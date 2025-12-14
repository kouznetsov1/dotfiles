# Neovim Keybindings Reference

## Leader Key
- **Leader**: `<Space>`
- **Local Leader**: `\`

## File Navigation & Fuzzy Finding
| Mode | Keybinding | Description |
|------|------------|-------------|
| n | `<leader>pv` | Open file explorer at git root (Oil) |
| n | `<leader>ff` | Fuzzy find files |
| n | `<leader>fg` | Live grep |
| n | `<leader>fb` | Find buffers |
| n | `<leader>fh` | Help tags |
| n | `<leader>fo` | Recent files |
| n | `<leader>fc` | Grep word under cursor |

## Oil File Explorer
| Mode | Keybinding | Description |
|------|------------|-------------|
| n | `-` | Open parent directory |
| n | `<leader>-` | Open oil at current file |
| Oil buffer | `g?` | Show help |
| Oil buffer | `<CR>` | Select file/directory |
| Oil buffer | `<C-s>` | Open in vertical split |
| Oil buffer | `<C-h>` | Open in horizontal split |
| Oil buffer | `<C-t>` | Open in new tab |
| Oil buffer | `<C-p>` | Preview file |
| Oil buffer | `<C-c>` | Close oil |
| Oil buffer | `<C-l>` | Refresh |
| Oil buffer | `-` | Go to parent directory |
| Oil buffer | `_` | Open current working directory |
| Oil buffer | `` ` `` | Change directory (cd) |
| Oil buffer | `~` | Tab-local cd (tcd) |
| Oil buffer | `gs` | Change sort order |
| Oil buffer | `gx` | Open file with external program |
| Oil buffer | `g.` | Toggle hidden files |
| Oil buffer | `g\` | Toggle trash |

## Harpoon Quick Navigation
| Mode | Keybinding | Description |
|------|------------|-------------|
| n | `<leader>ha` | Add file to Harpoon |
| n | `<C-h>` | Toggle Harpoon menu |
| n | `<leader>1` | Navigate to Harpoon file 1 |
| n | `<leader>2` | Navigate to Harpoon file 2 |
| n | `<leader>3` | Navigate to Harpoon file 3 |
| n | `<leader>4` | Navigate to Harpoon file 4 |
| n | `<leader>5` | Navigate to Harpoon file 5 |
| n | `<leader>6` | Navigate to Harpoon file 6 |
| n | `<C-S-P>` | Previous Harpoon file |
| n | `<C-S-N>` | Next Harpoon file |

## LSP (Language Server Protocol)
| Mode | Keybinding | Description |
|------|------------|-------------|
| n | `gd` | Go to definition |
| n | `K` | Show hover info (types, docs) |
| n | `gr` | Find all references |
| n | `<leader>rn` | Rename symbol |
| n,v | `<leader>ca` | Code actions (quick fixes) |
| n | `<leader>f` | Format file |

## Diagnostics
| Mode | Keybinding | Description |
|------|------------|-------------|
| n | `<leader>df` | Open diagnostic float |
| n | `<leader>dn` | Go to next diagnostic |
| n | `<leader>dp` | Go to previous diagnostic |

## Git (Gitsigns)
| Mode | Keybinding | Description |
|------|------------|-------------|
| n | `]c` | Next git hunk |
| n | `[c` | Previous git hunk |
| n | `<leader>hs` | Stage hunk |
| n | `<leader>hr` | Reset hunk |
| v | `<leader>hs` | Stage selected hunk |
| v | `<leader>hr` | Reset selected hunk |
| n | `<leader>hS` | Stage entire buffer |
| n | `<leader>hu` | Undo stage hunk |
| n | `<leader>hR` | Reset entire buffer |
| n | `<leader>hp` | Preview hunk |
| n | `<leader>hb` | Blame line (full) |
| n | `<leader>tb` | Toggle current line blame |
| n | `<leader>hd` | Diff this |
| n | `<leader>hD` | Diff this against ~ |
| n | `<leader>td` | Toggle deleted |

## Completion (nvim-cmp)
| Mode | Keybinding | Description |
|------|------------|-------------|
| i | `<C-b>` | Scroll docs up |
| i | `<C-f>` | Scroll docs down |
| i | `<C-Space>` | Trigger completion |
| i | `<C-e>` | Abort completion |
| i | `<CR>` | Accept completion |
| i | `<Tab>` | Next completion item |
| i | `<S-Tab>` | Previous completion item |

## Clipboard & Context
| Mode | Keybinding | Description |
|------|------------|-------------|
| v | `<leader>yc` | Yank with context (filename:lines) |
| n | `<leader>yd` | Yank diagnostics with context |

## Treesitter Context
| Mode | Keybinding | Description |
|------|------------|-------------|
| n | `<leader>tc` | Toggle treesitter context |


## Quick Tips
- The leader key is `<Space>`, so `<leader>ff` means pressing Space followed by ff
- Most plugin commands start with `<leader>` for easy access
- LSP keybindings (like `gd` for go to definition) follow Vim conventions
- Use `:checkhealth` to verify all plugins are working correctly

## Keybinding Patterns
- **File operations**: `<leader>f*` (fuzzy finding, file search)
- **Git operations**: `<leader>h*` (hunks), `<leader>t*` (toggles)
- **LSP operations**: Standard vim keys (`gd`, `gr`, `K`) + `<leader>` commands
- **Diagnostics**: `<leader>d*`
- **Harpoon**: `<leader>1-6` for quick file access, `<C-h>` for menu
- **Clipboard**: `<leader>y*` for special yanking operations
