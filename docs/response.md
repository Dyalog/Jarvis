The `Response` namespace is a field in `Request` instance that contains the payload and information `Jarvis` uses to format and send a response.

Every [`Request`](./request.md) has its own `Response` namespace, `req.Response`. You can set its fields directly, or use the [`Request` methods](./request-methods.md) [`SetStatus`](./request-methods.md#setstatus), [`Fail`](./request-methods.md#fail), [`SetHeader`](./request-methods.md#setheader), [`AddHeader`](./request-methods.md#addheader), [`DefaultHeader`](./request-methods.md#defaultheader) and [`SetContentType`](./request-methods.md#setcontenttype), which update `Response` for you.

In many cases you won't need to touch `Response` at all; `Jarvis` builds the response from your endpoint's result.

## How `Jarvis` builds the response

Once your endpoint (or REST handler) returns, `Jarvis`:

1. Uses the endpoint's result as [`Payload`](#payload), but only if you haven't already set `Payload` yourself.
2. Calls [`PostProcessFn`](./settings-hooks.md#postprocessfn), if you've defined one.
3. Sets the `Content-Type` header to [`DefaultContentType`](./settings-operational.md#defaultcontenttype) if it hasn't been set.
4. Converts `Payload` to JSON if the content-type is `application/json`.
5. Compresses `Payload` if [`UseZip`](./settings-operational.md#usezip) is enabled, the payload is large enough, and the client accepts compressed content.
6. Adds `Server` and `Date` headers and sends the response.

In the REST paradigm, steps 3 and 4 are skipped for a non-2xx response unless [`RESTFailProcessing`](./settings-rest.md#restfailprocessing) is `1`.

## `Response` Fields

### `Status`

|--|--|
|Description|`Status` is the HTTP status code to send to the client.|
|Default|`0`|
|Notes|<ul><li>If [`ValidateRequestFn`](./settings-hooks.md#validaterequestfn) accepts the request and `Status` is still `0`, `Jarvis` sets it to `200` before calling your endpoint. If `ValidateRequestFn` rejects the request and doesn't set a status, `Jarvis` uses `400`.</li><li>Use [`SetStatus`](./request-methods.md#setstatus) or [`Fail`](./request-methods.md#fail) rather than assigning `Status` directly. They also set [`StatusText`](#statustext).</li><li>In the JSON paradigm, if your endpoint returns no result, leaves `Payload` empty and leaves `Status` at `200`, `Jarvis` responds with `204 No Content`.</li><li>`Jarvis` closes the connection after sending any non-2xx response.</li></ul>|

### `StatusText`

|--|--|
|Description|`StatusText` is the reason phrase sent with [`Status`](#status), for example `'Not Found'`.|
|Default|`'OK'`|
|Notes|[`SetStatus`](./request-methods.md#setstatus) and [`Fail`](./request-methods.md#fail) look up the standard reason phrase for the status code and append any message you supply in parentheses. If you assign `Status` directly, remember to set `StatusText` to match.|

### `Payload`

|--|--|
|Description|`Payload` is the body of the response.|
|Default|`''`|
|Notes|<ul><li>If you set `Payload` in your endpoint, `Jarvis` sends it in preference to your endpoint's result.</li><li>If the response content-type is `application/json`, `Payload` should be an APL array; `Jarvis` converts it to JSON. Otherwise, `Payload` should be a character vector or a vector of byte values.</li><li>To send a file, set `Payload` to a 2-element vector of an empty vector and the file name, `''filename`. Conga reads and sends the file. Use [`ContentTypeForFile`](./request-methods.md#contenttypeforfile) to set an appropriate content-type.</li><li>If [`HTMLInterface`](./settings-json.md#htmlinterface) is enabled and a request fails with an empty `Payload`, `Jarvis` sends a short HTML page showing the status and status text.</li></ul>|
|Examples|`req.Response.Payload←'<h1>Hello</h1>'`<br>`req.Response.Payload←'' '/var/www/report.pdf'`|

### `Headers`

|--|--|
|Description|`Headers` is a 2-column matrix of the response's `[;1]` header names and `[;2]` header values.|
|Default|`0 2⍴'' ''`|
|Notes|<ul><li>Use [`SetHeader`](./request-methods.md#setheader), [`AddHeader`](./request-methods.md#addheader), [`DefaultHeader`](./request-methods.md#defaultheader) or [`SetContentType`](./request-methods.md#setcontenttype) rather than assigning `Headers` directly. `SetHeader` always appends a new row; `AddHeader` and `DefaultHeader` add the header only if it isn't already present.</li><li>To read a response header, use `req.(Response.Headers GetHeader 'content-type')`. See [`GetHeader`](./request-methods.md#getheader).</li><li>`Jarvis` adds the `Server` and `Date` headers when it sends the response, and `Content-Encoding` if it compresses the payload.</li></ul>|

## Examples

A REST handler that returns `201 Created` with a `Location` header:

```APL
     ∇ r←Post req;id
[1]    id←SaveItem req.Payload
[2]    req.SetStatus 201
[3]    'Location'req.SetHeader req.MakeURI id
[4]    r←⎕NS''
[5]    r.id←id
     ∇
```

A JSON endpoint that returns plain text instead of JSON:

```APL
     ∇ r←req Version dummy
[1]    req.SetContentType'text/plain; charset=utf-8'
[2]    r←'Version 1.2.3'
     ∇
```

An endpoint that fails the request with a message:

```APL
     ∇ r←req GetItem args
[1]    r←''
[2]    →0 If'Item not found'req.Fail 404×~ItemExists args.id
[3]    r←LoadItem args.id
     ∇
```
