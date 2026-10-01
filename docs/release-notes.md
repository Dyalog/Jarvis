# Release Notes

## 1.24.0

### Server-Sent Events (SSE)

- New: `Jarvis` can push a stream of events to browsers over plain HTTP, consumed by the JavaScript `EventSource` API. SSE works in both JSON and REST modes and reuses `Jarvis`'s existing CORS, validation, authentication and sessions. See [Using Server-Sent Events](./sse.md).
- New settings: [`SSEEndpoints`](./settings-sse.md#sseendpoints) names the endpoints that serve event streams, and [`SSEHeartbeatInterval`](./settings-sse.md#sseheartbeatinterval) controls the keep-alive heartbeat (default 30 seconds, `0` to disable).
- New instance methods [`SendSSE`](./sse.md#sendsse) (send an event to one or more streams) and [`SSEConnections`](./sse.md#sseconnections) (list open streams), and new shared methods [`FormatSSE`](./sse.md#formatsse) (build an event) and [`IsSSEText`](./sse.md#isssetext).
- The [`Request`](./request.md) object gains [`IsSSE`](./request.md#issse) (true for an SSE request), `Connection` (the Conga connection name) and an `AddHeader` method.
- Shy results are now accepted from every user hook function. Previously a hook such as [`AppInitFn`](./settings-hooks.md#appinitfn) or [`ValidateRequestFn`](./settings-hooks.md#validaterequestfn) that returned a shy result was rejected at start-up; now it is treated as returning a result.

### WebSockets

- The built-in WebSocket message handler (used when [`OnWsReceiveFn`](./settings-websockets.md#onwsreceivefn) is not defined and the HTML interface is enabled) now applies the same restrictions as the HTTP interface: a message's endpoint is run only if it passes [`IncludeFns`](./settings-operational.md#includefns)/[`ExcludeFns`](./settings-operational.md#excludefns) and is not a hook function. Previously any function in [`CodeLocation`](./settings-operational.md#codelocation) was reachable over the built-in handler. A disallowed endpoint now returns `Invalid Endpoint`.
- WebSocket authentication ([`WsAuthenticateFn`](./settings-websockets.md#wsauthenticatefn)) now runs once per connection: after it succeeds the connection is marked authenticated. A failed authentication closes the connection *without* dispatching the message to [`OnWsReceiveFn`](./settings-websockets.md#onwsreceivefn) (previously the message was dispatched before the connection was closed).
- With [`WsAutoUpgrade`](./settings-websockets.md#wsautoupgrade)`←0` and no [`OnWsUpgradeReqFn`](./settings-websockets.md#onwsupgradereqfn), the upgrade is now accepted (previously the connection was left waiting). `OnWsUpgradeReqFn` is now valence-checked at start-up like the other hooks.
- [`OnWsErrorFn`](./settings-websockets.md#onwserrorfn) is now called when an error occurs on a WebSocket.
- Errors from the built-in handler are now reported following [`ErrorInfoLevel`](./settings-operational.md#errorlevelinfo), and WebSocket error events are logged with their detail.
- The `WsTimeout` setting, which had no effect, has been removed.
- New documentation: [Using WebSockets](./websockets.md) and [WebSocket Settings](./settings-websockets.md).
