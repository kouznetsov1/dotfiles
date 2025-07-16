# Neovim Configuration

A modern, TypeScript/JavaScript-focused Neovim configuration built with Lua and optimized for professional web development in monorepo environments.

## Features

### Core Editor
- **Plugin Manager**: lazy.nvim with lazy loading optimization
- **Colorscheme**: Gruvbox
- **Status Line**: lualine.nvim with git-root-relative paths
- **File Explorer**: oil.nvim (edit directories like buffers, replaces netrw)
- **Quick Navigation**: harpoon (v2) for fast file switching

### Language Support & LSP
- **LSP Manager**: Mason + Mason-lspconfig for automatic LSP server management
- **TypeScript/JavaScript**: Enhanced support with typescript-tools.nvim
- **Language Servers**: lua_ls, jsonls, yamlls, tailwindcss, prismals
- **JSON/YAML**: SchemaStore.nvim for intelligent schema validation
- **Tailwind CSS**: tailwind-tools.nvim with inline color previews
- **Prisma**: Full ORM support with syntax highlighting
- **Auto-close tags**: HTML/JSX auto tag closing and renaming

### Code Intelligence
- **Autocompletion**: nvim-cmp with comprehensive sources:
  - LSP completions with signature help
  - Buffer words and paths
  - NPM packages (in package.json)
  - Command-line completions
- **Syntax Highlighting**: TreeSitter with parsers for TS, TSX, JS, Lua, HTML, JSON, YAML, Prisma
- **Linting**: nvim-lint with ESLint and monorepo path resolution
- **Formatting**: Conform.nvim with project-aware Prettier integration (format on save)

### File Navigation & Search
- **Fuzzy Finder**: fzf-lua with comprehensive file/text search
- **Context Awareness**: nvim-treesitter-context shows function/class context
- **Git Integration**: All paths shown relative to git root

### Git Integration
- **Gitsigns**: Gutter indicators with hunk navigation
- **Diffview**: Enhanced diff viewing capabilities
- **Comprehensive Git Operations**: Stage/reset hunks, blame, diff navigation

### Custom Utilities
- **Clipboard Context**: Custom plugin for copying code with file/line context for LLM interactions
- **Diagnostic Copying**: Copy error messages with context
- **Smart Oil Navigation**: Opens file explorer at git root

## Keybindings

### Leader Key: `<Space>`

#### File Navigation
- `<leader>pv` - Open file explorer at git root (Oil)
- `<leader>ff` - Find files (fzf-lua)
- `<leader>fg` - Live grep (search in files)
- `<leader>fb` - Find buffers
- `<leader>fo` - Recent files
- `<leader>fc` - Grep word under cursor
- `-` - Open parent directory (Oil)

#### Harpoon (Quick File Access)
- `<leader>ha` - Add file to Harpoon
- `<C-h>` - Toggle Harpoon menu
- `<leader>1-6` - Jump to specific files
- `<C-S-P>` / `<C-S-N>` - Navigate Harpoon list

#### LSP Features
- `gd` - Go to definition
- `gr` - Find references
- `K` - Hover for documentation
- `<leader>rn` - Rename symbol
- `<leader>ca` - Code actions
- `<leader>f` - Format file

#### Diagnostics
- `<leader>e` - Show diagnostic in floating window
- `<leader>dn` - Next diagnostic
- `<leader>dp` - Previous diagnostic
- `[d` - Previous diagnostic (alternative)
- `]d` - Next diagnostic (alternative)

#### Git (Gitsigns)
- `<leader>hs` - Stage hunk
- `<leader>hr` - Reset hunk
- `<leader>hp` - Preview hunk
- `<leader>hb` - Blame line
- `<leader>tb` - Toggle blame on current line
- `[c` - Previous git change
- `]c` - Next git change

#### Custom Clipboard Features
- `<leader>yc` - Copy selection with file context (visual mode)
- `<leader>yd` - Copy diagnostics with context
- `dc` - Copy diagnostic to clipboard

#### Other
- `<leader>tc` - Toggle treesitter context (shows current function at top)
- `<C-a>` / `<C-x>` - Smart increment/decrement (works with Tailwind classes)

## Commands

- `:Lazy` - Plugin manager UI
- `:LspInfo` - Show attached language servers
- `:ConformInfo` - Show active formatters
- `:CmpStatus` - Show completion sources
- `:Lint` - Manually trigger linting
- `:TSInstall <language>` - Install TreeSitter parser
- `:TailwindSort` - Sort Tailwind classes
- `:UpdateRemotePlugins` - Update remote plugins (needed after installing tailwind-tools)
- `:Mason` - LSP server manager
- `:DiffviewOpen` - Open enhanced diff view

## Oil.nvim (File Explorer)

Oil lets you edit directories like text files:
- Navigate with normal vim motions
- Create files: Add a line with the filename and save
- Delete files: Delete the line with `dd` and save
- Rename files: Edit the filename and save
- Create directories: Add a line ending with `/` and save

## Monorepo Support

This config automatically handles monorepos (like your Viking turborepo):
- ESLint runs from the correct directory
- Finds Prettier config in parent directories
- TypeScript LSP detects the project root

## Adding New Languages

1. **Install LSP server**: Usually via your package manager or npm
2. **Add LSP config**: Create a file in `lua/dankovich/plugins/[language]lsp.lua`
3. **Add TreeSitter parser**: Add to `ensure_installed` in `treesitter.lua`
4. **Add formatter**: Add to `conform.lua` if needed
5. **Add linter**: Add to `lint.lua` if needed

## Troubleshooting

### ESLint not working
- Make sure ESLint is installed in your project
- Check `:Lint` output for errors
- In monorepos, it should automatically find the right config

### Formatting issues
- Run `:ConformInfo` to see active formatters
- Prettier uses your project's config automatically
- For Lua, global stylua config is at `~/.config/stylua/stylua.toml`

### TypeScript errors not showing
- Check `:LspInfo` to ensure typescript-tools is attached
- Make sure you have a `tsconfig.json` in your project

### Completions not working
- Run `:CmpStatus` to check sources
- For NPM completions, must be in `package.json` dependencies section

## File Structure

```
~/.config/nvim/
├── init.lua                 # Entry point
├── lazy-lock.json          # Plugin version lock file
├── lua/
│   └── dankovich/
│       ├── init.lua        # Main config loader
│       ├── remap.lua       # Key mappings
│       ├── set.lua         # Vim options
│       ├── lazy.lua        # Plugin declarations
│       └── plugins/        # Plugin configurations
│           ├── autopairs.lua
│           ├── clipboard-context.lua  # Custom clipboard utilities
│           ├── cmp.lua
│           ├── conform.lua
│           ├── context.lua
│           ├── diagnostics.lua
│           ├── fzf.lua
│           ├── gitsigns.lua
│           ├── harpoon.lua
│           ├── jsonls.lua
│           ├── lint.lua
│           ├── lualine.lua
│           ├── lualsp.lua
│           ├── oil.lua
│           ├── oil-clipboard.lua
│           ├── prismals.lua
│           ├── tailwind.lua
│           ├── treesitter.lua
│           ├── typescript.lua
│           └── yamlls.lua
└── stylua.toml             # Local Lua formatter config (optional)
```

## Performance & Architecture

- **Lazy Loading**: Most plugins load on specific events (InsertEnter, BufReadPre, etc.)
- **Startup Time**: Optimized with event-based loading
- **Monorepo Ready**: Automatic ESLint and Prettier resolution from project root
- **LSP Management**: Mason handles automatic LSP server installation and updates

## Currently Installed Plugins

31 plugins total including:
- **LSP Infrastructure**: mason, lspconfig, typescript-tools
- **Completion System**: nvim-cmp + 5 sources
- **File Navigation**: fzf-lua, oil, harpoon
- **Git Integration**: gitsigns, diffview
- **Code Quality**: conform, nvim-lint
- **UI Enhancements**: lualine, gruvbox, devicons
- **Language Tools**: tailwind-tools, SchemaStore
