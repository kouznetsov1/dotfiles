#!/bin/bash
set -e

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

create_symlink() {
    mkdir -p "$(dirname "$2")"
    [ -e "$2" ] || [ -L "$2" ] && mv "$2" "$2.backup"
    ln -sf "$1" "$2"
    echo "Linked $2"
}

# Symlinks
create_symlink "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
create_symlink "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
create_symlink "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"

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
    echo "Missing dependencies: ${MISSING[*]}"
    read -p "Install them? [y/N] " -n 1 -r
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
