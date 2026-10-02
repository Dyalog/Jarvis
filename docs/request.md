`Jarvis` creates a `Request` object for each HTTP request it receives from a client. The `Request` holds everything `Jarvis` knows about the request: the method, endpoint, headers, cookies, payload, any credentials, and the client's address and certificate. It also holds a [`Response`](./response.md) namespace, which `Jarvis` uses to build the response it sends back to the client.

In the documentation and examples, `req` refers to an instance of `Request`.

## What's in a `Request`

|Part|What it's for|
|--|--|
|[Fields](./request-fields.md)|Information about the incoming request, such as [`Method`](./request-fields.md#method), [`Endpoint`](./request-fields.md#endpoint), [`Headers`](./request-fields.md#headers), [`Payload`](./request-fields.md#payload), [`QueryParams`](./request-fields.md#queryparams), [`UserID`](./request-fields.md#userid) and [`Session`](./request-fields.md#session). Treat these as read-only.|
|[Methods](./request-methods.md)|Functions for reading the request and shaping the response, such as [`GetHeader`](./request-methods.md#getheader), [`SetHeader`](./request-methods.md#setheader), [`SetContentType`](./request-methods.md#setcontenttype), [`SetStatus`](./request-methods.md#setstatus) and [`Fail`](./request-methods.md#fail).|
|[`Response`](./response.md)|The status, headers and payload that `Jarvis` will send back to the client.|

## Where you'll see a `Request`

### In your endpoints

How your code receives `req` depends on the paradigm you're using:

- **[JSON paradigm](./json.md)**: `req` is the left argument to dyadic or ambivalent endpoints. Monadic endpoints don't receive it. Many endpoints don't need it, because `Jarvis` builds the response from the endpoint's result.
- **[REST paradigm](./rest.md)**: `req` is the right argument to your HTTP method handlers (`Get`, `Post` and so on). A REST handler usually needs `req`, at least to read [`Endpoint`](./request-fields.md#endpoint) and work out which resource was requested.

```APL
     ∇ r←req Hello name           ⍝ JSON endpoint
[1]    r←'Hello ',name,' from ',req.PeerAddr
     ∇

     ∇ r←Get req                  ⍝ REST handler
[1]    r←LookUp req.Endpoint
     ∇
```

### In hook functions

`req` is the right argument to these [hook functions](./settings-hooks.md):

|Hook|When `Jarvis` calls it|
|--|--|
|[`ValidateRequestFn`](./settings-hooks.md#validaterequestfn)|For every request, before any other processing. Use it to reject requests early.|
|[`AuthenticateFn`](./settings-hooks.md#authenticatefn)|Before calling your endpoint, to check the client's credentials.|
|[`SessionInitFn`](./settings-hooks.md#sessioninitfn)|When `Jarvis` creates a new [session](./sessions.md). The session is available as `req.Session`.|
|[`PostProcessFn`](./settings-hooks.md#postprocessfn)|After your endpoint returns and before `Jarvis` formats and sends the response. Use it to adjust `req.Response`.|

## The life of a `Request`

1. `Jarvis` receives an HTTP request and creates a `Request` with the request's method, endpoint, headers, body and so on.
2. If the request body is compressed, `Jarvis` decompresses it.
3. `Jarvis` calls `ValidateRequestFn`, if you've defined one.
4. `Jarvis` calls `AuthenticateFn` and parses the body into [`Payload`](./request-fields.md#payload), for example JSON into an APL array or form data into a namespace. In the JSON paradigm the body is parsed first; in the REST paradigm authentication comes first.
5. `Jarvis` calls your endpoint or REST handler.
6. `Jarvis` uses `req.Response` to send the response, as described in [How `Jarvis` builds the response](./response.md#how-jarvis-builds-the-response).

If a hook or one of `Jarvis`' own checks fails the request in steps 2–4, `Jarvis` skips the remaining steps and sends the failure status to the client. Calling [`Fail`](./request-methods.md#fail) in your endpoint doesn't stop the endpoint, but `Jarvis` sends the failure status when it returns.

Each `Request` lasts for one request only. Don't keep a reference to it after your endpoint returns. To keep information between requests from the same client, use [sessions](./sessions.md).

## See also

- [Using the Request Object](./using-request.md) for worked examples
- [Request Fields](./request-fields.md)
- [Request Methods](./request-methods.md)
- [Response Namespace](./response.md)
