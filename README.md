# StellarNet – Roblox Networking Framework w/ Middleware

StellarNet is a production-ready, type-safe Roblox networking framework designed for studios that demand hardened remote pipelines, schema validation, encrypted payloads, and complete observability.

## Features
- **Remote Schema Validation** with per-argument enforcement and rejection logging
- **Type-safe Event Definitions** shared across server and client
- **Middleware Pipeline** (Auth → Permission → Rate Limit → Schema → Sanitization → Handler)
- **Permission Tiers** (User, Mod, Admin, System) with middleware guard
- **Exploit Detection Logging** for schema, rate-limit, permission, and tampering events
- **Metrics Tracking** (RTT, events/sec, errors, rejected payloads, last caller context)
- **Per-Remote Rate Limits** configurable via definitions or runtime overrides
- **Global Abuse Controls** with optional player-wide cap, bypass list, and cooldown after repeated hits
- **Encrypted Payloads** using server-only secret key and XOR stream fallback
- **Debugging Dashboards** (server console commands, in-game client overlay)
- **Clean Module Architecture** with shared utilities and examples
  

## Architecture
```
StellarNet/
  src/
    Shared/        -- Types, signals, utilities, encryption
    Server/        -- Remotes, middleware, permissions, logging, metrics
    Client/        -- Remote wrappers, debugging, network interface
  example/         -- Minimal server/client usage samples
```

Pipeline overview:
`Remote Event -> Encryption -> Middleware (Auth → Permission → Rate Limit → Schema → Sanitization) -> Handler -> Metrics`

## Setup
1. Place the `StellarNet` folder in `ReplicatedStorage` or as a package.
2. Require `StellarNet/src/Server/init.server.lua` from ServerScriptService to bootstrap remotes and middleware.
3. Require `StellarNet/src/Client/init.client.lua` from StarterPlayerScripts to initialize the client interface and debugger.
4. Configure event definitions and handlers in `src/Server/Remotes/EventDefinitions.lua`.

## Defining Events
Create or edit entries in `src/Server/Remotes/EventDefinitions.lua`:
```lua
local PermissionLevels = require(script.Parent.Parent.Permissions.PermissionLevels)

return {
    PlayerMove = {
        Name = "PlayerMove",
        Description = "Broadcasts movement",
        Permission = PermissionLevels.USER,
        RateLimit = {Limit = 30, Window = 60},
        Params = {
            {Name = "Direction", Type = "Vector3"},
            {Name = "Speed", Type = "number"},
        },
        Handler = function(player, direction, speed)
            -- your handling logic
        end,
    },
}
```

- `RateLimit` is optional and accepts `{Limit = number, Window = number}` to override the default token bucket for that remote.

## Middleware
Middleware functions follow `(context, next) -> (bool, string?)`. Register additional middleware in `src/Server/init.server.lua` using `pipeline:Register(fn)`. The default chain:
1. `AuthMiddleware` – verifies the player exists.
2. `PermissionService.Middleware` – enforces permission tier.
3. `RateLimitMiddleware` – token bucket per-player per-remote.
4. `SchemaValidator` – validates payload shape/types.
5. `SanitizationMiddleware` – scrubs strings & truncates.
6. Handler execution.

## Security Notes
- Encryption key is generated server-side and published to clients via `RemoteEncryption`. Replace distribution with a secure channel for production.
- Middleware rejects unknown remotes, invalid schemas, and rate-limit violations while logging exploit attempts.
- Sanitization trims control characters and long payloads.

## Debugging & Metrics
- **Server Console**: chat commands `/stellarnet stats`, `/stellarnet remotes`, `/stellarnet violations` (Mod+ permission required).
- **Server Console Rate Limits**: `/stellarnet limits` shows the default bucket and per-remote overrides.
- **Client Debugger**: on-screen overlay showing received events and RTT traces.
- Metrics snapshots include last caller, peak payload size, and the most recent reject/error reasons for each remote.
- Metrics recorded per-remote: count, avg payload size, avg RTT, errors, rejects. Access via `MetricsService.GetAll()`.
- Rate limit console output now includes global caps, cooldown policy, and bypassed userIds for quick auditing.

## Examples
- Server example: `example/ServerExample.lua`
- Client example: `example/ClientExample.lua`

## License
This project is licensed under the MIT License. See [LICENSE](LICENSE).
