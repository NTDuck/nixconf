// ninfer-tui — Bubble Tea TUI for the ninfer model switcher.
//
// Context table = live-measured VRAM champions on the RTX 3090
// (2026-11-11, qwen shapes on engine v0.15.0, bonsai2 on v0.17.2,
// peaks include ~150 MiB desktop):
// for each context, the max concurrency that fits in VRAM with no
// host-RAM KV spill. Switching is delegated to the `ninfer` shell CLI
// (`ninfer switch <model> --context <ctx>`), which owns the systemd
// + shape-file logic. The TUI is pure UI: it never touches systemctl.
package main

import (
	"bufio"
	"fmt"
	"os"
	"os/exec"
	"strings"
	"time"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

// shape is one measured (context, max-concurrency, peak MiB) triple.
type shape struct {
	ctx  int
	conc int
	mib  int
}

var modelShapes = map[string][]shape{
	"qwen3.8-27b": {
		{ctx: 16384, conc: 8, mib: 21150},
		{ctx: 32768, conc: 7, mib: 21144},
		{ctx: 65536, conc: 6, mib: 21462},
		{ctx: 131072, conc: 4, mib: 22000},
		{ctx: 262144, conc: 1, mib: 23364},
	},
	"qwen3.8-27b-turbo": {
		{ctx: 16384, conc: 8, mib: 19562},
		{ctx: 32768, conc: 8, mib: 19860},
		{ctx: 65536, conc: 8, mib: 20454},
		{ctx: 131072, conc: 8, mib: 21644},
		{ctx: 262144, conc: 5, mib: 23526},
	},
	// 2026-11-11 sweep on engine v0.17.2: 6.7 GiB ternary weights hold
	// the engine's C8 ceiling at every context (14166 MiB worst case).
	"bonsai2": {
		{ctx: 16384, conc: 8, mib: 9704},
		{ctx: 32768, conc: 8, mib: 10002},
		{ctx: 65536, conc: 8, mib: 10596},
		{ctx: 131072, conc: 8, mib: 11786},
		{ctx: 262144, conc: 8, mib: 14166},
	},
	// coder390 Q3: no measured sweep yet — no entry on purpose; the
	// shapes view renders "(no measured shapes)" and enter switches
	// with the unit default instead of a table row.
}

// defaultShape = the shape the CLI itself picks when `--context` is
// omitted (matching `default_conc_for` + DEFAULT_CTX in ninfer.nix):
// calling `ninfer switch <model>` without --context hits the CLI fast
// path, so the TUI omits the flag for exactly this shape.
var defaultShape = map[string]shape{
	"qwen3.8-27b":          {ctx: 65536, conc: 6},
	"qwen3.8-27b-turbo":    {ctx: 65536, conc: 6},
	"bonsai2":              {ctx: 65536, conc: 8},
	"qwen3.8-27b-coder390": {ctx: 65536, conc: 8},
}

type row struct {
	id    string
	port  string
	state string
}

var (
	titleStyle    = lipgloss.NewStyle().Bold(true).Foreground(lipgloss.Color("212"))
	activeStyle   = lipgloss.NewStyle().Foreground(lipgloss.Color("42"))
	inactiveStyle = lipgloss.NewStyle().Foreground(lipgloss.Color("241"))
	selStyle      = lipgloss.NewStyle().Bold(true).Foreground(lipgloss.Color("212"))
	helpStyle     = lipgloss.NewStyle().Foreground(lipgloss.Color("241"))
	errStyle      = lipgloss.NewStyle().Foreground(lipgloss.Color("196"))
)

type mode int

const (
	modeList mode = iota
	modeShapes
	modeSwitching
	modeDone
	modeErr
)

type uiModel struct {
	mode        mode
	cursor      int
	shapeCursor int
	rows        []row
	choice      string
	shape       shape
	output      strings.Builder
	err         error
	width       int
	height      int
	progress    string // latest CLI line in modeSwitching
	spin        int    // spinner frame index
}

func (m uiModel) Init() tea.Cmd { return queryModels() }

func queryModels() tea.Cmd {
	return tea.Cmd(func() tea.Msg {
		out, err := exec.Command("ninfer", "list").CombinedOutput()
		if err != nil {
			return modelsMsg{err: fmt.Errorf("%v: %s", err, out)}
		}
		var rows []row
		for _, line := range strings.Split(string(out), "\n") {
			f := strings.Fields(line)
			if len(f) < 3 {
				continue
			}
			mid := f[0]
			if mid == "<nil>" {
				continue
			}
			state := "inactive"
			port := ""
			for _, fl := range f {
				if fl == "active" || fl == "inactive" {
					state = fl
				}
				if strings.HasPrefix(fl, ":") {
					port = strings.TrimPrefix(fl, ":")
				}
			}
			rows = append(rows, row{id: mid, state: state, port: port})
		}
		// Synthetic unload-all row: `ninfer switch <nil>` unloads every
		// active model. State mirrors "no other row active".
		nilState := "inactive"
		nilPort := ""
		for _, r := range rows {
			if r.state == "active" {
				nilState, nilPort = "active", r.port
				break
			}
		}
		rows = append(rows, row{id: "<nil>", state: nilState, port: nilPort})
		return modelsMsg{rows: rows}
	})
}

type modelsMsg struct {
	rows []row
	err  error
}

type switchDoneMsg struct{ out string }

type switchErrMsg struct{ err error }

// progressMsg carries one CLI output line during a running switch.
type progressMsg struct{ line string }

// spinnerTickMsg drives the animated spinner in the switching view.
type spinnerTickMsg struct{}

var spinnerFrames = []string{"|", "/", "-", "\\"}

func tickSpinner() tea.Cmd {
	return tea.Tick(time.Millisecond*100, func(time.Time) tea.Msg {
		return spinnerTickMsg{}
	})
}

// runSwitch switches to target; ctx < 0 omits --context entirely so the
// CLI fast path (and the default shape) applies.
//
// Output is streamed through a channel that keeps running AFTER this
// closure returns: returning progressMsg per line from here (the naive
// shape) exits the whole tea.Cmd on the first line — cmd.Wait() would
// never run and the CLI would be orphaned. The goroutine below feeds
// lines to Update via progressMsg and delivers the terminal
// switchDone/ErrMsg itself, so the spinner stays live for the full
// switch.
func runSwitch(target string, ctx int) tea.Cmd {
	return tea.Cmd(func() tea.Msg {
		args := []string{"switch", target}
		if ctx >= 0 {
			args = append(args, "--context", fmt.Sprint(ctx))
		}
		lines := make(chan string)
		out := make(chan string, 1)
		go func() {
			defer close(lines)
			var collected strings.Builder
			fail := func(err error) {
				// CLI stderr already carries its own "error:" prefix.
				lines <- fmt.Sprintf("\x00err:%v: %s", err, collected.String())
			}
			cmd := exec.Command("ninfer", args...)
			// CombinedOutput equivalent: fold stderr into the same stream.
			cmd.Stderr = cmd.Stdout
			stdout, err := cmd.StdoutPipe()
			if err != nil {
				fail(err)
				return
			}
			if err := cmd.Start(); err != nil {
				fail(err)
				return
			}
			scanner := bufio.NewScanner(stdout)
			for scanner.Scan() {
				// Strip trailing \r so CLI progress spinners render cleanly.
				line := strings.TrimRight(scanner.Text(), "\r")
				collected.WriteString(line)
				collected.WriteByte('\n')
				lines <- line
			}
			out <- collected.String()
			if err := cmd.Wait(); err != nil {
				fail(err)
			}
		}()
		return streamSwitch(lines, out)
	})
}

// streamSwitch relays channel lines as progressMsgs, batching each with
// the follow-up re-entry so Update keeps a live tea.Cmd. The terminal
// line (\x00err: prefixed) becomes switchErrMsg; channel close becomes
// switchDoneMsg carrying the final buffer. out is the goroutine's
// accumulated output — Batch runs Cmds concurrently, so per-invocation
// builders would each see only their own slice of the stream.
func streamSwitch(lines <-chan string, out <-chan string) tea.Msg {
	for line := range lines {
		if strings.HasPrefix(line, "\x00err:") {
			// Drain the rest so the writer goroutine never blocks on a
			// send after this chain stops consuming.
			for range lines {
			}
			return switchErrMsg{err: fmt.Errorf("%s", strings.TrimPrefix(line, "\x00err:"))}
		}
		if strings.TrimSpace(line) == "" {
			continue
		}
		return tea.Batch(
			tea.Cmd(func() tea.Msg { return progressMsg{line: line} }),
			tea.Cmd(func() tea.Msg { return streamSwitch(lines, out) }),
		)
	}
	return switchDoneMsg{out: <-out}
}

func (m uiModel) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.width, m.height = msg.Width, msg.Height
	case tea.KeyMsg:
		switch msg.String() {
		case "ctrl+c":
			// Only way out of a running switch.
			return m, tea.Quit
		case "q":
			if m.mode != modeSwitching {
				return m, tea.Quit
			}
		case "esc":
			switch m.mode {
			case modeList:
				return m, tea.Quit
			case modeShapes, modeDone, modeErr:
				m.mode = modeList
			}
		case "b": // back
			if m.mode == modeShapes || m.mode == modeDone || m.mode == modeErr {
				m.mode = modeList
			}
		case "up", "k":
			if m.mode == modeList && m.cursor > 0 {
				m.cursor--
			}
			if m.mode == modeShapes && m.shapeCursor > 0 {
				m.shapeCursor--
			}
		case "down", "j":
			if m.mode == modeList && m.cursor < len(m.rows)-1 {
				m.cursor++
			}
			if m.mode == modeShapes && m.shapeCursor < len(modelShapes[m.choice])-1 {
				m.shapeCursor++
			}
		case "enter":
			switch m.mode {
			case modeList:
				if m.cursor < 0 || m.cursor >= len(m.rows) {
					return m, nil
				}
				m.choice = m.rows[m.cursor].id
				if m.choice == "<nil>" {
					// Unload-all: enter skips the shapes view entirely.
					m.shape = shape{conc: -1, ctx: -1}
					m.mode = modeSwitching
					m.progress = ""
					return m, tea.Batch(runSwitch("<nil>", -1), tickSpinner())
				}
				m.mode = modeShapes
				m.shapeCursor = 0
			case modeShapes:
				shapes, ok := modelShapes[m.choice]
				if !ok || m.shapeCursor < 0 || m.shapeCursor >= len(shapes) {
					return m, nil
				}
				m.shape = shapes[m.shapeCursor]
				m.mode = modeSwitching
				m.progress = ""
				// Default shape → omit --context so the CLI fast path applies.
				// Compare ctx+conc only: defaultShape entries carry no mib.
				ctx := m.shape.ctx
				if def, ok := defaultShape[m.choice]; ok && def.ctx == m.shape.ctx && def.conc == m.shape.conc {
					ctx = -1
				}
				return m, tea.Batch(runSwitch(m.choice, ctx), tickSpinner())
			}
		}
	case modelsMsg:
		if msg.err != nil {
			m.err = msg.err
			m.mode = modeErr
			return m, nil
		}
		m.rows = msg.rows
		// Refreshed rows must not wipe the done/err screen the user is
		// reading; only the list switches back to modeList.
		if m.mode != modeDone && m.mode != modeErr && m.mode != modeSwitching {
			m.mode = modeList
		}
		if m.cursor >= len(m.rows) {
			m.cursor = max(0, len(m.rows)-1)
		}
	case progressMsg:
		m.progress = msg.line
		// Keep the spinner ticking while CLI lines keep arriving.
		return m, tickSpinner()
	case switchDoneMsg:
		m.output.Reset()
		m.output.WriteString(msg.out)
		m.mode = modeDone
		return m, queryModels()
	case spinnerTickMsg:
		if m.mode == modeSwitching {
			m.spin = (m.spin + 1) % len(spinnerFrames)
			return m, tickSpinner()
		}
	case switchErrMsg:
		m.err = msg.err
		m.mode = modeErr
		return m, queryModels()
	}
	return m, nil
}

// kCtx abbreviates a context length the way the zsh completions do
// (16384 → 16k, 65536 → 64k, 262144 → 256k).
func kCtx(ctx int) string {
	return fmt.Sprintf("%dk", ctx/1024)
}

func (m uiModel) View() string {
	var b strings.Builder
	b.WriteString(titleStyle.Render(" ninfer — model switcher ") + "\n")
	b.WriteString(helpStyle.Render(" measured shapes (max concurrency per context, RTX 3090 VRAM-only)") + "\n\n")
	switch m.mode {
	case modeList:
		// Pad plain text BEFORE styling so colors never skew widths.
		for i, r := range m.rows {
			cursor := "  "
			if i == m.cursor {
				cursor = "> "
			}
			var shapesCol string
			for _, s := range modelShapes[r.id] {
				shapesCol += fmt.Sprintf("%dx%s ", s.conc, kCtx(s.ctx))
			}
			line := fmt.Sprintf("%s%-16s %-30s %-9s :%s", cursor, r.id, strings.TrimSpace(shapesCol), r.state, r.port)
			if i == m.cursor {
				line = selStyle.Render(line)
			} else if r.state == "active" {
				// Color just the padded state field.
				line = strings.Replace(line, r.state, activeStyle.Render(r.state), 1)
			} else if r.id != "<nil>" {
				line = strings.Replace(line, r.state, inactiveStyle.Render(r.state), 1)
			}
			b.WriteString(line + "\n")
		}
		b.WriteString("\n" + helpStyle.Render("↑/↓/j/k move · enter select · q quit"))
	case modeShapes:
		shapes, ok := modelShapes[m.choice]
		if !ok {
			b.WriteString(fmt.Sprintf("no measured shapes for %s\n", m.choice))
			b.WriteString("\n" + helpStyle.Render("b back · q quit"))
			break
		}
		def, hasDef := defaultShape[m.choice]
		b.WriteString(fmt.Sprintf("context for %s:\n\n", m.choice))
		for i, s := range shapes {
			cursor := "  "
			if i == m.shapeCursor {
				cursor = "> "
			}
			hint := ""
			if hasDef && s == def {
				hint = " (default)"
			}
			line := fmt.Sprintf("%s%dx%-8s %6d MiB peak%s", cursor, s.conc, kCtx(s.ctx), s.mib, hint)
			if i == m.shapeCursor {
				line = selStyle.Render(line)
			}
			b.WriteString(line + "\n")
		}
		b.WriteString("\n" + helpStyle.Render("↑/↓ move · enter switch · b back · q quit"))
	case modeSwitching:
		spinner := spinnerFrames[m.spin]
		if m.choice == "<nil>" {
			b.WriteString(clipWidth(fmt.Sprintf("%s unloading all models... this can take a moment", spinner), m.width) + "\n")
		} else {
			b.WriteString(clipWidth(fmt.Sprintf("%s switching to %s (%dx%d)... loading weights, this can take a minute",
				spinner, m.choice, m.shape.conc, m.shape.ctx), m.width) + "\n")
		}
		if m.progress != "" {
			b.WriteString("\n" + clipWidth(m.progress, m.width) + "\n")
		}
	case modeDone:
		b.WriteString(clipWidth(m.output.String(), m.width))
		b.WriteString("\n" + helpStyle.Render("q/esc quit · b back"))
	case modeErr:
		b.WriteString(clipWidth(errStyle.Render(fmt.Sprintf("%v", m.err)), m.width) + "\n")
		b.WriteString(helpStyle.Render("q/esc quit · b back"))
	}
	return b.String()
}

// clipWidth hard-wraps a rendered block to the stored terminal width so
// long CLI journal spew cannot overflow the screen. 0 = no clipping.
func clipWidth(s string, width int) string {
	if width <= 0 {
		return s
	}
	return lipgloss.NewStyle().MaxWidth(width).Render(s)
}

func main() {
	if _, err := tea.NewProgram(uiModel{}, tea.WithAltScreen()).Run(); err != nil {
		fmt.Fprintf(os.Stderr, "ninfer-tui: %v\n", err)
		os.Exit(1)
	}
}
