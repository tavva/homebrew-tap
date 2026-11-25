# homebrew-tap

Ben's personal Homebrew tap (`brew tap tavva/tap`). It holds formulae that
patch or pin software where Homebrew's own formula isn't usable as is.

## Formulae

- `tmux`: tmux 3.7c from homebrew-core's 3.7c formula, plus upstream commit
  0750e649 (tmux issue 5664: the server spins in `screen_redraw_screen` when a
  client is narrower than a window with `pane-border-status`). Installed as
  `tavva/tap/tmux` in place of homebrew-core's `tmux`, so `brew upgrade`
  follows this tap and won't bring back the bug. Drop it and go back to
  core's `tmux` once a core release contains the fix.

## Conventions

- Base each formula on homebrew-core's, and say in a comment what differs.
- Keep patches inline (`patch :DATA`) so their checksums can't drift.
- Check with `brew audit --tap tavva/tap` and `brew install --build-from-source`.
