import {
	isToolCallEventType,
	type ExtensionAPI,
	type ExtensionContext,
} from "@earendil-works/pi-coding-agent";
import {
	classifyProductionCommand,
	classifyProductionPath,
	isStrictProductionWorktree,
	type ProductionRisk,
} from "./policy.ts";

const BLOCK_REASON = "Production access was not approved";

async function requestApproval(
	ctx: ExtensionContext,
	risk: ProductionRisk,
	detail: string,
): Promise<boolean> {
	if (!ctx.hasUI) return false;

	return ctx.ui.confirm(
		"Production access requested",
		`${risk.reason}\n\n${detail}\n\nAllow this tool call once?`,
	);
}

export default function productionGate(pi: ExtensionAPI) {
	pi.on("session_start", (_event, ctx) => {
		const mode = isStrictProductionWorktree(ctx.cwd) ? "strict" : "targeted";
		ctx.ui.setStatus("production-gate", `production gate: ${mode}`);
	});

	pi.on("session_shutdown", (_event, ctx) => {
		ctx.ui.setStatus("production-gate", undefined);
	});

	pi.on("tool_call", async (event, ctx) => {
		let risk: ProductionRisk | undefined;
		let detail: string | undefined;

		if (isToolCallEventType("bash", event)) {
			risk = classifyProductionCommand(event.input.command, ctx.cwd);
			detail = `Command:\n${event.input.command}`;
		} else if (isToolCallEventType("read", event)) {
			risk = classifyProductionPath(event.input.path, ctx.cwd);
			detail = `Read path:\n${event.input.path}`;
		} else if (isToolCallEventType("write", event)) {
			risk = classifyProductionPath(event.input.path, ctx.cwd);
			detail = `Write path:\n${event.input.path}`;
		} else if (isToolCallEventType("edit", event)) {
			risk = classifyProductionPath(event.input.path, ctx.cwd);
			detail = `Edit path:\n${event.input.path}`;
		} else if (isToolCallEventType("grep", event)) {
			const path = event.input.path ?? ".";
			risk = classifyProductionPath(path, ctx.cwd);
			if (!risk && isStrictProductionWorktree(ctx.cwd)) {
				risk = {
					reason: "Broad search requires approval in the production operations worktree",
					strictWorktree: true,
				};
			}
			detail = `Search path:\n${path}`;
		} else if (isToolCallEventType("find", event)) {
			const path = event.input.path ?? ".";
			risk = classifyProductionPath(path, ctx.cwd);
			if (!risk && isStrictProductionWorktree(ctx.cwd)) {
				risk = {
					reason: "Broad file discovery requires approval in the production operations worktree",
					strictWorktree: true,
				};
			}
			detail = `Find path:\n${path}`;
		} else if (isToolCallEventType("ls", event)) {
			const path = event.input.path ?? ".";
			risk = classifyProductionPath(path, ctx.cwd);
			if (!risk && isStrictProductionWorktree(ctx.cwd)) {
				risk = {
					reason: "Directory listing requires approval in the production operations worktree",
					strictWorktree: true,
				};
			}
			detail = `List path:\n${path}`;
		}

		if (!risk || !detail) return undefined;

		const approved = await requestApproval(ctx, risk, detail);
		if (!approved) {
			if (ctx.hasUI) ctx.ui.notify(BLOCK_REASON, "warning");
			return {
				block: true,
				reason: ctx.hasUI ? BLOCK_REASON : `${BLOCK_REASON} because no approval UI is available`,
			};
		}

		ctx.ui.notify("Production access approved once", "warning");
		return undefined;
	});
}
