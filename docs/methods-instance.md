Most of `Jarvis`' instance methods return a return code, `rc`, and a message, `msg`.

* `rc` is 0 to indicate success, a non-zero value indicates some error or warning condition
* `msg` is a (hopefully) meaningful message describing the success or error 

Below, the methods you are more likely to use are presented first.

### `Start`
|--|--|
|Description|`Start` starts or resumes a `Jarvis` instance.|
|Syntax|`(rc msg)←j.Start`|  
|Examples|<pre style="font-family:APL">      j.Start<br/>2025-09-01 @ 10.14.54.476 - Starting  Jarvis  1.20.6<br/>2025-09-01 @ 10.14.54.493 - Conga copied from C:\Program Files\Dyalog\Dyalog APL-64 20.0 Unicode/ws/conga<br/>2025-09-01 @ 10.14.54.494 - Local Conga v3.6 reference is #.Jarvis.[LIB]<br/>2025-09-01 @ 10.14.54.499 - Jarvis starting in "JSON" mode on port 8080<br/>2025-09-01 @ 10.14.54.500 - Serving code in #<br/>2025-09-01 @ 10.14.54.506 - Click http://192.168.223.137:8080 to access web interface<br/>0  Server started</pre>|

### `Stop`
|--|--|
|Description|`Stop` stops a running `Jarvis` instance.|
|Syntax|`(rc msg)←j.Stop`|  
|Examples|<pre style="font-family:APL">      j.Stop<br/>2025-09-01 @ 10.54.24.701 - Stopping server...<br/>0  Server stopped <br/><br/>     j.Stop ⍝ try stopping a stopped server<br/>¯1  Server is not running </pre>|

### `Config`
|--|--|
|Description|`Config` returns all of the settings for a `Jarvis` instance.|
|Syntax|`r←j.Config`|  
|`r`|is a 2-column matrix of `[;1]` setting names, `[;2]` setting values.|
|Examples|<pre style="font-family:APL">       j.Config<br/> AcceptFrom</br/> AllowFormData                                               0 <br/> AllowGETs                                                   0 <br/> AppCloseFn<br/> AppInitFn<br/> AuthenticateFn<br/> BufferSize                                              10000 <br/> CORS_Headers                                                * <br/> CORS_MaxAge                                                60 <br/> CORS_Methods                                 GET,POST,OPTIONS <br/> ORS_Origin                                                 * <br/> ... and so on and so forth</pre>|
|Notes|At present, there are about 60 settings that are displayed.|

### `EndPoints`
|--|--|
|Description||
|Syntax||  
|``||
|Examples||
|Notes||

### `Pause`
|--|--|
|Description|`Pause` "pauses" a running `Jarvis` instance. Pausing causes `Jarvis` to refuse any new connections. Existing connections will continue to be served. The [`Start`](#start) method will "unpause" a paused `Jarvis`.|
|Syntax|`(rc msg)←j.Pause`|  
|Examples|<pre style="font-family:APL">      j.Pause<br/>2025-09-01 @ 10.57.13.275 - Pausing server...<br/>0  Server paused <br/>      j.Pause ⍝ try pausing a paused server<br/>¯2  Server is already paused <br/>      j.Start ⍝ restart a paused server<br/>2025-09-01 @ 11.03.31.296 - Starting  Jarvis  1.20.6<br/>0  Server resuming operations <br/>      j.Stop<br/>2025-09-01 @ 10.58.36.630 - Stopping server...<br/>0  Server stopped <br/>      j.Pause ⍝ try pausing a stopped server<br/>¯1  Server is not running </pre>|
|Notes||

### `Running`
|--|--|
|Description|`Running` returns a `1` if `Jarvis` is running or paused, `0` otherwise.|
|Syntax|`r←j.Running`|  

### `Thread`
|--|--|
|Description|`Thread` returns the thread number if the server is running or `⍬` if the server is not running.|
|Syntax|`thread←j.Thread`|  

### `Log`
|--|--|
|Description|`Log` is an overridable method used to log messages. By default if [`Logging`](./settings-operational.md#logging) is set to `1` the message passed as the right argument is displayed with a timestamp in the APL session.|
|Syntax|`{msg}←{level}Log msg`|  
|`msg`|The message to be displayed. This is also returned as the shy result.|
|`level`|(optional) The message level. This is not used in the default `Log` method, but is included so that an overriding method can make use of it to distinguish between different types of messages, for instance informational, warning, and error messages.|
|Examples|To use `Log` from an endpoint, you need to use the [reference to the `Jarvis` server](./request-fields.md#server) that is supplied in the [Request](./request.md) object. One might write something like<br/><pre style="font-family:APL">req.server.Log 'Endpoint "',(⊃⎕SI),'" called'</pre> to log whenever an endpoint is called.|
|Notes|We intend to implement more comprehensive logging in a future release of **Jarvis**.|

### `Reset`
|--|--|
|Description|`Reset` "resets" `Jarvis` by killing all `Jarvis`-related threads and clearing any session information. `Reset` does not affect any `Jarvis` settings.|
|Syntax|`(rc msg)←j.Reset`|  
|Examples|<pre style="font-family:APL">      j.Reset<br/>0  Server reset (previously set options are still in effect)</pre>|
|Notes|`Reset` is rarely needed but can be useful during endpoint development.|

### `SendSSE`
|--|--|
|Description|`SendSSE` sends a [Server-Sent Event](./sse.md) to one or more open SSE connections.|
|Syntax|`{r}←targets j.SendSSE payload`|  
|`targets`|One or more SSE connections: connection name(s) (from [`SSEConnections`](#sseconnections) or [`req.Connection`](./request-fields.md#connection)), connection namespace(s), or [`Request`](./request.md) instance(s). Empty → no-op, result `⍬`.|
|`payload`|The event to send: `''` sends a `:` keep-alive comment; text that is already a complete event (per [`IsSSEText`](./methods-shared.md#isssetext)) is sent as it is; anything else is formatted with [`FormatSSE`](./methods-shared.md#formatsse) first.|
|`r`|One code per target: `0` sent, a Conga return code on failure (the connection is removed), or `¯1` for a target that isn't an open SSE connection (logged).|
|Examples|`(j.SSEConnections 'events') j.SendSSE 'tick' j.FormatSSE ⎕TS`|
|Notes|See [Using Server-Sent Events](./sse.md#sending-events) for the full payload rules.|

### `SSEConnections`
|--|--|
|Description|`SSEConnections` returns the names of the open SSE connections — all of them, or those for particular endpoints.|
|Syntax|`r←j.SSEConnections endpoints`|  
|`endpoints`|`''` → every open SSE connection; otherwise one or more [`SSEEndpoints`](./settings-sse.md#sseendpoints) names (for example `'events'`, `'events, alerts'`, or `'events' 'alerts'`) → those endpoints' connections.|
|`r`|A vector of connection names, for use as the left argument to [`SendSSE`](#sendsse). Empty before `Start` and after `Stop`.|
|Examples|`(j.SSEConnections '') j.SendSSE j.FormatSSE ⎕TS ⍝ broadcast to every stream`|
|Notes|A connection can close at any time, so the list may be out of date by the time it's used; [`SendSSE`](#sendsse) re-validates each connection. See [Using Server-Sent Events](./sse.md#sseconnections).|

### `WsSend`
|--|--|
|Description|`WsSend` sends a message to one or more open [WebSocket](./websockets.md) connections.|
|Syntax|`{r}←where j.WsSend what`|  
|`where`|One or more WebSocket connections: connection name(s) (a `conx`, from a connection namespace) or connection namespace(s).|
|`what`|The message: a namespace is sent as JSON; any other array is sent as it is.|
|`r`|One Conga return code per connection: `0` for success, non-`0` for a send failure (also logged).|
|Examples|A reply from inside an [`OnWsReceiveFn`](./settings-websockets.md#onwsreceivefn):<br/><pre style="font-family:APL">      ∇ r←WsReceive req;ns<br/>        ns←req.##<br/>        {}(ns.conx)ns.Server.WsSend 'ack: ',req.Payload<br/>        r←0<br/>      ∇</pre>|
|Notes|See [Using WebSockets](./websockets.md#sending-messages).|
