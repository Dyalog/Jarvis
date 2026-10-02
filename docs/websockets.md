[WebSockets](https://developer.mozilla.org/docs/Web/API/WebSockets_API) give a `Jarvis` application a two-way, persistent connection to a client. Unlike an ordinary HTTP request, where the client asks and the server answers once, a WebSocket stays open: either side can send a message at any time, until the connection is closed. This suits interactive, low-latency exchanges — live updates in both directions, chat, collaborative editing, streaming commands and results.

If you only need the server to push a stream of events to the client, and the client never sends anything back over that channel, [Server-Sent Events](./sse.md) are simpler, work over plain HTTP, and reconnect automatically.

WebSocket support works in both the [JSON](./json.md) and [REST](./rest.md) paradigms. It is off by default; see [WebSocket Settings](./settings-websockets.md).

## A first example

```
      ⍝ in CodeLocation
      ∇ r←WsReceive req                 ⍝ OnWsReceiveFn
        {}(req.##.conx)req.##.Server.WsSend 'You said: ',req.Payload
        r←0                              ⍝ 0 keeps the connection open
      ∇

      j←Jarvis.New ''
      j.CodeLocation←#
      j.EnableWebSockets←1
      j.OnWsReceiveFn←'WsReceive'
      j.Start
```

In a page served from the same `Jarvis`:

```
const ws = new WebSocket("ws://localhost:8080/");
ws.onmessage = e => console.log(e.data);   // "You said: hello"
ws.onopen    = () => ws.send("hello");
```

## The connection lifecycle

A WebSocket connection goes through three stages, each with its own hook.

### Upgrade

A client opens an HTTP connection and sends an `Upgrade: websocket` request. How `Jarvis` handles it depends on [`WsAutoUpgrade`](./settings-websockets.md#wsautoupgrade):

- **`WsAutoUpgrade←1` (the default):** `Jarvis` accepts the upgrade automatically, then calls [`OnWsUpgradeFn`](./settings-websockets.md#onwsupgradefn) with the [connection namespace](#the-connection-namespace). Returning a non-zero result closes the connection.
- **`WsAutoUpgrade←0`:** `Jarvis` calls [`OnWsUpgradeReqFn`](./settings-websockets.md#onwsupgradereqfn) with the connection namespace *before* accepting. Return `0` to accept the upgrade, or a non-zero value to reject it. If `OnWsUpgradeReqFn` is not defined, the upgrade is accepted. Your function can inspect the request (`Headers`, `Path`, `PeerAddr`) and can add headers to the acceptance by setting the connection namespace's `AcceptHeaders`.

### Messages

Once upgraded, each message the client sends arrives as a call to [`OnWsReceiveFn`](./settings-websockets.md#onwsreceivefn) (see [Receiving messages](#receiving-messages)). Your application sends messages to a client with [`WsSend`](#sending-messages). A message can be sent from inside `OnWsReceiveFn` (a reply) or from any other code that has the connection, such as a background thread broadcasting to many clients.

### Close and error

When the client closes the connection, `Jarvis` calls [`OnWsCloseFn`](./settings-websockets.md#onwsclosefn) with the connection namespace, then removes the connection. If an error occurs on the connection, `Jarvis` logs it, calls [`OnWsErrorFn`](./settings-websockets.md#onwserrorfn), and removes the connection. Use these hooks to release any per-connection state your application is holding.

## The connection namespace

The upgrade, close and error hooks are each passed a **connection namespace**: a namespace `Jarvis` keeps for the life of the connection. Useful fields are:

| | |
|--|--|
| `conx` | The Conga connection name. Pass it (or the namespace) to [`WsSend`](#sending-messages). |
| `Server` | The `Jarvis` instance, for calling `WsSend`. |
| `Headers` | The upgrade request's headers, as a 2-column matrix of lower-case name and value. |
| `Path` | The path from the upgrade request's URL. |
| `PeerAddr` | The client's IP address. |
| `IsWebSocket` | `1`. |
| `IsAuthenticated` | `1` once [`WsAuthenticateFn`](./settings-websockets.md#wsauthenticatefn) has accepted the connection. |

Keep a reference to the connection (its `conx`, or the namespace) if you want to send to it later, for example from a broadcast thread.

## Receiving messages

When `OnWsReceiveFn` is defined, `Jarvis` calls it for each message with a **message namespace**, which we'll call `req`. Its fields are:

| | |
|--|--|
| `Payload` | The message content. |
| `DataType` | The WebSocket data type. |
| `Complete` | Whether the message is complete. |
| `req.##` | The [connection namespace](#the-connection-namespace) (the message namespace's parent). |

So `req.##.conx` is the connection, `req.##.Server` is the `Jarvis` instance, and `req.##.Headers` is the upgrade request's headers.

`OnWsReceiveFn`'s result controls the connection: `0` keeps it open, and any non-zero value closes it.

## Sending messages

```
{r}←where j.WsSend what
```

`where` is one or more connections to send to. Each can be:

- a connection name (a `conx`, as found in the connection namespace), or
- a connection namespace

`what` is the message:

- a namespace is sent as JSON
- any other array is sent as it is

`r` is one Conga return code per connection: `0` for success, non-zero for a send failure (which is also logged). A reply from inside `OnWsReceiveFn`:

```
      ∇ r←WsReceive req;ns
        ns←req.##                              ⍝ the connection namespace
        {}(ns.conx)ns.Server.WsSend 'ack: ',req.Payload
        r←0
      ∇
```

To send to several connections, collect their `conx` names (for example in `OnWsUpgradeFn`) and pass them all to `WsSend`. A background thread started by [`AppInitFn`](./settings-hooks.md#appinitfn) can broadcast this way; keep a reference to the `Jarvis` instance, which a monadic `AppInitFn` receives as its argument.

## The built-in message handler

If `OnWsReceiveFn` is **not** defined, and the [HTML interface](./settings-json.md#htmlinterface) is enabled (which it is by default in JSON mode), `Jarvis` uses a built-in message handler. It treats each WebSocket message as a JSON request for an endpoint:

```
{"Endpoint":"/myEndpoint","Payload":<argument>}
```

`Jarvis` runs the named function in `CodeLocation` with `Payload` as its argument and sends the result back as JSON. This is what the built-in HTML test page's "Send via WebSocket" button uses, and it's a quick way to try an endpoint over a WebSocket.

The built-in handler applies the same restrictions as the HTTP interface: a function is run only if it passes [`IncludeFns`](./settings-operational.md#includefns) / [`ExcludeFns`](./settings-operational.md#excludefns) and is not a hook function. A message naming any other function gets `Invalid Endpoint`, and a message that isn't valid JSON gets a `WSReceive Error` whose detail follows [`ErrorInfoLevel`](./settings-operational.md#errorinfolevel).

Because the built-in handler is active whenever WebSockets are enabled without an `OnWsReceiveFn`, define `OnWsReceiveFn` for any application that has its own WebSocket protocol, so messages go to your code instead.

## Authentication

Set [`WsAuthenticateFn`](./settings-websockets.md#wsauthenticatefn) to authenticate a connection. When `OnWsReceiveFn` is defined, `Jarvis` calls `WsAuthenticateFn` with the connection namespace before dispatching the first message. Return `0` to accept (the connection is then marked authenticated and the function isn't called again for it), or a non-zero value to reject, in which case `Jarvis` closes the connection without dispatching the message.

The browser's `WebSocket` API can't add headers to its request, so a token is usually carried another way:

- in a cookie, which the browser sends with the upgrade request (available in the connection namespace's `Headers`)
- in the upgrade request's query string (`new WebSocket("ws://host/path?token=…")`), available in `Path`

A non-browser client (for example an APL HTTP client) can send any headers on the upgrade request.

## Things to bear in mind

- Each open WebSocket is a connection that stays open. WebSocket connections are not subject to [`ConnectionTimeout`](./settings-operational.md#connectiontimeout).
- `Jarvis` uses Conga, which supports HTTP/1.x and its WebSocket upgrade; it does not implement WebSocket extensions such as per-message compression.
- Each message is handled on its own thread, so a slow handler for one message doesn't block others; conversely, don't assume replies to rapid successive messages arrive in a fixed order relative to later sends.
- `OnWsCloseFn` is called on a WebSocket **close handshake** (what a browser's `ws.close()` performs). A connection that simply drops is reported as a close and cleaned up, but may not invoke `OnWsCloseFn`.
