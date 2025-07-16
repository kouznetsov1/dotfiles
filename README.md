# Dotfiles

My personal development environment configuration files.

## Quick Start

```bash
# Clone the repository
git clone https://github.com/kouznetsov1/dotfiles.git ~/dotfiles

# Run the installation script
cd ~/dotfiles
./install.sh
```

## What's Included

### 📝 Neovim Configuration
A modern, TypeScript/JavaScript-focused Neovim setup with:
- **Plugin Manager**: lazy.nvim with lazy loading
- **LSP Support**: Mason-managed language servers (TypeScript, JSON, YAML, Lua, Prisma, Tailwind)
- **Completion**: nvim-cmp with multiple sources
- **File Navigation**: fzf-lua, oil.nvim, harpoon
- **Git Integration**: gitsigns, diffview
- **Code Quality**: ESLint, Prettier with monorepo support
- **Custom Features**: LLM-friendly clipboard utilities

See [nvim/README.md](nvim/README.md) for detailed configuration info.

### 🐚 Zsh Configuration
- Shell customizations and aliases
- Oh My Zsh integration
- FZF integration with custom key bindings
- Advanced grep-based file finding functions:
  - `fzg <term>` / `fzf_grep <term>` - Search file contents, open at line
  - `fzs` / `fzf_search` - Interactive search through all files
  - `fze <term>` / `fzf_edit <term>` - Find files by content, edit selected

### 🔧 Tmux Configuration
- Custom key bindings and layouts
- Status bar customization
- Session management enhancements

## Installation Details

The `install.sh` script creates symlinks from your home directory to the dotfiles:

```
~/.config/nvim -> ~/dotfiles/nvim
~/.zshrc -> ~/dotfiles/zsh/.zshrc
~/.tmux.conf -> ~/dotfiles/tmux/.tmux.conf
```

### Safety Features
- **Automatic Backup**: Existing configs are backed up with `.backup` extension
- **Directory Creation**: Creates necessary parent directories
- **Error Handling**: Exits on any error during installation

## Adding New Dotfiles

1. **Add config files** to appropriate directory in `~/dotfiles/`
2. **Update install.sh** to include new symlinks
3. **Run installation** again: `./install.sh`
4. **Commit changes** to git

## Directory Structure

```
dotfiles/
├── nvim/                   # Neovim configuration
│   ├── init.lua           # Entry point
│   ├── lua/dankovich/     # Main config modules
│   ├── README.md          # Detailed Neovim docs
│   └── CLAUDE.md          # AI assistant context
├── zsh/                   # Zsh configuration
│   └── .zshrc             # Zsh configuration file
├── tmux/                  # Tmux configuration
│   └── .tmux.conf         # Tmux configuration file
├── install.sh             # Installation script
└── README.md              # This file
```

## Requirements

- **Neovim**: 0.8+ (for LSP and modern features)
- **Zsh**: For shell configuration
- **Tmux**: For terminal multiplexing
- **Git**: For version control

### Essential Dependencies
- **fzf**: Fuzzy finder (core dependency for Neovim file navigation)
- **ripgrep**: Fast grep alternative (required for fzf live grep)
- **fd**: Fast find alternative (improves file finding performance)

### Installation Commands
```bash
# macOS
brew install fzf ripgrep fd

# Ubuntu/Debian
sudo apt install fzf ripgrep fd-find

# Arch Linux
sudo pacman -S fzf ripgrep fd
```

### Optional but Recommended
- **Node.js**: For TypeScript/JavaScript LSP servers

## Troubleshooting

### Neovim Issues
```bash
# Check plugin status
nvim -c "Lazy" -c "qa"

# Check LSP servers
nvim -c "Mason" -c "qa"

# Run health check
nvim -c "checkhealth" -c "qa"
```

### Symlink Issues
```bash
# Verify symlinks are correct
ls -la ~/.config/nvim ~/.zshrc ~/.tmux.conf

# Re-run installation
cd ~/dotfiles && ./install.sh
```

### Plugin Installation
```bash
# Force plugin sync
nvim --headless -c "Lazy sync" -c "qa"
```

## Customization

### Personal Modifications
- Fork this repository
- Modify configurations in respective directories
- Update install.sh if adding new configs
- Keep your fork synced with updates

### Machine-Specific Settings
- Use local config files that aren't tracked in git
- Neovim: `~/.config/nvim/lua/local.lua`
- Zsh: `~/.zshrc.local`
- Tmux: `~/.tmux.conf.local`

## Backup Strategy

Before making major changes:
```bash
# Create a backup branch
git checkout -b backup-$(date +%Y%m%d)
git add . && git commit -m "Backup before changes"
git checkout main
```

## Contributing

1. Test changes thoroughly
2. Update documentation if needed
3. Ensure install.sh works correctly
4. Submit pull request with clear description

## License

Personal configuration files - use at your own discretion.