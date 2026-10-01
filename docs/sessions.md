A stateless web service treats each request as independent: the server keeps nothing about a client between requests. That keeps a service simple and scalable, and it's the right default. Sometimes, though, you need to remember something about a client across several requests — a logged-in user, a shopping basket, a multi-step workflow. **Jarvis**'s sessions let you keep that state on the server and associate it with a particular client.

## Enabling sessions

Sessions are off by default. Turn them on with [`SessionTimeout`](./settings-session.md#sessiontimeout), which is also how long (in minutes) a session may be idle before **Jarvis** discards it:

```apl
j←Jarvis.New ''
j.CodeLocation←#.MyApp
j.SessionTimeout←20   ⍝ sessions time out after 20 minutes of inactivity
j.Start
```

Use `¯1` for sessions that never time out (you then manage their lifetime yourself), or `0` (the default) for no sessions.

## How a session flows

1. A request arrives without a valid session id. **Jarvis** creates a session: a fresh namespace to hold your state, with a unique id.
2. **Jarvis** sends the id back to the client in the [`SessionIdHeader`](./settings-session.md#sessionidheader) — as an HTTP header, or, if [`SessionUseCookie`](./settings-session.md#sessionusecookie) is `1`, as a cookie.
3. The client returns that id on its next request (a browser returns a cookie automatically; other clients must echo the header).
4. **Jarvis** looks the id up, finds the session namespace, and makes it available to your endpoint as [`req.Session`](./request.md#session). The session's idle timer is reset.

If the id is missing, unknown, or expired, **Jarvis** starts a new session, so your endpoint always has a `req.Session` to work with when sessions are enabled.

For a browser client, set `SessionUseCookie←1`: the browser then carries the session cookie on every request with no page code required. `EventSource` and `WebSocket` clients can't set request headers, so a cookie is the practical way to session them too (see [Server-Sent Events](./sse.md#authentication-and-sessions) and [WebSockets](./websockets.md#authentication)).

## Using the session

`req.Session` is an ordinary namespace. Read and write variables in it to keep per-client state:

```apl
∇ r←hit req
⍝ a per-session hit counter
  req.Session.count+←1
  r←req.Session.count
∇
```

Give session variables their initial values in a [`SessionInitFn`](./settings-hooks.md#sessioninitfn), which **Jarvis** calls once, when the session is created, with the [`Request`](./request.md) whose `Session` is the new namespace:

```apl
j.SessionInitFn←'InitSession'

∇ r←InitSession req
  req.Session.count←0
  r←0        ⍝ 0 = session initialised; non-0 fails the request with 500
∇
```

Without a `SessionInitFn`, a new session's namespace starts empty, so guard the first access (for example with `⎕NC`) or set defaults yourself.

## Timeouts and cleanup

While sessions are enabled, **Jarvis** runs a monitor in a separate thread that looks for idle sessions every [`SessionPollingTime`](./settings-session.md#sessionpollingtime) minutes. When a session has been idle longer than `SessionTimeout`, its namespace is erased and the state is gone.

**Jarvis** keeps a small record that the session *existed* for a further [`SessionCleanupTime`](./settings-session.md#sessioncleanuptime) minutes. During that window a request bearing the expired id can be told its session timed out, rather than silently being given a brand-new one. Set `SessionCleanupTime` equal to `SessionTimeout` to keep no record at all after a session ends.

## Sessions and security

A session id is a bearer token: whoever holds it can use the session. So:

- Serve a sessioned service over [TLS](./security.md#using-tls) so ids aren't sent in the clear.
- Treat sessions as a convenience for state, not as authentication on their own; see [Authentication](./security.md#authentication) for deciding who a client is. A common pattern is to authenticate once and record the result in `req.Session`.
