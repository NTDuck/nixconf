// ninfer-tui — Bubble Tea TUI for the ninfer model switcher.
//
// Context table = live-measured VRAM champions on the RTX 3090
// (2026-11-11, engine v0.15.0, peaks include ~150 MiB desktop):
// for each context, the max concurrency that fits in VRAM with no
// host-RAM KV spill. Switching is delegated to the `ninfer` shell CLI
// (`ninfer switch <model> --context <ctx>`), which owns the systemd
// + shape-file logic. The TUI is pure UI: it never touches systemctl.
package main

import (
	"fmt"
	"os"
	"os/exec"
	"strings"

	"github.com/charmbracelet/bubbletea"
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
}

func (m uiModel) Init() tea.Cmd { return queryModels() }

func queryModels() tea.Cmd {
	return tea.Cmd(func() tea.Msg {
		out, err := exec.Command("ninfer", "list").Output()
		if err != nil {
			return modelsMsg{err: err}
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
		return modelsMsg{rows: rows}
	})
}

type modelsMsg struct {
	rows []row
	err  error
}

type switchDoneMsg struct{ out string }

type switchErrMsg struct{ err error }

func runSwitch(target string, ctx int) tea.Cmd {
	return tea.Cmd(func() tea.Msg {
		args := []string{"switch", target, "--context", fmt.Sprint(ctx)}
		out, err := exec.Command("ninfer", args...).CombinedOutput()
		if err != nil {
			return switchErrMsg{err: fmt.Errorf("%v: %s", err, out)}
		}
		return switchDoneMsg{out: string(out)}
	})
}

func (m uiModel) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.width, m.height = msg.Width, msg.Height
	case tea.KeyMsg:
		switch msg.String() {
		case "q", "esc", "ctrl+c":
			if m.mode == modeSwitching {
				return m, nil
			}
			return m, tea.Quit
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
				if len(m.rows) == 0 {
					return m, nil
				}
				m.choice = m.rows[m.cursor].id
				m.mode = modeShapes
				m.shapeCursor = 0
			case modeShapes:
				m.shape = modelShapes[m.choice][m.shapeCursor]
				m.mode = modeSwitching
				return m, runSwitch(m.choice, m.shape.ctx)
			}
		case "b": // back
			if m.mode == modeShapes {
				m.mode = modeList
			}
		}
	case modelsMsg:
		if msg.err != nil {
			m.err = msg.err
			m.mode = modeErr
			return m, nil
		}
		m.rows = msg.rows
		m.mode = modeList
	case switchDoneMsg:
		m.output.Reset()
		m.output.WriteString(msg.out)
		m.mode = modeDone
		return m, queryModels()
	case switchErrMsg:
		m.err = msg.err
		m.mode = modeErr
	}
	return m, nil
}

func (m uiModel) View() string {
	var b strings.Builder
	b.WriteString(titleStyle.Render(" ninfer — model switcher ") + "\n")
	b.WriteString(helpStyle.Render(" measured max concurrency per context (RTX 3090, VRAM-only)") + "\n\n")
	switch m.mode {
	case modeList:
		for i, r := range m.rows {
			cursor := "  "
			if i == m.cursor {
				cursor = "> "
			}
			state := r.state
			styled := inactiveStyle.Render(state)
			if state == "active" {
				styled = activeStyle.Render(state)
			}
			line := fmt.Sprintf("%s%-24s %-10s :%s", cursor, r.id, styled, r.port)
			if i == m.cursor {
				line = selStyle.Render(line)
			}
			b.WriteString(line + "\n")
		}
		b.WriteString("\n" + helpStyle.Render("↑/↓ move · enter select · q quit"))
	case modeShapes:
		b.WriteString(fmt.Sprintf("context for %s:\n\n", m.choice))
		for i, s := range modelShapes[m.choice] {
			cursor := "  "
			if i == m.shapeCursor {
				cursor = "> "
			}
			line := fmt.Sprintf("%s%dx%-8d %6d MiB peak", cursor, s.conc, s.ctx, s.mib)
			if i == m.shapeCursor {
				line = selStyle.Render(line)
			}
			b.WriteString(line + "\n")
		}
		b.WriteString("\n" + helpStyle.Render("↑/↓ move · enter switch · b back · q quit"))
	case modeSwitching:
		b.WriteString(fmt.Sprintf("switching to %s (%dx%d)... loading weights, this can take a minute\n",
			m.choice, m.shape.conc, m.shape.ctx))
	case modeDone:
		b.WriteString(m.output.String())
		b.WriteString("\n" + helpStyle.Render("q quit"))
	case modeErr:
		b.WriteString(errStyle.Render(fmt.Sprintf("error: %v", m.err)) + "\n")
		b.WriteString(helpStyle.Render("q quit"))
	}
	return b.String()
}

func main() {
	if _, err := tea.NewProgram(uiModel{}, tea.WithAltScreen()).Run(); err != nil {
		fmt.Fprintf(os.Stderr, "ninfer-tui: %v\n", err)
		os.Exit(1)
	}
}
