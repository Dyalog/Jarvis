# Server-Sent Events (SSE) support

Status: in progress on branch `SSE` (Jarvis 1.24.0). Last reviewed 2026-09-30 against the working tree
(thirteenth review: the sample in `Samples/SSE` is written and tested; source and tests unchanged since the twelfth).

## 1. Goal

Let a Jarvis application push a stream of events to browsers over plain HTTP, using the
[`text/event-stream`](https://html.spec.whatwg.org/multipage/server-sent-events.html) format consumed by the
JavaScript `EventSource` API. SSE works in both JSON and REST modes, needs no WebSocket support, and reuses Jarvis's
existing CORS, validation and authentication.

## 2. Current state

### 2.1 Done (in `Source/Jarvis.dyalog`)

| Piece | Where | Notes |
|---|---|---|
| Settings | fields | `SSEEndpoints` (comma/space-delimited string, or a vector of names) and `SSEHeartbeatInterval` (seconds, default 30, 0 = off). |
| Endpoint list | `CheckCodeLocation` | `_SSEEndpoints←normalizeEndpoint SSEEndpoints`. The names are added to `_userHookFns`, so they can't also be called as ordinary JSON/REST functions (404). Each name for which `CodeLocation.⎕NC fn` is non-zero is checked with `CheckHookFn(0 1)(1 ¯2)`: monadic or ambivalent, with an explicit, shy or no result. A variable or namespace with an endpoint's name therefore fails `Start` with a clear message, by design (§4.7). |
| `normalizeEndpoint` | private | Splits a string on commas and spaces, or takes a vector of names (from JSON config), then drops leading `/`s, converts `/`→`.`, and removes empties and duplicates. It always returns a vector of names. Produces the same form as `HandleRequest`'s `1↓'.'@('/'∘=)Endpoint` (tested in dyalogscript). |
| `CheckHookFn` | private | Now compares `|` of the `⎕AT` result code, so a shy result counts as a result for **every** hook. Every hook's call site handles a shy result: `⍎`/direct calls use it as a value, and `PostProcess` is called with `1(85⌶)` inside `:Trap 85`. The error message handles a vector of result codes. |
| Routing | `HandleRequest` | `fn←1↓'.'@('/'∘=)ns.Req.Endpoint`. If `fn` is in `_SSEEndpoints`, the request goes to `HandleSSERequest` instead of `RequestHandler`. A `state` flag (0 respond / 1 SSE / 2 removed) skips `Respond`. `Req.Connection` is set from `ns.conx`. Request paths are deliberately **not** passed through `normalizeEndpoint` (§4.1). |
| Request checks | `HandleSSERequest` | CORS, then `GET` only (405), then `Accept` must allow `text/event-stream` (406), then `CheckAuthentication`. A failure falls through to a normal error response. |
| Stream start | `StartSSE(obj req endpoint)` | Sends a raw, close-delimited `200` response with SSE headers (`text/event-stream; charset=utf-8`, `no-cache`, `Connection: close`, `X-Accel-Buffering: no`). Header lines are built with `fmtHeaders req.Response.Headers`, which capitalises names with `firstCaps` (e.g. `x-app-header` → `X-App-Header`). Records the endpoint number in `_connections.index[4;]` (§4.1), sets `IsSSE` on the connection namespace, and sends a `: connected` comment. |
| Endpoint function | `HandleSSERequest` | Optional. If `3=CodeLocation.⎕NC endpoint`, it's called with `0 CodeLocation.(85⌶)endpoint,' ⍵'`, so explicit and shy results are used and no result is allowed. Result 0 or no result keeps the stream open, non-zero closes it, and an error is logged and closes it. |
| Timeouts | `CleanupConnections` | SSE connections are excluded from `ConnectionTimeout` (`0∧.=_connections.index[3 4;]`). This exclusion is redundant today, but harmless (§3 item 2). |
| Header formatting | Jarvis level | `fmtHeaders` and `firstCaps` (lines 2378–2379) sit next to `uc`/`lc`, where both are visible. They're used only by `StartSSE`; `Respond` hands its headers to Conga. |
| `SSEConnections` | public instance | `''` → all SSE connections. Otherwise the argument goes through `normalizeEndpoint` and connections whose endpoint number is in the result are returned (`∊`), so several endpoints can be requested at once. An unknown endpoint → empty. Before `Start`, `{6::1 ⋄ 0⊣_connections}''` detects the unassigned field, and the function returns `''`. After `Stop` or `Reset`, `_connections` is freshly initialised (`init_connections`), so it returns `''` then too. |
| `SendSSE` | public instance | Accepts connection names, connection namespaces (`.conx`) or `Request` instances (`.Connection`). A leading BOM is stripped only when present (`what←{(⎕UCS 65279)≡⊃⍵:1↓⍵ ⋄ ⍵}what`), leaving scalars as scalars. Then an empty payload, or anything that isn't already a valid event (per `IsSSEText`), goes through `FormatSSE` (`FormatSSE⍣((0∊⍴what)∨~IsSSEText what)`), so `SendSSE ''` sends a `:` keep-alive comment. Returns one code per target: the Conga rc, or `¯1` (logged as "non-SSE or closed connection"). Removes a connection on send failure. |
| `init_connections` | private | Creates `_connections` with an empty 4-row `index` and `lastCheck←0`. Builds the namespace in a local `c` and assigns `_connections←c` once, so readers never see it without `index` (§4.3). Called from `Start` (before `LDRC.Srv`), `Stop` (after the server has stopped) and `Reset`. |
| `IsSSEText` | public shared | Returns 1 if the argument is a simple character vector made up of valid SSE lines (`:comment`, `data`, `event`, `id`, `retry: n`) and ending with a blank line. CRLF/CR are accepted. It has no BOM handling of its own, since `SendSSE` strips it first. Tested in `Tests/SSE` (see §3 item 1 for documentation points). |
| `FormatSSE` | public shared | Builds one event from fields (namespace or positional ≤3) and data (text, character scalar, matrix, lines or JSON; `(¯2↑1 1,⍴data)` handles scalars). An empty result becomes a `:` comment (heartbeat). Tested in `Tests/SSE`. |
| Heartbeat | `StartSSEHeartbeat`, `SSEHeartbeat`, `_sseThread` | Started from `Server` (because `RunServer` blocks in thread modes `0`/`1`). Sleeps in ≤1 s slices, sends `FormatSSE ''` to `SSEConnections ''` every interval, traps and logs errors (`'SSEHeartbeat: '`), and exits on `_stop`. `_sseThread` is killed at `Server`'s `Exit:` and in `Reset`. |
| Request additions | `Request` class | `Connection`, `IsSSE`, `AddHeader`. |

### 2.2 Tests (written, passing)

`Tests/SSE/test_SSE.apln` and `Tests/SSE/run.apls` (§5 Phase 2): 23 tests. All pass against the current source (about
18 s). Against the equivalent fix-B copy, they passed three consecutive runs. A mutation check confirmed that the new
controls catch the faults they're meant to (§5 Phase 2).

### 2.3 Sample (written, tested)

`Samples/SSE/`: a live server clock and shared chat, with Jarvis serving the page, the stream and a JSON endpoint
(§5 Phase 3).

### 2.4 Not started

- Documentation (`docs/`) and release notes.

## 3. Issues found in review

Each points to the phase that deals with it. No blocking issues remain.

1. **Documentation points:**
   - On client disconnect with `KillOnDisconnect=0` (the default), a looping endpoint function keeps running until its next `SendSSE` fails. With `KillOnDisconnect←1` its thread is killed at once. Both are confirmed by `test_KillOnDisconnect`. Document this and recommend checking `SendSSE`'s result. → Phase 3.
   - The shy-result change in `CheckHookFn` applies to all hooks, not only SSE endpoints. It's safe (see §2.1), but it is a user-visible relaxation: a shy-result `AppInitFn`, `ValidateRequestFn` and so on was previously rejected. Mention it in the release notes. → Phase 3.
   - A line with an unknown field (e.g. `foo: x`, valid per the SSE spec) makes `IsSSEText` return 0, so `SendSSE` re-wraps the whole text as `data: foo: x`. This conservative behaviour is intended; document it. → Phase 3.
   - `IsSSEText ''` is still 1. That no longer matters for `SendSSE`, which checks `0∊⍴what` itself, but it's worth one line in the `IsSSEText` docs. → Phase 3.
2. **The SSE exclusion in `CleanupConnections` is redundant (informational).** `CleanupConnections` only closes a
   timed-out connection with no `Req` (`timedOut/⍨←{6::1 ⋄ 0=(_connections⍎⍵).⎕NC⊂'Req'}¨timedOut`, line 1020).
   `Respond` removes `Req` when it finishes, but an SSE request never goes through `Respond`, so an SSE connection
   always keeps its `Req`. So the stream would survive `ConnectionTimeout` even without the row-4 test in
   `0∧.=_connections.index[3 4;]`.

   This was found by mutation: removing the row-4 test doesn't make `test_Timeouts` fail, while the test's control
   (an idle keep-alive connection) is closed as expected. Recommendation: keep the exclusion. It states the intent and doesn't depend on `Req`
   being kept, so it would survive a future change such as clearing `Req` after `StartSSE`. Your call; no code change is
   needed either way.

**Verified assumption:** `StartSSE`/`SendSSE` send a raw character vector on a connection that Conga opened in HTTP
mode, bypassing the structured `(status headers body)` form that `Respond` uses. `Tests/SSE` confirms this works
against the current source on Conga 3.6 (Dyalog 20.0, Linux). The raw client receives the headers, the `: connected`
comment, events and heartbeats, byte for byte. This covers HTTP/1.1 and HTTP/1.0 requests, and JSON and REST modes.
The sample was also exercised end to end (same platform) with two more clients:
- `curl -N`
- Node 20's built-in, standards-based `EventSource` (`--experimental-eventsource`). It received the named `tick` and
  `chat` events with the right `lastEventId`. After a server restart, it reconnected by itself about 3 s later,
  sending `Last-Event-ID`.

Still to do: a real browser, and the older Conga versions Jarvis supports.

### 3.1 Resolved since earlier reviews

- Connection registry: `SSEConnections` and endpoint numbers in `index[4;]` (§4.1).
- `SendSSE`:
  - the `_connections.index` lookups are correct;
  - SSE targets are validated, with `¯1` returned and logged otherwise;
  - `Request` instances are accepted;
  - non-event payloads go through `FormatSSE` (via `IsSSEText`).
- Heartbeat: implemented per §4.4, and shutdown and the heartbeat launch both work.
- Endpoint names: `normalizeEndpoint` handles strings and nested vectors, and is used at start-up and in `SSEConnections`.
- Endpoint functions: checked at start-up (monadic or ambivalent, explicit/shy/no result), matching how `HandleSSERequest` calls them.
- `CheckHookFn`: accepts shy results, and its error message handles a vector of result codes.
- `SSEConnections` is public, returns `''` before `Start`, and accepts several endpoints.
- `Req.Connection` is set from `ns.conx`.
- Log wording: the heartbeat label reads `SSEHeartbeat:`, and the `¯1` message says "non-SSE or closed connection".
- BOM: `SendSSE` strips a leading BOM before checking, so a BOM-prefixed event arrives intact.
- The text check is renamed `IsSSEText`, so `IsSSE` now only means "is an SSE connection" (`Req.IsSSE` and the connection-namespace flag).
- Empty payload: `SendSSE ''` goes through `FormatSSE` and sends a `:` keep-alive comment (`(0∊⍴what)∨~IsSSEText what`).
- Stale connections after `Stop`: `Stop` and `Reset` call `init_connections`, so `SSEConnections` returns `''` after the server stops.
- Scalar payloads: the BOM is stripped only when present, so `SendSSE 42` sends `data: 42` and a namespace sends `data: {"a":1}` (confirmed by `test_Payloads`).
- `FormatSSE 'a'`: a character scalar gives `data: a` (confirmed by `test_FormatSSE` and `test_Payloads`).
- `init_connections` assigns `_connections` once, from a local namespace (§4.3).
- Every SSE request failing with a 500: `fmtHeaders` was a private dfn in `Request`, and its `firstCaps` needed a `uc` that `Request` doesn't have. Both were moved to the Jarvis level, and `StartSSE` calls `fmtHeaders req.Response.Headers` (line 1355). Found by the first run of `Tests/SSE`; now covered by `test_Handshake` and most of the suite.

## 4. Design decisions

### 4.1 Connection registry and endpoint names (implemented)

- `_connections.index[4;]` holds the endpoint number: 0 = not SSE, *n* = `_SSEEndpoints[n]`. There's no separate
  registry, so every existing removal path cleans it up automatically, and `0∧.=_connections.index[3 4;]` keeps
  working.
- `_SSEEndpoints` is fixed at start-up, so endpoint numbers stay valid while connections are open.
- **Endpoint names:** configured names (`SSEEndpoints`) and names passed to `SSEConnections` go through
  `normalizeEndpoint`. Request paths don't: `HandleRequest` (and the WebSocket path) keep
  `1↓'.'@('/'∘=)Endpoint`, because a URL path must not be split on commas or spaces. That would change routing
  for every JSON/REST request whose path contains them. The two forms agree for any path without those characters
  (tested for `/a/b`).
- `SSEConnections endpoints` (public instance): `''` → every SSE connection. One or more names (`'events'`,
  `'/events'`, `'events, alerts'`, or a vector of names) → those endpoints' connections.
- The list can be out of date by the time it's used; `SendSSE` re-validates each connection.
- Broadcast pattern: `(SSEConnections 'events') SendSSE 'tick' FormatSSE ⎕TS`.

### 4.2 `SendSSE` argument handling (implemented)

- **Left:** connection name(s), connection namespace(s) (`.conx`), or `Request` instance(s) (`.Connection`).
  Empty → no-op, returns `⍬`.
- **Right:** a leading BOM is stripped, and nothing else about the payload changes. Text that `IsSSEText` recognises as one or more complete events is then sent as is, and `''` becomes a `:` keep-alive comment. Anything else (plain text,
  numbers, namespaces, matrices, vectors of lines) goes through `FormatSSE` first, which guarantees a well-formed
  event. So `conx SendSSE 'hello'` and `conx SendSSE FormatSSE 'hello'` send the same thing.
- **Result:** one code per target, in order. 0 = sent, a Conga error code = send failed (connection removed),
  and `¯1` = not an open SSE connection (logged).
- Each call makes exactly one `LDRC.Send` per connection, so concurrent senders (app threads and heartbeat) never
  interleave within an event.

### 4.3 Thread safety of `_connections.index` (no `:Hold` needed for reads)

Dyalog switches threads only between lines of a defined function, on entry to a dfn/dop, and during waits and
external calls. Every write to `_connections.index` is a single line of primitives:
- the append in `AddConnection`,
- the row-4 assignment in `StartSSE`,
- the compress in `RemoveConnection` and `CleanupConnections`,
- the replacement of `_connections` itself in `init_connections`, a single assignment of a fully built namespace.

A reader that references the index only on a single line of primitives (no calls to defined functions or dfns on
that line) therefore always sees a consistent index without `:Hold '_connections'`. These lines meet this condition:
- `SendSSE`'s validation line.
- Both index-reading lines in `SSEConnections`. The `normalizeEndpoint` call and the guard dfn are on separate lines, and neither reads the index.

**Keep them that way:** splitting such a line, or adding a call to a defined function or dfn inside it,
reintroduces the race.

A connection can still be removed between `SendSSE`'s check and its `LDRC.Send` on the next line. That's
harmless: the send fails, and `RemoveConnection` on an already-removed connection is a no-op.

### 4.4 Heartbeat (implemented)

- `SSEHeartbeatInterval` (seconds; 0 = off) defaults to 30. It's passed to the thread as an argument, so a change
  takes effect on the next start (like `SessionTimeout`/`SessionMonitor`).
- `Server` calls `StartSSEHeartbeat` right after `(_started _stopped)←1 0`. It launches
  `_sseThread←SSEHeartbeat&SSEHeartbeatInterval` when the interval is positive and there are SSE endpoints.
  This can't go in `Start`: `RunServer` doesn't return until shutdown when `DYALOG_JARVIS_THREAD` is `0` or `1`.
- `SSEHeartbeat` sleeps in ≤1 s slices against a deadline, so `Stop` isn't delayed and the interval doesn't
  drift. Errors are trapped and logged so that cleanup of dead connections doesn't silently stop.
- `_sseThread` is killed at `Server`'s `Exit:` (a trapped server error reaches `Exit` without setting `_stop`)
  and in `Reset`.

### 4.5 Connection-namespace `IsSSE` flag (kept by design)

- `StartSSE` sets `IsSSE←1` on the connection namespace, and `AddConnection` initialises it to 0. This mirrors
  `IsWebSocket`.
- It's a convenience for application developers: they can't see `_connections.index`, and reading a flag is
  quicker than looking the connection up. Internally, Jarvis uses `index[4;]` (§4.1); the flag must be kept in step
  with it (both are set together in `StartSSE`, and both disappear with the namespace on removal).
- **Open question:** on the SSE path the developer never receives the connection namespace. The endpoint function
  gets `ns.Req` (which has its own `Req.IsSSE`), and `SSEConnections` returns names. Currently the flag is only
  reachable where a hook is passed the connection namespace (the WebSocket hooks). Decide whether that's enough, or
  whether SSE code should also be able to get the namespace (for example, via a `Req` reference to it, or
  `SSEConnections` returning namespaces on request).

### 4.6 Behaviour carried over from ordinary requests (tested; document)

- These apply to SSE requests:
  - `ValidateRequestFn` (`test_Validate`)
  - CORS (`test_Rejections`)
  - authentication (`test_Rejections`)
  - sessions: the session header is sent with the stream (`test_Sessions`)
- These don't apply:
  - `PostProcessFn` (`test_PostProcess`)
  - response compression (`test_NoCompression`)
- SSE works in both JSON and REST modes (`test_REST`).
- An SSE endpoint can't also be called as a normal JSON/REST endpoint (404). Not yet tested.
- The stream is close-delimited, so it works for HTTP/1.0 and 1.1 (`test_HTTP10`) and ends when either side closes (`test_Disconnect`, `test_EndpointFunction`).
- On reconnect the browser sends `Last-Event-ID`, which the endpoint reads with `req.GetHeader 'last-event-id'` (`test_LastEventID`).

### 4.7 Endpoint names that aren't functions (by design)

- At start-up, `CheckCodeLocation` valence-checks any `CodeLocation` name that matches an endpoint and has a
  non-zero `⎕NC`. A variable or namespace with an endpoint's name therefore fails `Start` with
  "… is not a monadic or ambivalent function".
- At runtime, `HandleSSERequest` calls the endpoint function only when `3=CodeLocation.⎕NC endpoint`.
- The two tests are deliberately different. A clash is reported loudly at start-up, so the runtime test only ever
  sees a function or nothing.

## 5. Implementation phases

### Phase 1 — Correctness (done, apart from one decision)
Sections: §4.5.
- Done: the `fmtHeaders` fix (§3.1). `Tests/SSE` passes against the source with no patching.
- Decide the §4.5 open question: how SSE code gets the connection namespace, if at all.

### Phase 2 — Tests (written and passing: `Tests/SSE/`)
Sections: §4 (all), §3 "Verified assumption".

**Files:**
- `Tests/SSE/test_SSE.apln`: namespace `test_SSE`. `Run` runs every `test_*` function and returns a vector of failure messages (empty = pass).
- `Tests/SSE/run.apls`: shell runner, run as `dyalogscript Tests/SSE/run.apls` from the repository root.
  - It loads `Source/Jarvis.dyalog`, or the copy named by the `JARVIS_SOURCE` environment variable.
  - It uses ports from `JARVIS_TEST_PORT` (default 8191) up.
  - It prints the results, and exits 0 if every test passed, 1 otherwise.

**How it works:**
- **Servers:** every server in a run gets its own port (`BasePort+1`, `BasePort+2`, …), never reused within the run, so one test's server can't receive another's traffic.
  - Servers run in `DYALOG_JARVIS_THREAD←'debug'` mode, so `Start` returns immediately.
  - They use `WaitTimeout←5000`, which `Stop` also uses as its limit.
  - Each is a `TJarvis` subclass whose `Log` override records messages in `Logged`.
- **Clients:** raw Conga clients (Jarvis's own `LDRC`, `Text` mode), so the stream can be read incrementally.
- **Cleanup:** every server and client is closed after each test.
- **Test application:** the `CodeLocation` namespace (`MakeApp`) holds:
  - the endpoint functions (`events`, `alerts`, `closer`, `broken`, `shy`, `nores`, `dyadic`, `a.b`, `killme`, `looper`);
  - the hook functions (`Authenticate`, `CheckRequest`, `AddLowerHeader`, `AfterRequest`);
  - an ordinary JSON endpoint, `echo`, used by the control checks.

**Tests and what they check:**
- `test_Startup`:
  - A missing function is allowed, and `GET /nofn` gives an open stream.
  - Explicit, shy and no-result functions are accepted.
  - A dyadic function is rejected with an "is not a …" message.
  - A variable named like an endpoint fails `Start` (§4.7).
- `test_Shutdown`: `Stop` returns `0 'Server stopped'` in under 5 s, with and without SSE endpoints.
- `test_Handshake`:
  - Status 200, with the `content-type`, `cache-control` and `x-accel-buffering` headers.
  - Raw header names are capitalised: a lower-case `x-app-header` added by a `ValidateRequestFn` arrives as `X-App-Header`.
  - The body is exactly `: connected` + blank line, the stream stays open, and `SSEConnections` lists it.
- `test_Rejections`:
  - `POST` → 405; `Accept: application/json` → 406; no `Accept` → 200.
  - CORS preflight → 204 with `Access-Control-Allow-Origin`; CORS GET → 200 with `Access-Control-Allow-Origin: *`.
  - With `AuthenticateFn`, no token → 401 and no stream, and a valid token → 200.
- `test_EndpointNames`: `events`, `/events`, `a.b`, `/a/b`, `'/events, a/b'` and `'/events' 'a/b'` all route correctly.
- `test_EndpointFunction`:
  - Result 0 keeps the stream open, and the function runs once with `req.IsSSE=1` and `req.Connection` matching `SSEConnections`.
  - Result 1 closes the stream.
  - An error closes it and logs "Error in SSE handler for endpoint broken".
- `test_Sending`:
  - Sends by connection name and by `Request`.
  - Broadcasts to all, to one endpoint (the other client receives nothing), and `SSEConnections` with two endpoints.
- `test_Payloads`: exact bytes on the wire for:
  - a pre-formatted event, text, lines and a matrix;
  - a BOM-prefixed event, `''` and a lone BOM;
  - `42`, a namespace, a numeric vector and a character scalar.
- `test_NonSSETarget`: `SendSSE` to an unknown connection returns `¯1` and logs it.
- `test_Disconnect`: after the client closes, the connection leaves `SSEConnections` within 3 s, and a later `SendSSE` to it is non-zero.
- `test_Heartbeat`:
  - With an interval of 1, a `:` comment arrives within 3 s, and `Stop` with the heartbeat running takes under 5 s.
  - With 0, no data arrives in 2.5 s, and interval 1 starts exactly one more thread than interval 0.
  - The default is 30.
- `test_Timeouts`: with `ConnectionTimeout←1`, the stream survives 3 s and still receives an event. The control, an idle keep-alive `POST /echo` connection, is closed in the same time.
- `test_BeforeAfter`: `SSEConnections ''` is empty before `Start`, after `Stop` and after `Reset`.
- `test_REST`: handshake and an event in REST mode.
- `test_Validate`: a request rejected by `ValidateRequestFn` gets 400 and no stream; an accepted one gets 200.
- `test_PostProcess`: `PostProcessFn` isn't called for an SSE request. The control: it is called for `POST /echo`.
- `test_Sessions`: with `SessionTimeout←1`, the stream opens and carries the session header (`SessionIdHeader`).
- `test_LastEventID`: `req.GetHeader'last-event-id'` returns the value sent.
- `test_HTTP10`: an `HTTP/1.0` request gets an `HTTP/1.0 200` stream that receives events.
- `test_NoCompression`: with `UseZip←1` and `Accept-Encoding: gzip`, the stream has no `Content-Encoding` and stays plain text. The control: `POST /echo` with the same header is compressed.
- `test_KillOnDisconnect`:
  - With `req.KillOnDisconnect←1`, the looping endpoint thread is gone within 3 s of the client closing.
  - With 0, the loop ends when its `SendSSE` fails.
- `test_FormatSSE`, `test_IsSSEText`: unit cases, including namespace and positional fields, a bad `retry`, and line breaks in field values.

**Mutation check** (run on scratchpad copies of the fixed source):

| Fault introduced | Caught by |
|---|---|
| Always start the heartbeat thread | `test_Heartbeat` (thread count), plus several stream tests |
| Don't kill the thread on disconnect when `KillOnDisconnect←1` | `test_KillOnDisconnect` |
| Format headers without `firstCaps` | `test_Handshake` (`X-App-Header`) |
| Remove the SSE exclusion from `CleanupConnections` | nothing: the exclusion is redundant (§3 item 2) |

**Not covered (and why):**
- `SendSSE` by connection namespace: SSE code has no public way to get one (§4.5 open question).
- Heartbeat with `DYALOG_JARVIS_THREAD` `0`/`1`: those modes block in `RunServer` and then `⎕OFF`, so they can't run inside the test process. Test manually.
- `normalizeEndpoint` unit cases: it's private, so it's covered indirectly by `test_EndpointNames`. It was checked directly in dyalogscript during review.
- An SSE endpoint called as an ordinary JSON/REST endpoint returning 404 (§4.6).
- A shy-result `ValidateRequestFn` (or another non-SSE hook): belongs in the general tests.
- The thread-switch window in §4.3: timing-dependent, so it can't be forced reliably.

**Still to do:** a manual check of `Samples/SSE/web/index.html` in Chrome and Firefox (no browser was available). The
`curl -N` and `EventSource` checks are done (§3 "Verified assumption").

### Phase 3 — Sample (done) and documentation

**Sample (written: `Samples/SSE/`).** Run it with `dyalogscript Samples/SSE/start.apls`, then open
<http://localhost:8080>. `Samples/SSE/README.md` covers running it from a session as well.
- **Files:**
  - `SSEDemo.apln`: the `CodeLocation`.
  - `web/index.html`: the page, served by `HTMLInterface`. It has no external libraries, and puts server data into the page only with `textContent`.
  - `jarvisconfig.json`: the settings.
  - `start.apls`: the launcher.
  - `README.md`.
- **What it demonstrates:**
  - `clock`, the SSE endpoint function: it reads `Last-Event-ID` and sends a welcome to just that client with `req Server.SendSSE msg`.
  - `Initialize`/`Shutdown` (`AppInitFn`/`AppCloseFn`) start and stop a `Ticker` thread. The thread broadcasts a named `tick` event, with an `id`, every second using `SSEConnections`/`SendSSE`/`FormatSSE`.
  - `say`, an ordinary JSON endpoint: it broadcasts a named `chat` event to every stream.
  - `SSEHeartbeatInterval` (15 s), and `IncludeFns` limiting the JSON endpoints to `say`.
- **Differences from the original outline:** the sample uses named `tick` and `chat` events rather than `ping`, and
  replaces `events.dyalog`/`events.html` instead of extending them. Those two original files are still in the
  folder; the README calls them "an earlier, minimal client and endpoint, not used by this demo". **Open question:**
  keep them or delete them?
- **Tested:**
  - With `curl`: the page is served intact; the stream sends the connected comment, the welcome, ticks and chat events; `Last-Event-ID` gives "Welcome back".
  - Chat input is trimmed and length-limited; empty text gets `{"error":"text is required"}`.
  - `IncludeFns` makes every internal function 404, and a POST to `/clock` gets 405.
  - With Node's `EventSource`, including an automatic reconnect after a server restart.
  - `Stop` runs `Shutdown`, and the ticker thread ends.
  - The page's JavaScript passes `node --check`.
- **Known limitation (documented in the README):** tick ids restart from 1 when the server restarts, because the
  counter is in the workspace. Replaying missed events is out of scope (§6).

**Documentation (not started):**
- Docs:
  - Settings: add `SSEEndpoints` (both accepted forms) and `SSEHeartbeatInterval` to a settings page (a new `settings-sse.md`, or the operational settings page) and to `mkdocs.yml` nav.
  - `methods-instance.md`: `SendSSE` (including the §4.2 payload rule), `SSEConnections` (including multiple endpoints).
  - `methods-shared.md`: `FormatSSE`, `IsSSEText` (including the unknown-field rule and `IsSSEText ''`, §3 item 1).
  - `request.md`: `Connection`, `IsSSE`, `AddHeader`.
  - The connection namespace's `IsSSE` flag, next to wherever `IsWebSocket` is documented (§4.5).
  - A short concepts section on how SSE requests flow (§4.6) and the disconnect/`KillOnDisconnect` note (§3 item 1).
  - Point to `Samples/SSE` as the worked example.
- `release-notes.md`: a 1.24.0 entry, including shy results now being accepted for all hook functions (§3 item 1).

## 6. Out of scope

- SSE over HTTP/2 (Conga is HTTP/1.x).
- Server-side replay/buffering of missed events for `Last-Event-ID`. That's the application's job; Jarvis only exposes the header.
- Per-connection back-pressure / send queues.

## 7. Decisions log

- 2026-09-29: the heartbeat interval defaults to 30 seconds (§4.4).
- 2026-09-29: SSE connections are tracked by endpoint number in `_connections.index[4;]` rather than a separate registry (§4.1).
- 2026-09-29: the heartbeat setting is named `SSEHeartbeatInterval`, and the thread is started from `Server`, not `Start` (§4.4).
- 2026-09-29: `SendSSE` and `SSEConnections` read `_connections.index` without `:Hold`, relying on thread switches happening only between lines (§4.3).
- 2026-09-30: `SendSSE` sends text that `IsSSEText` recognises as complete events unchanged, and passes everything else through `FormatSSE` (§4.2).
- 2026-09-30: the connection namespace keeps its `IsSSE` flag as a developer convenience, like `IsWebSocket` (§4.5).
- 2026-09-30: configured endpoint names and `SSEConnections` arguments go through `normalizeEndpoint`; request paths keep `1↓'.'@('/'∘=)Endpoint` and are not split (§4.1).
- 2026-09-30: `CheckHookFn` accepts shy results for all hooks (§2.1).
- 2026-09-30: a variable or namespace with an endpoint's name fails `Start` (start-up check `0≠⎕NC`); only functions are called at runtime (`3=⎕NC`). This is intentional (§4.7).
- 2026-09-30: SSE tests live in `Tests/SSE/` and use a raw Conga client and a logging `TJarvis` subclass (§5 Phase 2).
- 2026-09-30: recommended fix for the `fmtHeaders` 500 (now §3.1) is to move `fmtHeaders`/`firstCaps` to the Jarvis level; a public `Request` method alone fails on `uc` (tested).
- 2026-09-30: the `fmtHeaders` fix went in as recommended: `fmtHeaders`/`firstCaps` moved to the Jarvis level (§3.1).
- 2026-09-30: test servers get unique ports within a run; reusing ports across tests caused a flaky "Server seems stuck" from `Stop` (§5 Phase 2).
- 2026-09-30: the SSE sample is `Samples/SSE/` (`SSEDemo.apln` + `web/index.html`), using named `tick` and `chat` events (§5 Phase 3).
