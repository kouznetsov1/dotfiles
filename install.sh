#!/bin/bash
set -e

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check for stow
if ! command -v stow &> /dev/null; then
    echo "stow not found. Installing..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install stow
    else
        sudo apt install -y stow
    fi
fi

# Stow home directory
cd "$DOTFILES_DIR"
echo "Stowing dotfiles..."
stow -v --target="$HOME" home

# zsh-autosuggestions
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [ -d "$HOME/.oh-my-zsh" ] && [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# TPM (tmux plugin manager)
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "Installing TPM..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# Neovim plugins
if command -v nvim &> /dev/null; then
    echo "Installing nvim plugins..."
    nvim --headless -c "Lazy sync" -c "qa"
fi

# Dependencies
DEPS=(fzf bat ripgrep tree)
MISSING=()
for dep in "${DEPS[@]}"; do
    cmd=$dep
    [ "$dep" = "ripgrep" ] && cmd="rg"
    [ "$dep" = "bat" ] && command -v batcat &> /dev/null && continue
    command -v "$cmd" &> /dev/null || MISSING+=("$dep")
done

if [ ${#MISSING[@]} -gt 0 ]; then
    echo ""
    echo "Missing: ${MISSING[*]}"
    read -p "Install? [y/N] " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install "${MISSING[@]}"
        else
            sudo apt install -y "${MISSING[@]}"
        fi
    fi
fi

# Ubuntu: batcat -> bat alias
if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(which batcat)" "$HOME/.local/bin/bat"
    echo "Linked batcat -> bat"
fi

echo "Done!"
