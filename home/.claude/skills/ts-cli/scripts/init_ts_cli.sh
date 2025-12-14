#!/bin/bash
set -e

PROJECT_NAME="${1:-my-cli}"

if [ -d "$PROJECT_NAME" ]; then
    echo "Error: Directory '$PROJECT_NAME' already exists"
    exit 1
fi

echo "Creating CLI project: $PROJECT_NAME"

# Create project directory
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Initialize with bun
bun init -y > /dev/null 2>&1

# Create package.json
cat > package.json << 'EOF'
{
  "name": "PROJECT_NAME_PLACEHOLDER",
  "version": "0.1.0",
  "type": "module",
  "private": true,
  "bin": {
    "PROJECT_NAME_PLACEHOLDER": "./src/cli.ts"
  },
  "scripts": {
    "dev": "bun run src/cli.ts",
    "lint": "biome check .",
    "lint:fix": "biome check --write ."
  },
  "dependencies": {
    "@effect/cli": "^0.54.0",
    "@effect/platform": "^0.77.0",
    "@effect/platform-bun": "^0.56.0",
    "effect": "^3.12.0"
  },
  "devDependencies": {
    "@biomejs/biome": "^1.9.0",
    "@types/bun": "latest",
    "typescript": "^5.7.0"
  }
}
EOF
sed -i "s/PROJECT_NAME_PLACEHOLDER/$PROJECT_NAME/g" package.json

# Create tsconfig.json
cat > tsconfig.json << 'EOF'
{
	"compilerOptions": {
		"target": "ESNext",
		"module": "ESNext",
		"moduleResolution": "bundler",
		"strict": true,
		"esModuleInterop": true,
		"skipLibCheck": true,
		"noEmit": true,
		"declaration": true,
		"types": ["bun-types"],
		"paths": {
			"@/*": ["./src/*"]
		}
	},
	"include": ["src"]
}
EOF

# Create biome.json with Effect-compatible rules
cat > biome.json << 'EOF'
{
	"$schema": "https://biomejs.dev/schemas/1.9.0/schema.json",
	"organizeImports": {
		"enabled": true
	},
	"linter": {
		"enabled": true,
		"rules": {
			"recommended": true,
			"suspicious": {
				"noUnsafeDeclarationMerging": "off"
			},
			"style": {
				"noUnusedTemplateLiteral": "off"
			}
		}
	},
	"formatter": {
		"enabled": true,
		"indentStyle": "tab",
		"indentWidth": 2
	},
	"files": {
		"ignore": ["vendor/**", "node_modules/**"]
	}
}
EOF

# Create directory structure
mkdir -p src/{commands,services,schemas}

# Create errors.ts
cat > src/errors.ts << 'EOF'
import { Data } from "effect";

export class AppError extends Data.TaggedError("AppError")<{
	readonly message: string;
	readonly cause?: unknown;
}> {}
EOF

# Create placeholder cli.ts
cat > src/cli.ts << 'EOF'
#!/usr/bin/env bun
import { Command } from "@effect/cli";
import { BunContext, BunRuntime } from "@effect/platform-bun";
import { Effect, Layer } from "effect";

const rootCommand = Command.make("PROJECT_NAME_PLACEHOLDER").pipe(
	Command.withDescription("PROJECT_NAME_PLACEHOLDER CLI"),
);

const cli = Command.run(rootCommand, {
	name: "PROJECT_NAME_PLACEHOLDER",
	version: "0.1.0",
});

Effect.suspend(() => cli(process.argv)).pipe(
	Effect.provide(BunContext.layer),
	BunRuntime.runMain,
);
EOF
sed -i "s/PROJECT_NAME_PLACEHOLDER/$PROJECT_NAME/g" src/cli.ts

# Create placeholder command index
cat > src/commands/index.ts << 'EOF'
// Export your commands here
// Example:
// export { myCommand } from "./my-command.js";
EOF

# Update .gitignore
cat >> .gitignore << 'EOF'

# Vendor
vendor/
EOF

# Clone Effect repo for reference
echo "Cloning Effect repository for reference..."
git clone --depth 1 https://github.com/Effect-TS/effect.git vendor/effect 2>/dev/null || {
    echo "Warning: Could not clone Effect repo. You can do this manually later:"
    echo "  git clone --depth 1 https://github.com/Effect-TS/effect.git vendor/effect"
}

# Install dependencies
echo "Installing dependencies..."
bun install > /dev/null 2>&1

# Clean up bun-generated files
rm -f index.ts README.md 2>/dev/null

# Link globally so CLI is available immediately
echo "Linking CLI globally..."
bun link > /dev/null 2>&1

echo ""
echo "✅ Project '$PROJECT_NAME' created successfully!"
echo ""
echo "The CLI is now available globally as: $PROJECT_NAME"
echo ""
echo "Try it:"
echo "  $PROJECT_NAME --help"
echo ""
echo "Key files:"
echo "  src/cli.ts        - Entry point"
echo "  src/commands/     - Command definitions"
echo "  src/services/     - Service definitions"
echo "  src/schemas/      - Schema definitions"
echo "  vendor/effect/    - Effect source for reference"
