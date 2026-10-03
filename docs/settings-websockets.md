WebSockets give a `Jarvis` application a two-way, persistent connection to a client, over which either side can send messages at any time. A client opens an ordinary HTTP connection and asks to "upgrade" it to a WebSocket; once `Jarvis` accepts, the connection stays open and both ends exchange messages until it's closed.

WebSocket support is off by default. To use it, set [`EnableWebSockets`](#enablewebsockets) and write the [hook functions](#onwsreceivefn) your application needs. See [Using WebSockets](./websockets.md) for a fuller description and a worked example.

The hook functions below are all located in [`CodeLocation`](./settings-operational.md#codelocation), like the other [user hooks](./settings-hooks.md), and are excluded from being called as ordinary endpoints. Each must be a monadic or ambivalent, result-returning function; `Jarvis` checks this when it starts.

### `EnableWebSockets`
|--|--|
|Description|`EnableWebSockets` is a Boolean that enables or disables WebSocket support. Valid values are:<ul><li>`0` - WebSocket requests are refused</li><li>`1` - WebSocket requests are handled</li></ul>|
|Default|`0`|
|Examples|`j.EnableWebSockets←1`|
|Notes|When `0`, a WebSocket upgrade event on a connection is logged and the connection is closed. The WebSocket hook functions are only validated at start-up when `EnableWebSockets` is `1`.|

### `WsAutoUpgrade`
|--|--|
|Description|`WsAutoUpgrade` controls how a WebSocket upgrade request is accepted. Valid values are:<ul><li>`1` - `Jarvis` (via Conga) accepts the upgrade automatically. After the upgrade, [`OnWsUpgradeFn`](#onwsupgradefn), if defined, is called.</li><li>`0` - the upgrade is offered to your code: [`OnWsUpgradeReqFn`](#onwsupgradereqfn) decides whether to accept it. If `OnWsUpgradeReqFn` is not defined, the upgrade is accepted.</li></ul>|
|Default|`1`|
|Examples|`j.WsAutoUpgrade←0 ⍝ decide each upgrade in OnWsUpgradeReqFn`|
|Notes|With `WsAutoUpgrade←0` and no `OnWsUpgradeReqFn`, every upgrade is accepted, which is the same outcome as `WsAutoUpgrade←1` except that the event your code would see is `WSUpgradeReq` rather than `WSUpgrade`.|

### `OnWsUpgradeFn`
|--|--|
|Description|`OnWsUpgradeFn` is the name of a function called after a connection has been automatically upgraded to a WebSocket (`WsAutoUpgrade←1`). Its right argument is the connection namespace (see [Using WebSockets](./websockets.md#the-connection-namespace)). The result should be:<ul><li>`0` - keep the connection open</li><li>non-`0` - close the connection</li></ul>|
|Default|`''`|
|Examples|`j.OnWsUpgradeFn←'WsConnected'`|
|Notes|Use `OnWsUpgradeFn` to record the new connection or to initialise per-connection state. To accept or reject upgrades based on the request, set `WsAutoUpgrade←0` and use [`OnWsUpgradeReqFn`](#onwsupgradereqfn) instead.|

### `OnWsUpgradeReqFn`
|--|--|
|Description|`OnWsUpgradeReqFn` is the name of a function called when a client requests a WebSocket upgrade and `WsAutoUpgrade` is `0`. Its right argument is the connection namespace. The result should be:<ul><li>`0` - accept the upgrade</li><li>non-`0` - reject it and close the connection</li></ul>|
|Default|`''`|
|Examples|`j.OnWsUpgradeReqFn←'AcceptWs'`|
|Notes|`OnWsUpgradeReqFn` has effect only when `WsAutoUpgrade←0`. The connection namespace's `Headers`, `Path` and `PeerAddr` are available, so the decision can be based on the upgrade request. To add headers to the acceptance response, set the connection namespace's `AcceptHeaders`.|

### `OnWsReceiveFn`
|--|--|
|Description|`OnWsReceiveFn` is the name of a function called for each message received on a WebSocket. Its right argument is a message namespace (see [Receiving messages](./websockets.md#receiving-messages)) whose `Payload` is the message. The result should be:<ul><li>`0` - keep the connection open</li><li>non-`0` - close the connection</li></ul>|
|Default|`''`|
|Examples|`j.OnWsReceiveFn←'WsReceive'`|
|Notes|If `OnWsReceiveFn` is not defined and the [HTML interface](./settings-json.md#htmlinterface) is enabled, `Jarvis` uses a built-in handler that treats each message as a request for an endpoint in `CodeLocation`. See [The built-in message handler](./websockets.md#the-built-in-message-handler). If you use WebSockets for your own protocol, define `OnWsReceiveFn`.|

### `OnWsCloseFn`
|--|--|
|Description|`OnWsCloseFn` is the name of a function called when a WebSocket is closed by the client. Its right argument is the connection namespace. Any result is ignored.|
|Default|`''`|
|Examples|`j.OnWsCloseFn←'WsClosed'`|
|Notes|Use `OnWsCloseFn` to clean up any per-connection state. It is called on a WebSocket close handshake; `Jarvis` removes the connection afterwards regardless.|

### `OnWsErrorFn`
|--|--|
|Description|`OnWsErrorFn` is the name of a function called when an error occurs on a WebSocket. Its right argument is the connection namespace. Any result is ignored.|
|Default|`''`|
|Examples|`j.OnWsErrorFn←'WsError'`|
|Notes|`Jarvis` logs the error and removes the connection regardless of whether `OnWsErrorFn` is defined.|

### `WsAuthenticateFn`
|--|--|
|Description|`WsAuthenticateFn` is the name of a function used to authenticate a WebSocket connection. It is called with the connection namespace before the first message is dispatched to [`OnWsReceiveFn`](#onwsreceivefn). The result should be:<ul><li>`0` - authentication succeeded (or none was needed)</li><li>non-`0` - authentication failed; `Jarvis` closes the connection without dispatching the message</li></ul>|
|Default|`''`|
|Examples|`j.WsAuthenticateFn←'WsAuthenticate'`|
|Notes|`WsAuthenticateFn` is called once per connection: after it succeeds, the connection is marked authenticated and the function is not called again for that connection. It applies only when [`OnWsReceiveFn`](#onwsreceivefn) is defined. Because the browser's `WebSocket` API can't set request headers, a token is usually carried in the connection namespace's `Headers` (from the upgrade request), in a cookie, or in the upgrade request's query string.|
