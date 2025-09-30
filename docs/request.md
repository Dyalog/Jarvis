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

## `Response` Namespace