# ast-grep

ast-grep matches code by structure (AST), not text. Use `-p 'pattern'` for search, `-l lang` for language.
Metavariables: `$VAR` matches one node, `$$$VARS` matches zero or more nodes.
Examples: `ast-grep -p 'console.log($$$)'` finds all console.log calls, `ast-grep -p '$A == $A'` finds self-comparisons.
For rewrites: `ast-grep -p 'old($$$ARGS)' --rewrite 'new($$$ARGS)' --interactive`
Rule files: `ast-grep --rule rule.yml` for complex patterns with context matching.