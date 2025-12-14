---
name: ts-cli
description: This skill should be used when creating CLI applications with TypeScript, Effect, and Bun. Use when user asks to build a CLI, command-line tool, or terminal application.
---

# TypeScript CLI with Effect

## Overview

Build CLI applications using Bun runtime, Effect framework (@effect/cli, @effect/platform), and Biome for linting/formatting. This stack provides type-safe command parsing, composable services, and robust error handling.

## Quick Start

To initialize a new CLI project, run the init script:

```bash
~/.claude/skills/ts-cli/scripts/init_ts_cli.sh <project-name>
```

This creates:
- `package.json` with Effect dependencies
- `tsconfig.json` configured for Bun
- `biome.json` with Effect-compatible rules
- `src/` directory structure
- `vendor/effect` cloned for reference
- `.gitignore` updated

## Project Structure

```
project/
├── src/
│   ├── cli.ts              # Entry point
│   ├── errors.ts           # Tagged error types
│   ├── commands/
│   │   ├── index.ts        # Root command
│   │   └── <feature>/      # Feature subcommands
│   ├── services/
│   │   └── <name>.ts       # Service definitions
│   └── schemas/
│       └── <name>.ts       # Schema definitions
├── vendor/effect/          # Effect source for reference
├── package.json
├── tsconfig.json
└── biome.json
```

## Core Patterns

For detailed code patterns, see `references/effect-patterns.md`. Key patterns:

### 1. Service Definition
Services use Context.Tag with interface + implementation + Layer:
```typescript
export interface MyService { readonly doThing: Effect.Effect<Result, MyError> }
export class MyService extends Context.Tag("MyService")<MyService, MyService>() {}
const make = Effect.gen(function* () { /* implementation */ })
export const MyServiceLive = Layer.effect(MyService, make)
```

### 2. Command Composition
Commands use `Command.make` with Options/Args:
```typescript
const myCommand = Command.make("name", { opt: Options.text("opt") }, ({ opt }) =>
  Effect.gen(function* () { /* handler */ })
).pipe(Command.withDescription("..."))
```

### 3. Layer Wiring
Wire layers with dependencies in cli.ts:
```typescript
const ConfigLayer = ConfigLive.pipe(Layer.provide(BunContext.layer))
const ServiceLayer = ServiceLive.pipe(Layer.provide(ConfigLayer))
const MainLayer = Layer.mergeAll(ConfigLayer, ServiceLayer, BunContext.layer)
```

## Dependencies

Required packages:
- `effect` - Core Effect library
- `@effect/cli` - CLI framework
- `@effect/platform` - Platform abstractions
- `@effect/platform-bun` - Bun runtime

## Resources

### scripts/
- `init_ts_cli.sh` - Project scaffolding script

### references/
- `effect-patterns.md` - Detailed code patterns for services, commands, HTTP clients, and schemas
