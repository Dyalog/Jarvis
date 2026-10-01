# Jarvis live demo: SSE + WebSockets + JSON

One `Jarvis` server, running in **JSON mode**, showing three ways to talk to a browser from the same application:

| Channel | Direction | In the demo |
|---|---|---|
| [Server-Sent Events](../../docs/sse.md) | server → client | A **live feed**: `GET /feed` is an event stream. A background thread broadcasts a `tick` event every second with the server time and the current client counts. |
| [WebSockets](../../docs/websockets.md) | two-way | A **shared chat**: the browser opens a WebSocket, sends `{"name":…,"text":…}`, and the server broadcasts a `chat` message to every connected client. |
| JSON | request / response | **Stats on demand**: `POST /stats` returns the current counts and server time, like any ordinary `Jarvis` endpoint. |

The same `Jarvis` also serves the page, so everything is one origin and no CORS set-up is needed.

## Run it

From the repository root:

```
dyalogscript Samples/LiveDemo/start.apls
```

Then open <http://localhost:8080> in one or more browser windows. Stop the server with Ctrl+C.

From an APL session, start from a clear workspace so the relative paths in `jarvisconfig.json` resolve against this folder:

```apl
]load /path/to/Jarvis/Source/Jarvis.dyalog
j←Jarvis.New '/path/to/Jarvis/Samples/LiveDemo/jarvisconfig.json'
j.Start
⍝ … browse to http://localhost:8080 …
j.Stop
```

## What it shows

| In the page | How it's done |
|---|---|
| A feed that updates every second | `Initialize` (the `AppInitFn`) starts `Ticker`, a thread that broadcasts a named `tick` event (with an `id`) to every `/feed` client using `Server.SSEConnections`, `Server.SendSSE` and `Server.FormatSSE`. |
| A welcome line in the feed for each client | `feed` is the SSE endpoint function. `Jarvis` calls it once per client; it sends a plain-text event to that client only, and returns 0 to keep the stream open. It also reads `Last-Event-ID` for a reconnecting browser. |
| Chat shared by every window | The page opens a WebSocket. `WsConnect` (`OnWsUpgradeFn`) records the connection and welcomes it; `WsReceive` (`OnWsReceiveFn`) parses each message and broadcasts a `chat` message to every client with `WsSend`; `WsClose` (`OnWsCloseFn`) forgets a client that leaves. |
| A **Get stats** button | `stats` is an ordinary JSON endpoint: `POST /stats` returns a namespace (sent as JSON) with the SSE and WebSocket client counts, the tick id, and the time. |

## Files

| File | Purpose |
|---|---|
| `LiveDemo.apln` | The `CodeLocation` namespace: `feed` (SSE), the WebSocket hooks, `stats` (JSON), `Initialize`/`Shutdown` (`AppInitFn`/`AppCloseFn`), and the `Ticker` thread. |
| `web/index.html` | The page, served by `HTMLInterface`. Self-contained, no external libraries; server data goes into the page only with `textContent`. |
| `jarvisconfig.json` | Settings. |
| `start.apls` | Loads `../../Source/Jarvis.dyalog` and starts `Jarvis` with `jarvisconfig.json`. |

The settings in `jarvisconfig.json`:

| Setting | Why |
|---|---|
| `"SSEEndpoints": "feed"` | Makes `GET /feed` an event stream, handled by the `feed` function. |
| `"SSEHeartbeatInterval": 15` | `Jarvis` sends a `:` comment every 15 seconds to keep idle streams open. |
| `"EnableWebSockets": 1` | Turns on WebSocket support. |
| `"OnWsUpgradeFn"`, `"OnWsReceiveFn"`, `"OnWsCloseFn"` | The chat hooks: track connections, handle messages, clean up. |
| `"HTMLInterface": "web"` | Serves `web/index.html` at `/`, from the same origin as the feed and the WebSocket. |
| `"IncludeFns": "stats"` | In JSON mode this limits the callable JSON endpoints to `stats`. (SSE endpoints and WebSocket hooks aren't affected.) |
| `"AppInitFn"`, `"AppCloseFn"` | Start and stop the ticker thread with the server. |

## Things to try

- Open two windows: both show the same client counts in the feed, and chat messages appear in both.
- Click **Get stats** while windows are open and watch the counts change.
- Stop and restart the server while a page is open. The feed shows *reconnecting…* and then recovers by itself (the browser's `EventSource` reconnects); the WebSocket shows *closed* (a WebSocket doesn't reconnect on its own — reload the page).
- Watch the raw feed: `curl -N http://localhost:8080/feed`.

## Known limitation

Tick ids restart from 1 when the server restarts, because the counter lives in the workspace. Replaying missed events is out of scope; see the [SSE page](../../docs/sse.md#reconnecting-and-last-event-id).
