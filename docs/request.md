A `Request` object is created for each request `Jarvis` receives from a client. `Request` contains the information from the HTTP request and a [`Response`](#response) namespace that contains information `Jarvis` uses to send the response back to the client.  `Request` is also passed as an argument to several of `Jarvis`' ["hook" functions](./settings-hooks.md). 

We'll use `req` in the documentation and examples to refer to an instance of the `Request` object.

## When using the [JSON paradigm](./json.md)
`req` is passed as the left argument to dyadic or ambivalent endpoints. In many cases, your endpoint won't need the `Request`; `Jarvis` handles the details of formatting the response from the result of your endpoint.   

## When using the [REST paradigm](./rest.md)
The `Request` object is passed as the right argument to your HTTP command handlers.

## `Request` Fields
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

### `Password`
|--|--|
|Description||
|Default||
|Example(s)||
|Notes||

### `UserID`
|--|--|
|Description||
|Default||
|Example(s)||
|Notes||

### `PeerCert`
|--|--|
|Description||
|Default||
|Example(s)||
|Notes||

### `PeerAddr`
|--|--|
|Description||
|Default||
|Example(s)||
|Notes||

### `Server`
|--|--|
|Description||
|Default||
|Example(s)||
|Notes||

### `Session`
|--|--|
|Description||
|Default||
|Example(s)||
|Notes||

### `KillOnDisconnect`
|--|--|
|Description||
|Default||
|Example(s)||
|Notes||

### `Input`
|--|--|
|Description||
|Default||
|Example(s)||
|Notes||

### `Payload`
|--|--|
|Description||
|Default||
|Example(s)||
|Notes||

### `Response`
See [`Response` Namespace](#response-namespace).



## `Request` Methods

### `AddHeader`
|--|--|
|Description|`AddHeader` adds an HTTP response header, but only if a header with that name is not already set. (Use `SetHeader` to set a header unconditionally, replacing any existing value.)|
|Syntax|`{(name value)}←name req.AddHeader value`|
|`name`|The header name.|
|`value`|The header value to add if the header isn't already present.|
|Notes|Returns the header's name and its resulting value — the value just added, or the existing value if the header was already set. `Jarvis` uses `AddHeader` to set the default Server-Sent Event response headers, which an application's [`ValidateRequestFn`](./settings-hooks.md#validaterequestfn) can therefore pre-empt.|

## `Response` Namespace