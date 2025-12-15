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

# JetBrains Mono Nerd Font
if ! fc-list | grep -qi "JetBrainsMono Nerd Font"; then
    echo "Installing JetBrains Mono Nerd Font..."
    mkdir -p ~/.local/share/fonts
    cd ~/.local/share/fonts
    curl -fLO "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
    unzip -o JetBrainsMono.zip -d JetBrainsMono
    rm JetBrainsMono.zip
    fc-cache -f
    cd "$DOTFILES_DIR"
fi

# Neovim plugins
if command -v nvim &> /dev/null; then
    echo "Installing nvim plugins..."
    nvim --headless -c "Lazy sync" -c "qa"
fi

# zoxide
if ! command -v zoxide &> /dev/null; then
    echo "Installing zoxide..."
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

# Detect OS/arch for binary downloads
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="Darwin"
else
    OS="Linux"
fi
ARCH=$(uname -m)
[[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]] && ARCH="arm64" || ARCH="x86_64"

# sesh (tmux session manager)
if ! command -v sesh &> /dev/null; then
    echo "Installing sesh..."
    mkdir -p ~/.local/bin
    curl -sSfL "https://github.com/joshmedeski/sesh/releases/latest/download/sesh_${OS}_${ARCH}.tar.gz" | tar xz -C /tmp
    mv /tmp/sesh ~/.local/bin/
fi

# lazygit
if ! command -v lazygit &> /dev/null; then
    echo "Installing lazygit..."
    mkdir -p ~/.local/bin
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -oE '"tag_name": *"v[^"]*"' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
    curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_${OS}_${ARCH}.tar.gz"
    tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
    mv /tmp/lazygit ~/.local/bin/
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
