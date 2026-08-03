import { realpathSync } from "node:fs";
import { basename, dirname, resolve, sep } from "node:path";

export type ProductionRisk = {
	reason: string;
	strictWorktree: boolean;
};

const DEFAULT_STRICT_WORKTREE_NAMES = ["ultra-ops"];
const PROTECTED_FILE_NAMES = new Set([".env.keys", ".env.production"]);

const PRODUCTION_COMMAND_PATTERNS: Array<{ pattern: RegExp; reason: string }> = [
	{
		pattern: /\.env\.keys/i,
		reason: "Command references .env.keys",
	},
	{
		pattern: /\.env\.production/i,
		reason: "Command references .env.production",
	},
	{
		pattern: /\bDOTENV_PRIVATE_KEY(?:_PRODUCTION)?\b/i,
		reason: "Command references a dotenvx private key",
	},
	{
		pattern: /\bdotenvx\s+(?:decrypt|keypair)\b/i,
		reason: "Command can decrypt or manage environment keys",
	},
	{
		pattern: /\b[\w:-]+:prod\b/i,
		reason: "Command invokes a production script",
	},
	{
		pattern: /\b(?:ultra-ops)(?:\/|\b)/i,
		reason: "Command accesses the operations worktree",
	},
];

function strictWorktreeNames(): string[] {
	const configured = process.env.PI_PRODUCTION_WORKTREE_NAMES;
	if (!configured) return DEFAULT_STRICT_WORKTREE_NAMES;

	const names = configured
		.split(",")
		.map((name) => name.trim())
		.filter(Boolean);

	return names.length > 0 ? names : DEFAULT_STRICT_WORKTREE_NAMES;
}

function pathSegments(path: string): string[] {
	return path.split(sep).filter(Boolean);
}

function canonicalPath(path: string): string {
	let existingPath = resolve(path);
	const missingSegments: string[] = [];

	while (true) {
		try {
			return resolve(realpathSync(existingPath), ...missingSegments.reverse());
		} catch {
			const parent = dirname(existingPath);
			if (parent === existingPath) return resolve(path);
			missingSegments.push(basename(existingPath));
			existingPath = parent;
		}
	}
}

function resolvedPaths(path: string): string[] {
	const lexicalPath = resolve(path);
	return [lexicalPath, canonicalPath(lexicalPath)];
}

export function isStrictProductionWorktree(cwd: string): boolean {
	const names = strictWorktreeNames();
	return resolvedPaths(cwd).some((path) => pathSegments(path).some((segment) => names.includes(segment)));
}

export function classifyProductionCommand(command: string, cwd: string): ProductionRisk | undefined {
	if (isStrictProductionWorktree(cwd)) {
		return {
			reason: "Every agent shell command requires approval in the production operations worktree",
			strictWorktree: true,
		};
	}

	for (const candidate of PRODUCTION_COMMAND_PATTERNS) {
		if (candidate.pattern.test(command)) {
			return { reason: candidate.reason, strictWorktree: false };
		}
	}

	return undefined;
}

export function classifyProductionPath(path: string, cwd: string): ProductionRisk | undefined {
	const normalizedInput = path.startsWith("@") ? path.slice(1) : path;
	const absolutePath = resolve(cwd, normalizedInput);
	const candidates = resolvedPaths(absolutePath);

	for (const candidate of candidates) {
		const segments = pathSegments(candidate);
		const protectedName = segments.find((segment) => PROTECTED_FILE_NAMES.has(segment));

		if (protectedName) {
			return {
				reason: `Tool accesses protected production file ${protectedName}`,
				strictWorktree: isStrictProductionWorktree(cwd),
			};
		}

		const strictName = strictWorktreeNames().find((name) => segments.includes(name));
		if (strictName && !isStrictProductionWorktree(cwd)) {
			return {
				reason: `Tool accesses production operations worktree ${strictName}`,
				strictWorktree: true,
			};
		}
	}

	return undefined;
}
