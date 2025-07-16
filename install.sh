#!/bin/bash

# Dotfiles Installation Script
# This script sets up symlinks for all dotfiles configurations

set -e  # Exit on any error

echo "🚀 Setting up dotfiles..."

# Get the directory where this script is located
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Function to create symlink with backup
create_symlink() {
    local source="$1"
    local target="$2"
    
    # Create target directory if it doesn't exist
    mkdir -p "$(dirname "$target")"
    
    # Backup existing file/directory if it exists
    if [ -e "$target" ] || [ -L "$target" ]; then
        echo "⚠️  Backing up existing $target to $target.backup"
        mv "$target" "$target.backup"
    fi
    
    # Create symlink
    ln -sf "$source" "$target"
    echo "✅ Linked $source -> $target"
}

# Neovim configuration
echo "📝 Setting up Neovim configuration..."
create_symlink "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

# Zsh configuration
if [ -f "$DOTFILES_DIR/zsh/.zshrc" ]; then
    echo "🐚 Setting up Zsh configuration..."
    create_symlink "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
fi

# Tmux configuration
if [ -f "$DOTFILES_DIR/tmux/.tmux.conf" ]; then
    echo "🔧 Setting up Tmux configuration..."
    create_symlink "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
fi

# Install Neovim plugins
echo "🔌 Installing Neovim plugins..."
if command -v nvim &> /dev/null; then
    nvim --headless -c "Lazy sync" -c "qa"
    echo "✅ Neovim plugins installed"
else
    echo "⚠️  Neovim not found. Please install Neovim first."
    echo "   macOS: brew install neovim"
    echo "   Linux: package manager or https://github.com/neovim/neovim/releases"
fi

echo ""
echo "🎉 Dotfiles installation complete!"
echo ""
echo "Next steps:"
echo "1. Restart your terminal or run: source ~/.zshrc (or ~/.bashrc)"
echo "2. Open Neovim to test the configuration"
echo "3. Run :checkhealth in Neovim to verify everything is working"
echo ""
echo "To add more dotfiles:"
echo "1. Add config files to $DOTFILES_DIR/"
echo "2. Update this install script with new symlinks"
echo "3. Run ./install.sh again"