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
├── .claude/        # claude code settings
└── .zshrc          # zsh
```

## Usage

Uses [GNU Stow](https://www.gnu.org/software/stow/) for symlinks.

```bash
# Update after editing
stow -v --target="$HOME" home
```

## What's included

| Config | Features |
|--------|----------|
| zsh | oh-my-zsh, fzf, `fzg` (rg+fzf search) |
| nvim | lazy.nvim, lsp, treesitter, oil, harpoon, fzf |
| tmux | vim navigation, TPM |
| ghostty | catppuccin macchiato, monolisa |
| claude | settings, skills, auto-format hooks |
