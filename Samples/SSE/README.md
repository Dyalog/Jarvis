# Jarvis Server-Sent Events (SSE) demo

A web page that receives a live server clock and a shared chat from Jarvis over
[Server-Sent Events](https://html.spec.whatwg.org/multipage/server-sent-events.html), using the browser's `EventSource`.
The same Jarvis serves the page, the event stream and an ordinary JSON endpoint.

## Run it

From the repository root:

```
dyalogscript Samples/SSE/start.apls
```

Then open <http://localhost:8080> in one or more browser windows. Stop the server with Ctrl+C.

From an APL session, start from a clear workspace so that the relative paths in `jarvisconfig.json` resolve against
this folder:

```apl
]load /path/to/Jarvis/Source/Jarvis.dyalog
j←Jarvis.New '/path/to/Jarvis/Samples/SSE/jarvisconfig.json'
j.Start
⍝ … browse to http://localhost:8080 …
j.Stop
```

## What it shows

| In the page | How it's done |
|---|---|
| A clock that updates every second | `Initialize` (the `AppInitFn`) starts `Ticker`, a thread that broadcasts a `tick` event to every client with `Server.SSEConnections 'clock'` and `Server.SendSSE`. Each tick has an `id`. |
| A welcome message for each new client | `clock` is the SSE endpoint function. Jarvis calls it once per client, after the stream has started. It sends a plain-text event to that client only (`req Server.SendSSE msg`), and returns 0 to keep the stream open. |
| "Welcome back" after a reconnect | When the connection drops (for example, restart the server), the browser reconnects by itself and sends a `Last-Event-ID` header with the id of the last tick it saw. `clock` reads it with `req.GetHeader 'last-event-id'`. |
| Chat shared by every window | `Send` posts JSON to `/say`, an ordinary Jarvis JSON endpoint. `say` broadcasts the message to every open stream as a `chat` event. |
| An event log | Every event the page receives: its type, id and data. |

## Files

| File | Purpose |
|---|---|
| `SSEDemo.apln` | The `CodeLocation` namespace: `clock` (SSE endpoint), `say` (JSON endpoint), `Initialize`/`Shutdown` (`AppInitFn`/`AppCloseFn`), and the `Ticker` thread. |
| `web/index.html` | The page, served by `HTMLInterface`. It's self-contained, with no external libraries. |
| `jarvisconfig.json` | Settings. |
| `start.apls` | Loads `../../Source/Jarvis.dyalog` and starts Jarvis with `jarvisconfig.json`. |
| `events.html`, `events.dyalog` | An earlier, minimal client and endpoint, not used by this demo. |

The settings in `jarvisconfig.json`:

| Setting | Why |
|---|---|
| `"SSEEndpoints": "clock"` | Makes `GET /clock` an event stream, handled by the `clock` function. |
| `"SSEHeartbeatInterval": 15` | Jarvis sends a `:` comment every 15 seconds, which keeps proxies from closing an idle stream and detects clients that have gone away. Browsers don't pass comments to the page. |
| `"HTMLInterface": "web"` | Serves `web/index.html` at `/`, from the same origin as the stream, so no CORS set-up is needed. |
| `"IncludeFns": "say"` | In JSON mode, every function in `CodeLocation` would otherwise be callable. This allows only `say`. (SSE endpoints and hook functions aren't affected.) |
| `"AppInitFn"`/`"AppCloseFn"` | Start and stop the ticker thread with the server. |

## Things to try

- Open two windows: both show the same client count, and chat messages appear in both.
- Click **Disconnect**, then **Connect**. The client count drops and recovers. A reconnect started by the page itself
  (a new `EventSource`) doesn't send `Last-Event-ID`; only the browser's automatic reconnect does.
- Stop and restart the server while a page is open. The page shows *Reconnecting…*, then reconnects and says
  "Welcome back". Tick ids start again from 1, because the demo keeps its counter in the workspace. A real
  application that wants to replay missed events would keep the ids (and events) somewhere that survives a restart.
- Watch the raw stream: `curl -N http://localhost:8080/clock`, and in another shell
  `curl -X POST -H 'Content-Type: application/json' -d '{"name":"curl","text":"hi"}' http://localhost:8080/say`.
