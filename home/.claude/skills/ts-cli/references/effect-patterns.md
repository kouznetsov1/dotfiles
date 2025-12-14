# Effect CLI Patterns

Detailed code patterns for building CLIs with Effect. Reference the Effect source in `vendor/effect/packages/cli/examples/` for more examples.

## Service Definition Pattern

Services follow: interface → Tag → make → Layer

```typescript
import { Context, Effect, Layer } from "effect";
import { MyError } from "../errors.js";

// 1. Define interface
export interface MyService {
	readonly getData: Effect.Effect<Data, MyError>;
	readonly saveData: (data: Data) => Effect.Effect<void, MyError>;
}

// 2. Create Tag (same name as interface - this is intentional)
export class MyService extends Context.Tag("MyService")<
	MyService,
	MyService
>() {}

// 3. Implement with make
const make = Effect.gen(function* () {
	// Inject dependencies
	const fs = yield* FileSystem.FileSystem;
	const otherService = yield* OtherService;

	const getData: MyService["getData"] = Effect.gen(function* () {
		// implementation
	});

	const saveData: MyService["saveData"] = (data) =>
		Effect.gen(function* () {
			// implementation
		});

	return { getData, saveData } satisfies MyService;
});

// 4. Export Layer
export const MyServiceLive = Layer.effect(MyService, make);
```

## Command Patterns

### Basic Command with Options

```typescript
import { Command, Options } from "@effect/cli";
import { Console, Effect } from "effect";
import { MyService } from "../services/my-service.js";

const maxResults = Options.integer("max").pipe(
	Options.withAlias("n"),
	Options.withDefault(10),
	Options.withDescription("Maximum results"),
);

export const listCommand = Command.make(
	"list",
	{ maxResults },
	({ maxResults }) =>
		Effect.gen(function* () {
			const service = yield* MyService;
			const data = yield* service.getData;
			yield* Console.log(`Found ${data.length} items`);
		}),
).pipe(Command.withDescription("List items"));
```

### Command with Positional Arguments

```typescript
import { Args, Command, Options } from "@effect/cli";

const queryArg = Args.text({ name: "query" }).pipe(
	Args.withDescription("Search query"),
);

const maxResults = Options.integer("max").pipe(
	Options.withDefault(20),
);

export const searchCommand = Command.make(
	"search",
	{ query: queryArg, maxResults },
	({ query, maxResults }) =>
		Effect.gen(function* () {
			// Use query and maxResults
		}),
).pipe(Command.withDescription("Search items"));
```

### Nested Subcommands

```typescript
// commands/feature/index.ts
import { Command } from "@effect/cli";
import { listCommand } from "./list.js";
import { createCommand } from "./create.js";

export const featureCommand = Command.make("feature").pipe(
	Command.withDescription("Feature operations"),
	Command.withSubcommands([listCommand, createCommand]),
);

// commands/index.ts
import { Command } from "@effect/cli";
import { featureCommand } from "./feature/index.js";
import { authCommand } from "./auth/index.js";

export const rootCommand = Command.make("mycli").pipe(
	Command.withDescription("My CLI"),
	Command.withSubcommands([featureCommand, authCommand]),
);
```

## Layer Wiring Pattern

Layers must be wired with proper dependency order:

```typescript
// cli.ts
import { Command } from "@effect/cli";
import { BunContext, BunRuntime } from "@effect/platform-bun";
import { Effect, Layer } from "effect";
import { rootCommand } from "./commands/index.js";
import { ConfigLive } from "./services/config.js";
import { AuthLive } from "./services/auth.js";
import { ApiLive } from "./services/api.js";

// Build dependency tree
// ConfigLive needs FileSystem/Path from BunContext
const ConfigLayer = ConfigLive.pipe(Layer.provide(BunContext.layer));

// AuthLive needs ConfigService
const AuthLayer = AuthLive.pipe(Layer.provide(ConfigLayer));

// ApiLive needs AuthService
const ApiLayer = ApiLive.pipe(Layer.provide(AuthLayer));

// Merge all layers
const MainLayer = Layer.mergeAll(
	ConfigLayer,
	AuthLayer,
	ApiLayer,
	BunContext.layer,
);

const cli = Command.run(rootCommand, {
	name: "mycli",
	version: "0.1.0",
});

Effect.suspend(() => cli(process.argv)).pipe(
	Effect.provide(MainLayer),
	BunRuntime.runMain,
);
```

## HTTP Client Pattern

### Basic API Client

```typescript
import {
	FetchHttpClient,
	HttpClient,
	HttpClientRequest,
	HttpClientResponse,
} from "@effect/platform";
import { Context, Effect, Layer } from "effect";
import { AuthService } from "./auth.js";
import { ApiError } from "../errors.js";
import { ResponseSchema } from "../schemas/api.js";

const API_BASE = "https://api.example.com/v1";

export interface ApiService {
	readonly getData: Effect.Effect<ResponseData, ApiError>;
}

export class ApiService extends Context.Tag("ApiService")<
	ApiService,
	ApiService
>() {}

const make = Effect.gen(function* () {
	const auth = yield* AuthService;
	const httpClient = yield* HttpClient.HttpClient;

	// Helper for authorized requests
	const authorizedRequest = <A>(
		req: HttpClientRequest.HttpClientRequest,
		decoder: (res: HttpClientResponse.HttpClientResponse) => Effect.Effect<A, unknown>,
	) =>
		Effect.gen(function* () {
			const token = yield* auth.getAccessToken;
			const authedReq = HttpClientRequest.bearerToken(req, token);
			const response = yield* httpClient.execute(authedReq);
			return yield* decoder(response);
		}).pipe(
			Effect.scoped,
			Effect.mapError((e) => new ApiError({ message: "API request failed", cause: e })),
		);

	const getData: ApiService["getData"] = authorizedRequest(
		HttpClientRequest.get(`${API_BASE}/data`),
		HttpClientResponse.schemaBodyJson(ResponseSchema),
	);

	return { getData } satisfies ApiService;
});

export const ApiLive = Layer.effect(ApiService, make).pipe(
	Layer.provide(FetchHttpClient.layer),
);
```

### POST with Form Data

```typescript
const body = new URLSearchParams({
	grant_type: "authorization_code",
	code: authCode,
	redirect_uri: REDIRECT_URI,
});

const req = HttpClientRequest.post(TOKEN_URL).pipe(
	HttpClientRequest.bodyText(
		body.toString(),
		"application/x-www-form-urlencoded",
	),
);

const response = yield* httpClient.execute(req).pipe(Effect.scoped);
const data = yield* HttpClientResponse.schemaBodyJson(TokenSchema)(response);
```

## Schema Patterns

### Basic Schema with Class

```typescript
import { Schema } from "effect";

export class User extends Schema.Class<User>("User")({
	id: Schema.String,
	name: Schema.String,
	email: Schema.String,
	createdAt: Schema.optionalWith(Schema.String, { as: "Option" }),
}) {}
```

### Nested Schema with Optional Fields

```typescript
import { Schema } from "effect";

export class Address extends Schema.Class<Address>("Address")({
	street: Schema.String,
	city: Schema.String,
	zip: Schema.optionalWith(Schema.String, { as: "Option" }),
}) {}

export class UserWithAddress extends Schema.Class<UserWithAddress>("UserWithAddress")({
	id: Schema.String,
	name: Schema.String,
	address: Schema.optionalWith(Address, { as: "Option" }),
}) {}
```

### Recursive Schema (e.g., tree structures)

```typescript
export class TreeNode extends Schema.Class<TreeNode>("TreeNode")({
	value: Schema.String,
	children: Schema.optionalWith(
		Schema.Array(Schema.suspend((): Schema.Schema<TreeNode> => TreeNode)),
		{ as: "Option" },
	),
}) {}
```

## Error Handling Pattern

### Tagged Errors

```typescript
import { Data } from "effect";

export class AuthError extends Data.TaggedError("AuthError")<{
	readonly message: string;
	readonly cause?: unknown;
}> {}

export class ApiError extends Data.TaggedError("ApiError")<{
	readonly message: string;
	readonly code?: number;
	readonly cause?: unknown;
}> {}

export class ConfigError extends Data.TaggedError("ConfigError")<{
	readonly message: string;
	readonly cause?: unknown;
}> {}
```

### Error Mapping

```typescript
const result = yield* someEffect.pipe(
	Effect.mapError((e) =>
		e instanceof MyError ? e : new MyError({ message: "Operation failed", cause: e }),
	),
);
```

## File System Pattern

```typescript
import { FileSystem, Path } from "@effect/platform";
import { Effect, Option } from "effect";

const make = Effect.gen(function* () {
	const fs = yield* FileSystem.FileSystem;
	const path = yield* Path.Path;

	const configDir = path.join(process.env.HOME!, ".config/myapp");
	const configFile = path.join(configDir, "config.json");

	const readConfig = Effect.gen(function* () {
		const exists = yield* fs.exists(configFile);
		if (!exists) return Option.none();
		const content = yield* fs.readFileString(configFile);
		return Option.some(JSON.parse(content));
	});

	const writeConfig = (data: unknown) =>
		Effect.gen(function* () {
			yield* fs.makeDirectory(configDir, { recursive: true });
			yield* fs.writeFileString(configFile, JSON.stringify(data, null, 2));
		});

	return { readConfig, writeConfig };
});
```

## Options Reference

Common Option builders:

```typescript
import { Options } from "@effect/cli";

// Text option
Options.text("name").pipe(
	Options.withAlias("n"),
	Options.withDescription("User name"),
	Options.withDefault("anonymous"),
);

// Integer option
Options.integer("count").pipe(Options.withDefault(10));

// Boolean flag
Options.boolean("verbose").pipe(Options.withAlias("v"));

// Optional
Options.text("optional").pipe(Options.optional);

// File path
Options.file("config").pipe(Options.withDescription("Config file path"));

// Choice
Options.choice("format", ["json", "csv", "xml"]).pipe(
	Options.withDefault("json"),
);
```

## Args Reference

Common Arg builders:

```typescript
import { Args } from "@effect/cli";

// Required text arg
Args.text({ name: "query" }).pipe(Args.withDescription("Search query"));

// Optional arg
Args.text({ name: "file" }).pipe(Args.optional);

// Repeated args
Args.text({ name: "files" }).pipe(Args.repeated);

// File arg
Args.file({ name: "input" }).pipe(Args.withDescription("Input file"));
```
