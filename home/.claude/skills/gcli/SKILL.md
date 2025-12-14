---
name: gcli
description: This skill should be used when working on Ultra projects and need to check, search, or read Gmail. Use when user asks about emails, messages, or mail related to Ultra work.
---

# gcli - Gmail CLI

Check Gmail from the terminal when working on Ultra projects.

## Commands

```bash
# List recent emails
gcli mail list
gcli mail list -n 20

# Search emails (options before query)
gcli mail search "from:jimmy"
gcli mail search --max 10 "subject:faktura"
gcli mail search "from:totalventilation"

# Read specific email
gcli mail read <message-id>
```

## Common Ultra Searches

```bash
# Fortnox related
gcli mail search "fortnox"

# From specific Ultra contacts
gcli mail search "from:johnny@ultra.se"
gcli mail search "from:jimmy@totalventilation.se"

# Bug reports / issues
gcli mail search "subject:bug OR subject:fel OR subject:dublett"
```

## Notes

- Options (`-n`, `--max`) must come before positional arguments
- Message IDs shown in list/search output can be used with `gcli mail read`
- Tokens stored in `~/.config/gcli/tokens.json`
- Re-authenticate with `gcli auth login` if tokens expire
