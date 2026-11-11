package main

import (
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"

	tea "github.com/charmbracelet/bubbletea"
)

// stubNinfer writes a shell-script stand-in for the ninfer CLI into a
// per-test temp dir and returns its path. The sandbox has no /tmp/tui-
// smoke stub (the original smoke harness) — a missing stub there made
// cmd.Start() fail and the test block forever on the channel (seen as
// a 600s testing panic inside the Nix build).
func stubNinfer(t *testing.T) string {
	t.Helper()
	script := "#!/usr/bin/env bash\necho \"Stopping bonsai2 (ninfer-df2.service)... done.\"\necho \"  → weights ready\"\necho \"loading weights 42%\"\necho \"✔ Ready in 5s | listening on http://0.0.0.0:8092\"\necho \"switched to bonsai2\"\n"
	path := filepath.Join(t.TempDir(), "ninfer")
	if err := os.WriteFile(path, []byte(script), 0o700); err != nil {
		t.Fatal(err)
	}
	return path
}

// feedCLI runs the stub ninfer binary and pipes its output into lines;
// the collected buffer lands in out. Start failures fail via Errorf
// (Fatal is not goroutine-safe) and return early — the deferred
// close(lines) unblocks the consumer.
func feedCLI(t *testing.T, stub string, lines chan<- string, out chan<- string, args ...string) {
	t.Helper()
	defer close(lines)
	cmd := exec.Command(stub, args...)
	cmd.Stderr = cmd.Stdout
	stdout, err := cmd.StdoutPipe()
	if err != nil {
		// Fatal is not goroutine-safe; feedCLI runs on its own
		// goroutine — fail via Errorf and close early so the
		// consumer's drain() sees the terminal state instead of
		// blocking.
		t.Errorf("stdout pipe: %v", err)
		return
	}
	if err := cmd.Start(); err != nil {
		t.Errorf("stub start: %v", err)
		return
	}
	buf := make([]byte, 4096)
	var acc strings.Builder
	for {
		n, err := stdout.Read(buf)
		if n > 0 {
			for _, l := range strings.Split(strings.TrimRight(string(buf[:n]), "\n"), "\n") {
				lines <- l
			}
			acc.Write(buf[:n])
		}
		if err != nil {
			break
		}
	}
	out <- acc.String()
	if err := cmd.Wait(); err != nil {
		t.Error(err)
	}
}

// drain walks the Batch/re-entry chain until a terminal msg appears.
func drain(t *testing.T, msg tea.Msg) tea.Msg {
	for i := 0; i < 64; i++ {
		switch m := msg.(type) {
		case progressMsg:
			t.Fatalf("unexpected bare progressMsg: %v", m.line)
		case tea.Cmd:
			msg = m()
		case tea.BatchMsg:
			var next tea.Msg
			for _, c := range m {
				r := c()
				if _, isProg := r.(progressMsg); !isProg {
					next = r
					break
				}
			}
			if next == nil {
				t.Fatal("batch yielded no terminal msg")
			}
			msg = next
		default:
			return msg
		}
	}
	t.Fatal("drain did not terminate")
	return nil
}

// The streamSwitch contract: every CLI line becomes a progressMsg, the
// final collected output lands in switchDoneMsg, and the CLI process is
// fully reaped (no orphan).
func TestStreamSwitchFullFlow(t *testing.T) {
	// Stub is created on the test goroutine (t.TempDir registers
	// cleanup and is not goroutine-safe).
	stub := stubNinfer(t)
	lines := make(chan string, 16)
	out := make(chan string, 1)
	go feedCLI(t, stub, lines, out, "switch", "bonsai2")
	msg := drain(t, streamSwitch(lines, out))
	done, ok := msg.(switchDoneMsg)
	if !ok {
		t.Fatalf("expected switchDoneMsg, got %T: %v", msg, msg)
	}
	if !strings.Contains(done.out, "switched to bonsai2") {
		t.Fatalf("missing final line in %q", done.out)
	}
	if !strings.Contains(done.out, "weights ready") {
		t.Fatalf("missing milestone line in %q", done.out)
	}
}

// Progress lines precede the terminal \x00err: line; the chain must
// deliver switchErrMsg carrying the failure and prior output.
func TestStreamSwitchError(t *testing.T) {
	lines := make(chan string, 4)
	out := make(chan string, 1)
	go func() {
		defer close(lines)
		lines <- "error: failed to start some.service"
		lines <- "\x00err:exit status 1: error: failed to start some.service"
		out <- "error: failed to start some.service\n"
	}()
	msg := drain(t, streamSwitch(lines, out))
	e, ok := msg.(switchErrMsg)
	if !ok {
		t.Fatalf("expected switchErrMsg, got %T: %v", msg, msg)
	}
	if !strings.Contains(e.err.Error(), "failed to start") {
		t.Fatalf("wrong error: %v", e.err)
	}
}
