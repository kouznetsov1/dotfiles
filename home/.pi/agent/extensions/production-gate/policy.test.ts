import { describe, expect, test } from "bun:test";
import { mkdtempSync, mkdirSync, rmSync, symlinkSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import {
	classifyProductionCommand,
	classifyProductionPath,
	isStrictProductionWorktree,
} from "./policy.ts";

const dailyWorktree = "/workspace/ultra-1";
const operationsWorktree = "/workspace/ultra-ops";

describe("production command policy", () => {
	test("allows normal development commands", () => {
		expect(classifyProductionCommand("bun run lint", dailyWorktree)).toBeUndefined();
		expect(classifyProductionCommand("dotenvx run -- bun test", dailyWorktree)).toBeUndefined();
		expect(
			classifyProductionCommand(
				"dotenvx run -f .env-db-readonly -- bun run lookup-user.ts",
				dailyWorktree,
			),
		).toBeUndefined();
	});

	test("gates production environment and key access", () => {
		expect(
			classifyProductionCommand("dotenvx run -f .env.production -- bun run build", dailyWorktree),
		).toBeDefined();
		expect(classifyProductionCommand("cat .env.keys", dailyWorktree)).toBeDefined();
		expect(classifyProductionCommand("cat .env.production; git status", dailyWorktree)).toBeDefined();
		expect(classifyProductionCommand("cat<.env.keys", dailyWorktree)).toBeDefined();
		expect(classifyProductionCommand("echo $DOTENV_PRIVATE_KEY_PRODUCTION", dailyWorktree)).toBeDefined();
	});

	test("gates production scripts", () => {
		expect(classifyProductionCommand("bun run db:studio:prod", dailyWorktree)).toBeDefined();
		expect(classifyProductionCommand("bun run import:ultra:prod", dailyWorktree)).toBeDefined();
	});

	test("gates every shell command in the operations worktree and its descendants", () => {
		expect(isStrictProductionWorktree(operationsWorktree)).toBe(true);
		expect(isStrictProductionWorktree(`${operationsWorktree}/scripts`)).toBe(true);
		expect(classifyProductionCommand("git status", operationsWorktree)).toMatchObject({
			strictWorktree: true,
		});
	});
});

describe("production path policy", () => {
	test("gates protected production files", () => {
		expect(classifyProductionPath(".env.keys", dailyWorktree)).toBeDefined();
		expect(classifyProductionPath("../ultra-2/.env.production", dailyWorktree)).toBeDefined();
	});

	test("allows development and read-only environment files", () => {
		expect(classifyProductionPath(".env", dailyWorktree)).toBeUndefined();
		expect(classifyProductionPath(".env-db-readonly", dailyWorktree)).toBeUndefined();
	});

	test("gates paths into the operations worktree without gating ordinary source reads inside it", () => {
		expect(classifyProductionPath("../ultra-ops/package.json", dailyWorktree)).toMatchObject({
			strictWorktree: true,
		});
		expect(classifyProductionPath("src/index.ts", operationsWorktree)).toBeUndefined();
	});

	test("resolves symlinks before classifying paths", () => {
		const root = mkdtempSync(join(tmpdir(), "pi-production-gate-"));
		const ops = join(root, "ultra-ops");
		const daily = join(root, "ultra-1");
		mkdirSync(ops);
		mkdirSync(daily);
		writeFileSync(join(ops, "package.json"), "{}");
		symlinkSync(join(ops, "package.json"), join(daily, "safe-name.json"));
		symlinkSync(ops, join(daily, "linked-directory"));

		try {
			expect(classifyProductionPath("safe-name.json", daily)).toMatchObject({
				strictWorktree: true,
			});
			expect(classifyProductionPath("linked-directory/new-file.txt", daily)).toMatchObject({
				strictWorktree: true,
			});
		} finally {
			rmSync(root, { recursive: true, force: true });
		}
	});
});
