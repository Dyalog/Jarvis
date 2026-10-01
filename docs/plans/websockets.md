# WebSocket support: review and fixes

Status: in progress. Reviewed 2026-10-01 (second review) against the working tree — `Source/Jarvis.dyalog` with
uncommitted changes on top of commit `bf92df7` (branch `SSE`, Jarvis 1.24.0). Since the first review (against `1c34a50`)
Brian has already fixed most of the Phase 1 issues in the working tree; this review records what's resolved, what
remains, and one new finding. Line numbers refer to the current working tree.

## 1. Scope

Jarvis's WebSocket support has these parts:

- **Settings** (line 60 on): `EnableWebSockets`, `WsAutoUpgrade`, and the hooks `OnWsUpgradeFn`, `OnWsUpgradeReqFn`,
  `OnWsReceiveFn`, `OnWsCloseFn`, `OnWsErrorFn` and `WsAuthenticateFn`. (`WsTimeout` has been removed — see §3.4.)
- **Hook checks** in `CheckCodeLocation` (around lines 743–750).
- **Server set-up:** the Conga `Options`, or `WSFeatures` for older Conga (lines 802, 819).
- **Event dispatch** in `Server` (line 898 on).
- **`HandleWsRequest`** (line 1187 on).
- **`WsSend`** (line 1302 on).
- **The built-in HTML page:** the WebSocket part of `HtmlPage` (line 2823 on). Note a new `HtmlPageOld` also exists
  (line 2731), presumably the previous version kept for reference.

There is still no WebSocket documentation in `docs/`, and no WebSocket test in `Tests/`.

## 2. How it works today

- **Upgrade.** With `WsAutoUpgrade←1` (the default), Conga completes the upgrade and reports `WSUpgrade`.
  `HandleWsRequest` then marks the connection in `_connections.index[3;]`, fills in the connection namespace
  (`IsWebSocket`, `IsAuthenticated←0`, `Headers`, `PeerAddr`, `PeerCert`, `Server`, …), calls `OnWsUpgradeFn ns`, and
  closes the connection if the result is non-zero. With `WsAutoUpgrade←0`, Conga reports `WSUpgradeReq`;
  `OnWsUpgradeReqFn ns` decides whether to accept, and Jarvis accepts with `SetProp 'WSAccept'`.
- **Messages.** Each `WSReceive` creates a child namespace `t<thread>` of the connection namespace, holding `Payload`,
  `Complete` and `DataType`.
  - If `OnWsReceiveFn` is set, Jarvis authenticates (unless `ns.IsAuthenticated`) and, only on success, calls
    `OnWsReceiveFn ref`. A non-zero result, or a failed authentication, closes the connection.
  - If it is not set, and `HTMLInterface` is `1` or `¯1`, a **built-in handler** parses the message as JSON
    (`{"Endpoint":…,"Payload":…}`), checks the function with `CheckFunctionName`, runs it in `CodeLocation`, and sends
    the result (or an error) back as JSON. This is what the built-in HTML page's "Send via WebSocket" button uses.
- **Close.** `WSClose` calls `OnWsCloseFn ns`, then removes the connection. `WSError` logs (with detail) and removes it.
- **Sending.** `WsSend` accepts connection names or connection namespaces, and a payload that is either a namespace
  (sent as JSON) or any other array (sent as is).

## 3. Issues

Severity is my own estimate. "Verified" means I reproduced it against the source with a Conga WebSocket client on
Dyalog 20.0 / Conga 3.6 (Linux); "read" means I found it by reading the code only. §3.1, §3.3, §3.4 and §3.6 were open
in the first review and are now **resolved** in the working tree; they're kept here for the record.

### 3.1 Built-in WebSocket handler ignored `IncludeFns`/`ExcludeFns` — RESOLVED

Was (high; verified): the built-in `WSReceive` handler ran `payload.Endpoint` with no `CheckFunctionName`, so functions
excluded from the HTTP API (including hook functions) were reachable over WebSockets.

Now: the handler calls `:If 404=CheckFunctionName fn` (line 1243) and returns `'Invalid Endpoint: "…"'` instead of
running the function. `CheckFunctionName` applies `_includeRegex`/`_excludeRegex` and rejects `_userHookFns`, so the
built-in handler now honours the same restrictions as the HTTP path. Covered by `test_BuiltinHandler` (§3.8).

### 3.2 Built-in handler runs when the HTML interface is only defaulted on (low; verified — decision)

Still present: the built-in handler runs when `OnWsReceiveFn` is empty and `1 ¯1∊⍨⊃HTMLInterface` (line 1238), and
`HTMLInterface` defaults to `¯1` (on for the JSON paradigm). So a JSON service that enables WebSockets without setting
`OnWsReceiveFn` still gets the built-in handler.

With §3.1 fixed, this is no longer an exposure: only `IncludeFns`-permitted, non-hook functions are reachable, exactly
as over HTTP. It's now a design choice, not a vulnerability, so the severity drops to low.

**Decision (2026-10-01): leave as is.** The built-in handler mirrors the HTTP surface and is handy for the built-in
page. No code change; just document the behaviour — that enabling WebSockets without `OnWsReceiveFn` activates the
built-in handler (in JSON mode), and that it honours `IncludeFns`/`ExcludeFns` like the HTTP path (§3.7).

### 3.3 `WsAuthenticate` was dispatched past on failure — RESOLVED

Was (medium; read): on auth failure the connection was removed but `OnWsReceiveFn ref` still ran on the same pass.

Now: the branch is restructured (lines 1268–1285) so `OnWsReceiveFn ref` is called only when `ns.IsAuthenticated`, or
when `WsAuthenticate ns` returns 0. On failure it logs and `RemoveConnection`s without dispatching. **See §3.9** for a
follow-on bug in the same block.

### 3.4 `WsTimeout` was unused — RESOLVED (removed)

Was (medium; read): `WsTimeout` was declared and documented but never referenced; WebSocket connections are excluded
from `CleanupConnections` (the `index[3;]` test at line 1016), so it had no effect.

Now: the `WsTimeout` field has been removed. WebSocket connections are still never idle-timed-out, which is a reasonable
default for WebSockets (the application and Conga manage liveness). Worth one line in the docs (§3.7). If a
WebSocket-specific idle timeout is wanted later, it's a new feature, not a fix.

### 3.5 `WsAutoUpgrade←0` manual upgrade — CONFIRMED WORKING (with one documentation gotcha)

The misleading comment ("for now, this will always be 1…") is gone; the field now reads "automatically accept WebSocket
upgrades?" (line 62). The manual-upgrade path (`WsAutoUpgrade←0` → `WSUpgradeReq` → `OnWsUpgradeReqFn` → `WSAccept`) is
complete and works.

Verified 2026-10-01 with a Conga WebSocket client (Dyalog 20.0 / Conga 3.6, Linux), `WsAutoUpgrade←0`:
- `OnWsUpgradeReqFn` returns 0 → Jarvis calls `SetProp 'WSAccept'` (line 1227) and the client receives the `WSUpgrade`
  event; a following message is dispatched to `OnWsReceiveFn` on that connection (the handler received the payload).
- `OnWsUpgradeReqFn` returns non-zero → `RemoveConnection`; the client's connection is `Closed`, no upgrade.
- **No `OnWsUpgradeReqFn`** → the connection is accepted. Brian added an `:Else → SetProp 'WSAccept'` branch (line 1230),
  so an empty hook now means "accept every upgrade". Verified: the client receives `WSUpgrade`. (Earlier this hung; that
  gotcha is resolved.)

Also fixed in the working tree: `OnWsUpgradeReqFn` is now valence-checked at start-up
(`CheckHookFn 1(1 ¯2)0`, line 749) alongside the other WebSocket hooks; it was previously the one hook left unchecked.

**Still to do (small):** document the three cases above (§3.7) — in particular that an empty `OnWsUpgradeReqFn` with
`WsAutoUpgrade←0` accepts all upgrades, i.e. behaves like `WsAutoUpgrade←1` except the event is `WSUpgradeReq`.

### 3.6 Error handling and messages — RESOLVED

Was (low; read): the built-in handler returned the raw APL error; `WSError` logged no detail; a no-result endpoint
replied `"No result"`.

Now:
- Built-in-handler errors go through `ErrorInfo` (`'WSReceive Error: ',ErrorInfo`, line 1262), so they respect
  `ErrorInfoLevel`, like the HTTP side.
- `WSError` logs the event detail (`…,': ',∊⍕data`, line 1294).
- A no-result endpoint now sets `resp←''` (line 1256). Minor leftover: that empty result is still sent as
  `WsSend JSONout ''`, i.e. the client receives `""`. If silence is preferred for a no-result endpoint, skip the send
  when `resp` is empty — a small §3.9-adjacent tidy, not a correctness issue.

### 3.7 Documentation — RESOLVED

Was (medium; read): no WebSocket page in `docs/`, nothing in `mkdocs.yml`; the settings existed only as field comments.

Now: written —
- `docs/settings-websockets.md`: `EnableWebSockets`, `WsAutoUpgrade`, the hooks (`OnWsUpgradeFn`, `OnWsUpgradeReqFn`,
  `OnWsReceiveFn`, `OnWsCloseFn`, `OnWsErrorFn`) and `WsAuthenticateFn`.
- `docs/websockets.md` (Advanced Topics, "Using WebSockets"): the connection lifecycle (upgrade/receive/close/error),
  the connection namespace, the message namespace, `WsSend`, the two message modes with the built-in handler's
  `IncludeFns`/hook restrictions (§3.1/§3.2), authentication (§3.9), that connections aren't idle-timed-out (§3.4), and
  the `WsAutoUpgrade` options (§3.5).
- Both added to `mkdocs.yml` (Settings, after SSE; Advanced Topics, after Server-Sent Events) and to
  `settings-overview.md`. A `release-notes.md` 1.24.0 entry covers the behaviour changes. All internal links checked.

### 3.10 `OnWsErrorFn` was declared but never called — RESOLVED

Was (medium; read): `OnWsErrorFn` was a public field, added to `_userHookFns` and valence-checked at start-up, but the
`WSError` handler only logged and `RemoveConnection`d — it never called `OnWsErrorFn`, so the hook had no effect (the
same shape of gap as the old `WsTimeout`).

Now: the `WSError` case calls `OnWsErrorFn` (mirroring `OnWsCloseFn`) before logging and removing the connection. The
docs describe it as a working hook. **To do:** a test, once the raw Conga client can be made to produce a WebSocket
error (may be browser/manual, like `OnWsCloseFn` — §Phase 3 "Not covered").

### 3.8 Tests — RESOLVED

Was (medium; read): `Tests/` had no WebSocket coverage, so the §3.1/§3.3/§3.9 fixes had nothing guarding them.

Now: `Tests/WebSockets/` is written (committed `cb5ec37`) — 9 tests, passing 25/25 consecutive runs, modelled on
`Tests/SSE/` (raw Conga client upgraded with `Clt … ('Options' 1)` then `SetProp 'WSUpgrade'`, a logging `TJarvis`
subclass, one port per server). A mutation check confirms the suite catches reverting §3.1, §3.3 and §3.9. See
**Phase 3** for the test list, the mutation table, and the one gap left to manual/browser testing (`OnWsCloseFn`).

### 3.9 `IsAuthenticated` was never set to 1 — RESOLVED

Was (medium; verified): `ns.IsAuthenticated` was initialised to 0 at upgrade and never assigned 1, so the
`:If ns.IsAuthenticated` true-path was dead code and `WsAuthenticate ns` ran for every incoming message, not just the
first.

Now: `ns.IsAuthenticated←1` is set after a successful `WsAuthenticate` (line 1275), so a connection authenticates once
and later messages take the cached branch (line 1269). This matches the comment's intent. Covered by
`test_Authentication`, which confirms `WsAuthenticateFn` runs once per connection, not once per message (§3.8).

## 4. Smaller observations (not necessarily issues)

- `WsSend` accepts a namespace or a "variable" and silently logs/returns `⍬` for anything else; its result convention
  (one Conga rc per target, no `¯1` for a closed/dead connection as `SendSSE` has) differs from `SendSSE`. Worth
  aligning once the SSE API is settled, so applications see one pattern (see §6).
- On `WSUpgrade`/`WSUpgradeReq` the connection namespace fields are set directly; all the WebSocket hook functions are
  now valence-checked at start-up (lines 745–749, including `OnWsUpgradeReqFn` as of this review), consistent with the
  rest of Jarvis.
- The SSE work relaxed `CheckHookFn` to accept shy results for all hooks, which includes the WebSocket hooks; no action
  needed, just noting it.

## 5. Proposed phases

### Phase 1 — Correctness (mostly done)
- §3.1 built-in-handler `CheckFunctionName`: **done**, tested (§Phase 3).
- §3.3 don't dispatch on auth failure: **done** (but see §3.9).
- §3.4 remove `WsTimeout`: **done**.
- §3.6 error messages: **done** (optional: skip the send on empty result).
- §3.9 `IsAuthenticated` set to 1 after successful auth: **done**, tested (§Phase 3).
- §3.2 built-in-handler trigger: **decided** — leave as is, document the behaviour (no code change).

Phase 1 correctness is complete in the working tree and covered by the tests (Phase 3). What remains is docs (Phase 4).

### Phase 2 — Settings and intent
- §3.5 `WsAutoUpgrade←0` manual upgrade: **confirmed working**, including the empty-`OnWsUpgradeReqFn` case (now accepts
  all upgrades) and the start-up valence check. Remaining: document the three cases.

### Phase 3 — Tests (written and passing: `Tests/WebSockets/`)
`Tests/WebSockets/test_WebSockets.apln` and `run.apls`, modelled on `Tests/SSE/` (raw Conga client that it upgrades to a
WebSocket with `Clt … ('Options' 1)` then `SetProp 'WSUpgrade'`; a logging `TJarvis` subclass; one port per server).
`Run` runs every `test_*` and returns a vector of failure messages. 9 tests, all passing; ran 25 consecutive times
with no failures (the flaky cases were fixed — see below).

Tests:
- `test_Shutdown`: Start then Stop returns `0 'Server stopped'` promptly with WebSockets enabled.
- `test_Startup`: a dyadic `OnWsReceiveFn` and a dyadic `OnWsUpgradeReqFn` are both rejected at start-up; valid monadic
  hooks are accepted; with `EnableWebSockets←0` the hooks aren't valence-checked.
- `test_UpgradeAuto`: `WsAutoUpgrade←1` — the client gets `WSUpgrade` and `OnWsUpgradeFn` runs with the connection
  namespace; `OnWsUpgradeFn` returning non-zero closes the connection.
- `test_UpgradeManual`: `WsAutoUpgrade←0` — `OnWsUpgradeReqFn→0` accepts, `→non-zero` rejects, and an empty
  `OnWsUpgradeReqFn` accepts all (§3.5).
- `test_Receive`: a message is dispatched to `OnWsReceiveFn`, which can reply (`ack:…`); a non-zero result closes the
  connection.
- `test_Authentication`: a failed `WsAuthenticate` closes without dispatching (§3.3); a successful one authenticates
  once per connection, not per message (§3.9, three messages → one `WsAuthenticate` call).
- `test_BuiltinHandler`: with no `OnWsReceiveFn` and the HTML interface on, a permitted endpoint runs; a function outside
  `IncludeFns` and a hook function are both rejected with `Invalid Endpoint` (§3.1); malformed input gives
  `WSReceive Error` via `ErrorInfo` (§3.6).
- `test_WsSend`: `WsSend` by connection name and by connection namespace both reach the client; to a missing connection
  it returns non-zero and logs.
- `test_Disconnect`: after the client drops, the server removes the connection (the captured connection becomes
  unsendable).

**Mutation check** (reverting a fix in a scratchpad copy of the source, then running the suite):

| Fault introduced | Caught by |
|---|---|
| Built-in handler skips `CheckFunctionName` (revert §3.1) | `test_BuiltinHandler` (`secret` and `Init` reach the endpoint) |
| `IsAuthenticated` never cached (revert §3.9) | `test_Authentication` (`WsAuthenticate` runs 3× not 1×) |
| Dispatch even when auth fails (revert §3.3) | `test_Authentication` (failed auth still dispatches) |

**Design notes / robustness** (so the suite stays reliable):
- The built-in handler replies from a per-message **task thread**, so a reply can arrive a frame late. The built-in
  handler test therefore uses a **fresh connection per message** (`OneShot`), and all reads loop until a frame arrives
  (`WsReadData`) rather than reading exactly once.
- A raw Conga client's close isn't reported to the client reliably as one event, so **close is detected server-side**:
  after the connection should be gone, a `WsSend` to the captured connection returns non-zero. (`WaitFor` polls this.)
- Built-in-handler replies are JSON, so the rejection text on the wire is `Invalid Endpoint: \"secret\"` (escaped);
  the tests match on the substrings `Invalid Endpoint` and the name, not the literal quoted form.

**Not covered (and why):**
- `OnWsCloseFn`: it fires on a WebSocket **close handshake** (`WSClose`), which a browser's `ws.close()` sends but the
  raw Conga test client does not (a raw drop arrives as `Closed` → `RemoveConnection`, no `WSClose`). Test manually in a
  browser. `test_Disconnect` covers the `Closed`→cleanup path instead.
- A real browser WebSocket client, and the older Conga versions Jarvis supports.

### Phase 4 — Documentation (written)
- `docs/websockets.md` (concepts/usage) and `docs/settings-websockets.md` (settings), both in `mkdocs.yml` and
  `settings-overview.md`, in the style of the SSE pages (§3.7).
- `docs/release-notes.md`: a 1.24.0 entry covering the behaviour changes (built-in handler honours `IncludeFns`; auth
  no longer dispatches on failure and runs once per connection; `WsAutoUpgrade←0` with no hook accepts; `OnWsErrorFn`
  now called; `WsTimeout` removed).

## 6. Open questions

- Should `WsSend`'s result convention be aligned with `SendSSE`?
- `WsTimeout` is gone: do we want a WebSocket idle timeout at all, or rely on the application/Conga?

## 7. Decisions log

- 2026-10-01: created this plan from a read of the WebSocket code at `1c34a50`, plus a Conga WebSocket client check that
  confirmed the original §3.1 and §3.2.
- 2026-10-01 (second review, working tree over `bf92df7`): recorded Brian's fixes — §3.1 (`CheckFunctionName` in the
  built-in handler), §3.3 (no dispatch on auth failure), §3.4 (`WsTimeout` removed), §3.6 (errors via `ErrorInfo`,
  `WSError` detail, empty no-result) — all verified against the current source. Downgraded §3.2 to a documentation
  decision now that §3.1 bounds it. Added §3.9: `IsAuthenticated` is never set to 1, so `WsAuthenticate` runs on every
  message and the caching branch is dead code. Nothing in Phases 3–4 started.
- 2026-10-01: §3.9 fixed in the working tree — `ns.IsAuthenticated←1` after a successful `WsAuthenticate` (line 1275),
  verified. Phase 1 correctness is now complete; remaining work is the §3.2 decision, tests and docs.
- 2026-10-01: §3.2 decided — leave the built-in handler as is (active under the defaulted HTML interface in JSON mode);
  no code change, document the behaviour. Now that §3.1 bounds it to the HTTP surface, it's a design choice.
- 2026-10-01: §3.5 confirmed with a Conga WebSocket client — `WsAutoUpgrade←0` + `OnWsUpgradeReqFn` works (accept on 0,
  reject on non-zero, and `WSReceive` dispatches on the manually-upgraded connection). Found one gotcha: `WsAutoUpgrade←0`
  with no `OnWsUpgradeReqFn` never accepts the upgrade (client hangs). To be documented; optional start-up check.
- 2026-10-01: §3.5 gotcha resolved — an empty `OnWsUpgradeReqFn` with `WsAutoUpgrade←0` now accepts the upgrade
  (new `:Else → WSAccept` branch, line 1230), verified with a Conga client. `OnWsUpgradeReqFn` is also now valence-checked
  at start-up (line 749). Only documentation remains for §3.5.
- 2026-10-01: Phase 3 done — `Tests/WebSockets/` written (9 tests), passing 25/25 consecutive runs. A mutation check confirms the suite catches reverting §3.1, §3.3 and §3.9. `OnWsCloseFn` (the WSClose handshake) is left to browser testing; the raw Conga client can't produce it.
- 2026-10-01: Phase 4 done — `docs/websockets.md`, `docs/settings-websockets.md`, nav + overview wiring, and a 1.24.0 `release-notes.md` entry. Also found §3.10 (`OnWsErrorFn` never called); Brian is wiring it up, and the docs already describe it as working.
- 2026-10-01: §3.10 fixed — the `WSError` handler now calls `OnWsErrorFn`. All review items are now resolved except the two manual/browser test gaps (`OnWsCloseFn`, `OnWsErrorFn`) and the optional `WsSend`/`SendSSE` result-convention alignment (§6).
