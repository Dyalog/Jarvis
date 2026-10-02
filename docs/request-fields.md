Most `Request` fields should be considered read-only and are intended to convey information about the request to your endpoints.

### `ContentType`

|--|--|
|Description|`ContentType` is the request's payload content type specified in the `content-type` header. [`charset`](#charset) contains any `charset` specified in the `content-type header`.|
|Default|`''`|

### `Charset`

|--|--|
|Description|`Charset` is the character set, if any, specified in the `content-type` header.|
|Default|`''`|
|Notes|If `Charset` is `'utf-8'`, `Jarvis` will do the proper UTF-8 conversion to the request payload.|

### `Body`

|--|--|
|Description|`Body` is the raw body of the request after any UTF-8 conversion, if needed.|
|Default|`''`|
|Notes|The difference between `Body` and [`Payload`](#payload) is that `Payload` will have undergone any appropriate translation whereas `Body` won't. For example, if the `ContentType` is `'application/json'`, `Body` might be `[1,2,3]` whereas `Payload` would be the APL array `1 2 3`. Similarly, if the `ContentType` is `'multipart/form-data'` or `'application/x-www-form-urlencoded'`, `Body` contain the raw character data whereas `Payload` will be a namespace containing the named elements specified in the `Body`.|

### `Endpoint`

|--|--|
|Description|`Endpoint` is the endpoint specified in the request's URL, without any query string.|
|Default|`''`|
|Notes|In JSON mode, `Endpoint` is the name of the function that will be called when servicing the request.|

### `Headers`

|--|--|
|Description|`Headers` is a 2-column matrix of the request's `[;1]` header names, `[;2]` header values.|
|Default|`0 2⍴'' ''`|
|Notes|The [`GetHeader`](#getheader) method can be used to retrieve header values by name.|

### `Method`

|--|--|
|Description|`Method` is the HTTP method used for the request.|
|Default|`''`|
|Notes|In JSON mode, this will normally be `POST`. In REST mode, the HTTP method specifies the function to be called to service the request as specified in [`RESTMethods`](./settings-rest.md#restmethods).|

### `IsSSE`

|--|--|
|Description|`IsSSE` is a Boolean that indicates whether the request is for one of the [Server-Sent Events](./sse.md) endpoints named in [`SSEEndpoints`](./settings-sse.md#sseendpoints). Valid values are:<ul><li>`0` - an ordinary request</li><li>`1` - a request for an SSE endpoint</li></ul>|
|Default|`0`|
|Example(s)|An [`AuthenticateFn`](./settings-hooks.md#authenticatefn) that checks event streams differently, because the browser's `EventSource` can't send an `Authorization` header. `CheckToken` and `CheckLogin` stand for your own functions, returning `0` for success:<br><br>&emsp;&emsp;&emsp;`∇ r←Authenticate req`<br>`[1]    :If req.IsSSE`<br>`[2]        r←CheckToken req ⍝ e.g. a token in req.QueryParams`<br>`[3]    :Else`<br>`[4]        r←CheckLogin req`<br>`[5]    :EndIf`<br>&emsp;&emsp;&emsp;`∇`|
|Notes|`Jarvis` sets `IsSSE` after calling [`ValidateRequestFn`](./settings-hooks.md#validaterequestfn), just before it handles the SSE request. So it's always `0` in `ValidateRequestFn`, and `1` in `AuthenticateFn`, [`SessionInitFn`](./settings-hooks.md#sessioninitfn) and the SSE endpoint function. To recognise an SSE request in `ValidateRequestFn`, check [`Endpoint`](#endpoint) instead.|

### `Connection`

|--|--|
|Description|`Connection` is the name of the Conga connection the request arrived on. It can be used as a target for [`SendSSE`](./methods-instance.md#sendsse) to push [Server-Sent Events](./sse.md) to this client.|
|Default|`''`|
|Notes|`Jarvis` sets `Connection` for every request. For a WebSocket, the connection is reached instead through the connection namespace's `conx` (see [Using WebSockets](./websockets.md#the-connection-namespace)).|

### `QueryParams`

|--|--|
|Description|`QueryParams` is a 2-column matrix of the names and values of the parameters in the request's query string (the part of the URL after `?`).|
|Default|`0 2⍴0` (no query parameters)|
|Notes|For example, a request for `/report?from=2026-01-01&fmt=csv` gives `QueryParams` of two rows: `from` `2026-01-01` and `fmt` `csv`. In JSON mode, allowing query-string requests requires [`AllowGETs`](./settings-json.md#allowgets).|

### `UserID`

|--|--|
|Description|`UserID` is the user name supplied in the request's `Authorization` header when HTTP Basic authentication is used.|
|Default|`''`|
|Notes|Set only for a `Basic` `Authorization` header (see [`HTTPAuthentication`](./settings-operational.md#httpauthentication)). Use it in an [`AuthenticateFn`](./settings-hooks.md#authenticatefn) together with [`Password`](#password).|

### `Password`

|--|--|
|Description|`Password` is the password supplied in the request's `Authorization` header when HTTP Basic authentication is used.|
|Default|`''`|
|Notes|Set only for a `Basic` `Authorization` header. See [`UserID`](#userid) and [Security](./security.md).|

### `Cookies`

|--|--|
|Description|`Cookies` is a 2-column matrix of the names and values of the cookies sent with the request.|
|Default|`0 2⍴⊂''` (no cookies)|
|Notes|Use the [`GetCookie`](#getcookie) method to read a cookie by name, and [`SetCookie`](#setcookie) to set one on the response.|

### `PeerCert`

|--|--|
|Description|`PeerCert` is the client's certificate, when the server is running with TLS ([`Secure`](./settings-conga.md#secure)) and the client presented one.|
|Default|`0 0⍴⊂''` (no certificate)|
|Notes|For a secure server that couldn't obtain the certificate, `PeerCert` is the text `'Could not obtain certificate'`.|

### `PeerAddr`

|--|--|
|Description|`PeerAddr` is the IP address of the client that made the request.|
|Default|`'unknown'`|

### `Server`

|--|--|
|Description|`Server` is a reference to the `Jarvis` instance handling the request. Use it to reach the instance methods from an endpoint — for example [`Log`](./methods-instance.md#log), [`SendSSE`](./methods-instance.md#sendsse) or [`WsSend`](./methods-instance.md#wssend).|
|Example(s)|`req.Server.Log 'endpoint called'`|

### `Session`

|--|--|
|Description|`Session` is a reference to this request's session namespace when the service [uses sessions](./sessions.md), or `⍬` otherwise. Store per-session state in it.|
|Default|`⍬`|
|Notes|Sessions are enabled with [`SessionTimeout`](./settings-session.md#sessiontimeout). See [Using Sessions](./sessions.md).|

### `KillOnDisconnect`

|--|--|
|Description|`KillOnDisconnect` controls what happens to the thread handling this request if the client disconnects before the request finishes. Valid values are:<ul><li>`0` - let the handler run to completion</li><li>`1` - kill the handler's thread as soon as the disconnect is detected</li></ul>|
|Default|`0`|
|Notes|An endpoint can set `req.KillOnDisconnect←1` for a long-running request (for example a looping [SSE](./sse.md) endpoint) so its thread is stopped promptly when the client goes away.|

### `Input`

|--|--|
|Description|`Input` is the raw request target from the request line — the path together with any query string, before URL-decoding and before the query string is split off into [`QueryParams`](#queryparams).|
|Default|`''`|
|Notes|[`Endpoint`](#endpoint) is `Input` with the query string removed and URL-decoded.|

### `HTTPVersion`

|--|--|
|Description|`HTTPVersion` is the HTTP version from the request line, for example `'HTTP/1.1'`.|
|Default|`''`|

### `Payload`

|--|--|
|Description|`Payload` is the request body after any parsing. When the content-type is `application/json` or XML and [`ParsePayload`](./settings-rest.md#parsepayload) is on, `Payload` is the APL array converted from the body; for `multipart/form-data` or `application/x-www-form-urlencoded` it is a namespace of the named parts. Otherwise it is the raw body.|
|Default|`''`|
|Notes|The difference between [`Body`](#body) and `Payload` is that `Payload` has undergone any appropriate translation whereas `Body` has not. In JSON mode the parsed payload is passed as the right argument to your endpoint function.|

### `Response` Namespace

Every [`Request`](#request-fields) has a `Response` namespace (`req.Response`) holding what `Jarvis` will send back. Set its fields, or use the `Request` methods above ([`SetHeader`](#setheader), [`SetStatus`](#setstatus), [`SetContentType`](#setcontenttype), [`Fail`](#fail)), to shape the response. In many cases you don't touch it at all: `Jarvis` builds the response from your endpoint's result.

### `Response.Status`

|--|--|
|Description|The HTTP status code to return. `0` until set; `Jarvis` defaults it (to `200` for a normal response) if your code leaves it `0`. Prefer [`SetStatus`](#setstatus) or [`Fail`](#fail), which also set the status text.|

### `Response.StatusText`

|--|--|
|Description|The HTTP reason phrase that accompanies [`Status`](#responsestatus). `SetStatus`/`Fail` set it for you from the status code.|

### `Response.Payload`

|--|--|
|Description|The response body. If your endpoint returns a result and you haven't set `Payload`, `Jarvis` uses the result. When the response content-type is `application/json`, `Jarvis` converts `Payload` to JSON before sending.|

### `Response.Headers`

|--|--|
|Description|A 2-column matrix of the response's header names and values. Use [`SetHeader`](#setheader), [`AddHeader`](#addheader), [`DefaultHeader`](#defaultheader) or [`SetContentType`](#setcontenttype) to add to it rather than assigning it directly.|
