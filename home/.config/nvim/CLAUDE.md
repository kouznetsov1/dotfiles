# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Neovim Configuration Overview

This is a modern, production-ready Neovim configuration using Lua with lazy.nvim as the plugin manager. The configuration is specifically designed to support TypeScript/JavaScript development in monorepo environments, with comprehensive LSP support, intelligent formatting, and modern editing features.

## Common Commands for Development

### Testing and Validation
- Test the configuration: `nvim --headless -c "checkhealth" -c "qa"`
- Verify plugin installation: `nvim --headless -c "Lazy sync" -c "qa"`
- Test specific language support: Open a file of that type and run `:LspInfo`
- Check all systems: `:Mason`, `:ConformInfo`, `:CmpStatus`, `:Lint`

### Debugging Issues
- Check LSP status: `:LspInfo`
- Check formatter status: `:ConformInfo`
- Check linter status: `:Lint` (custom command)
- Check completion sources: `:CmpStatus`
- View plugin status: `:Lazy`
- LSP server management: `:Mason`
- Git diff view: `:DiffviewOpen`

## Architecture and Key Design Decisions

### Plugin Loading Strategy
The configuration uses lazy.nvim with sophisticated event-based loading:
- **Critical plugins** (LSP, TreeSitter): Load immediately for core functionality
- **UI plugins** (lualine, context): Load on BufReadPre, InsertEnter
- **File navigation** (fzf, oil, harpoon): Load on specific keymaps
- **Git tools** (gitsigns, diffview): Load on git-related events
- **Language tools**: Load on filetype detection

### Monorepo Support (Enhanced)
Advanced monorepo handling implemented across multiple plugins:
- **ESLint**: Resolves from git root's node_modules, runs from nearest package.json directory
- **Prettier**: Automatically finds project-local formatters
- **TypeScript**: Detects project root and tsconfig.json
- **Path Display**: All paths shown relative to git root for context
- **Linting CWD**: Dynamically sets working directory for proper config resolution

### LSP Configuration Pattern
Standardized LSP setup across all language servers:
1. **Mason Integration**: Automatic server installation and management
2. **Capabilities Enhancement**: Extended with cmp_nvim_lsp for completions
3. **Server-specific Settings**: Tailored configurations per language
4. **Unified Keymaps**: Consistent LSP bindings via LspAttach autocmd
5. **Schema Support**: JSON/YAML schemas via SchemaStore.nvim

### Plugin Inter-dependencies & Critical Paths
Essential dependencies that must be maintained:
- **nvim-cmp ecosystem**: Requires cmp_nvim_lsp, cmp-buffer, cmp-path, cmp-cmdline, cmp-npm
- **LSP stack**: Mason → mason-lspconfig → individual language servers
- **Format/Lint chain**: conform.nvim + nvim-lint with project-local executable resolution
- **File navigation**: oil.nvim completely replaces netrw
- **Git integration**: gitsigns + diffview for comprehensive git workflows
- **Custom utilities**: clipboard-context.lua for LLM-friendly code copying

### Custom Plugin Ecosystem
Specialized plugins developed for this configuration:
- **clipboard-context.lua**: Copy code selections with file/line context
- **oil-clipboard.lua**: Enhanced clipboard integration with file explorer
- **diagnostics.lua**: Advanced diagnostic handling and copying

## Critical Configuration Details

### Leader Key & Keymaps
- **Leader**: Space (set in both lazy.lua and remap.lua)
- **Harpoon Integration**: Quick file access with numbered jumps
- **Git Workflow**: Comprehensive hunk navigation and operations
- **LSP Bindings**: Standardized across all language servers
- **Custom Clipboard**: Context-aware copying for AI interactions

### Formatter & Linter Resolution
- **Conform.nvim**: Automatically detects project-local formatters (node_modules)
- **Format on Save**: Enabled with 500ms timeout
- **ESLint Path Resolution**: Custom logic finds correct executable in monorepos
- **Prettier Integration**: Respects project configuration files

### Language Server Strategy
- **TypeScript**: Uses typescript-tools.nvim for enhanced performance
- **JSON/YAML**: SchemaStore integration for intelligent validation
- **Tailwind**: Dedicated tools for class sorting and color previews
- **Prisma**: Full ORM support with syntax highlighting
- **Lua**: Configured for Neovim development

## Performance Optimizations

### Startup Time
- **Lazy Loading**: Event-based plugin loading
- **Minimal Init**: Entry point only loads core module
- **Deferred Operations**: Heavy operations delayed until needed

### Memory Management
- **Plugin Scope**: Plugins only load for relevant file types
- **Buffer Management**: Efficient handling of large files
- **LSP Resource**: Proper server lifecycle management

## Known Issues and Workarounds

1. **Tailwind Tools Setup**: Requires `:UpdateRemotePlugins` after installation
2. **ESLint Monorepo Resolution**: Custom path logic in lint.lua handles complex project structures
3. **Neovim API Changes**: Configuration monitors for deprecated API usage
4. **Oil.nvim First Run**: May need manual netrw disable in some environments
5. **Mason LSP Installation**: Some servers require manual PATH configuration

## File Organization & Structure

### Core Configuration
- `init.lua` - Entry point, loads dankovich module
- `lua/dankovich/init.lua` - Core module loader with proper ordering
- `lua/dankovich/lazy.lua` - Plugin declarations with lazy loading specs
- `lua/dankovich/set.lua` - Vim options and editor settings
- `lua/dankovich/remap.lua` - Key mappings and leader key setup

### Plugin Configurations
- `lua/dankovich/plugins/` - Individual plugin configurations
- Language servers: `typescript.lua`, `jsonls.lua`, `yamlls.lua`, `prismals.lua`
- Code quality: `conform.lua`, `lint.lua`, `cmp.lua`
- Navigation: `fzf.lua`, `oil.lua`, `harpoon.lua`
- Git integration: `gitsigns.lua`
- Custom utilities: `clipboard-context.lua`, `diagnostics.lua`

### Lock Files & State
- `lazy-lock.json` - Plugin version lock file (31 plugins total)
- `.gitignore` - Excludes temporary files and debug utilities

## Development Guidelines

### Adding New Languages
1. Install LSP server via Mason or package manager
2. Create language-specific config in `plugins/[language]ls.lua`
3. Add TreeSitter parser to `treesitter.lua`
4. Configure formatter in `conform.lua` if needed
5. Add linter to `lint.lua` if applicable

### Plugin Updates
- Use `:Lazy sync` for updates
- Check `:checkhealth` after major updates
- Test LSP functionality with `:LspInfo`
- Verify formatting with `:ConformInfo`

### Troubleshooting Workflow
1. Check plugin status: `:Lazy`
2. Verify LSP servers: `:Mason`
3. Test language support: `:LspInfo`
4. Check formatting: `:ConformInfo`
5. Validate completion: `:CmpStatus`
6. Review linting: `:Lint`

## Security Considerations
- No sensitive data in configuration files
- Project-local executables are resolved securely
- LSP servers are managed through Mason for safety
- Git operations are read-only by default