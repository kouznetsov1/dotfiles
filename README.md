# dotfiles

Personal config for zsh, nvim, tmux, ghostty, and claude code.

## Install

```bash
# Prerequisites: oh-my-zsh + neovim
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Clone and install
git clone https://github.com/kouznetsov1/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

## Structure

```
home/
├── .config/
│   ├── nvim/       # neovim
│   ├── tmux/       # tmux
│   └── ghostty/    # ghostty terminal
├── .claude/        # Claude Code settings
├── .pi/            # Pi settings, instructions, keybindings, and extensions
└── .zshrc          # zsh
```

## Usage

Uses [GNU Stow](https://www.gnu.org/software/stow/) for symlinks.

```bash
# Update after editing
stow --no-folding -v --target="$HOME" home
```

## What's included

| Config | Features |
|--------|----------|
| zsh | oh-my-zsh, fzf, `fzg` (rg+fzf search) |
| nvim | lazy.nvim, lsp, treesitter, oil, harpoon, fzf |
| tmux | vim navigation, TPM |
| ghostty | catppuccin macchiato, monolisa |
| Claude Code | settings, skills, auto-format hooks |
| Pi | model/package settings, global instructions, keybindings, production access gate |

The installer installs Claude Code and Pi when needed, stows their portable configuration, and
reconciles the packages declared in `~/.pi/agent/settings.json`. Authentication, sessions, caches,
and installed package contents remain machine-local.
