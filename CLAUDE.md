# Dotfiles

Personal config for zsh, nvim, Herdr, tmux, ghostty, Claude Code, and Pi.

## Structure

```
dotfiles/
├── home/                 # Stowed to ~/
│   ├── .config/
│   │   ├── nvim/         # Neovim config
│   │   ├── herdr/        # Herdr workspace manager
│   │   ├── tmux/         # Legacy Tmux config
│   │   └── ghostty/      # Ghostty terminal
│   ├── .claude/          # Claude Code settings
│   ├── .pi/              # Portable Pi settings, instructions, keybindings, extensions
│   └── .zshrc            # Zsh config
├── install.sh            # Setup script
└── CLAUDE.md
```

## Install

```bash
./install.sh
```

This will:
1. Install stow if missing
2. Symlink everything in `home/` to `~/`
3. Install Herdr, zsh-autosuggestions, TPM
4. Install nvim plugins
5. Prompt to install deps (fzf, bat, rg, tree)

## Manual steps

Before running install.sh:
- Install oh-my-zsh: `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`
- Install neovim

## Updating

After editing configs in `home/`, run:
```bash
stow --no-folding -v --target="$HOME" home
```

Or re-run `./install.sh`.

## Notes

- Herdr config is stowed to `~/.config/herdr/config.toml`; runtime files remain machine-local
- Tmux uses `~/.config/tmux/tmux.conf` (not `~/.tmux.conf`)
- Claude settings exclude machine-specific data (history, credentials, etc.)
- Pi auth, trust decisions, sessions, caches, run history, and installed package contents stay machine-local under `~/.pi/agent/`
