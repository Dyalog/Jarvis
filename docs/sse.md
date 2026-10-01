[Server-Sent Events](https://html.spec.whatwg.org/multipage/server-sent-events.html) (SSE) let a `Jarvis` service push a stream of events to a client over one long-lived HTTP response. In the browser, the [`EventSource`](https://developer.mozilla.org/docs/Web/API/EventSource) API reads the stream, hands each event to your JavaScript, and reconnects by itself if the connection drops.

SSE suits one-way, server-to-client updates such as live dashboards, progress reports, notifications and feeds. The client sends requests to your service in the usual way. Compared with WebSockets, SSE is plain HTTP: it needs no protocol upgrade, works through most proxies, and uses `Jarvis`'s existing validation, CORS, authentication and session handling.

SSE works in both the [JSON](./json.md) and [REST](./rest.md) paradigms.

## A first example

Name the endpoint in [`SSEEndpoints`](./settings-sse.md#sseendpoints). An endpoint function is optional; here it sends a greeting to each new client:

```
      ⍝ in CodeLocation
      ∇ r←events req
        {}req req.Server.SendSSE 'Hello!'   ⍝ send to this client only
        r←0                                 ⍝ 0 keeps the stream open
      ∇

      j←Jarvis.New ''
      j.CodeLocation←#
      j.SSEEndpoints←'events'
      j.Start
```

In a page served from the same `Jarvis` (for example with [`HTMLInterface`](./settings-json.md#htmlinterface)):

```
const source = new EventSource("events");
source.onmessage = e => console.log(e.data);   // "Hello!"
```

From then on, any APL code with a reference to the `Jarvis` instance can push events to the open streams:

```
      (j.SSEConnections 'events') j.SendSSE 'Something happened'
```

To watch a raw stream, use `curl -N http://localhost:8080/events`.

## How an SSE request is handled

A request whose endpoint is listed in `SSEEndpoints` goes through the same early steps as any other request:

1. The request is received and its body decoded.
2. Your [`ValidateRequestFn`](./settings-hooks.md#validaterequestfn), if any, is called. A non-zero result fails the request with 400 (Bad Request).

Then, instead of calling a JSON or REST handler, `Jarvis` checks the request:

3. CORS. A CORS preflight (`OPTIONS`) request gets its usual 204 (No Content) response. For a cross-origin `GET`, the `Access-Control-Allow-Origin` header is added. See [CORS Settings](./settings-cors.md).
4. The method must be `GET`. Otherwise the request fails with 405 (Method Not Allowed).
5. The `Accept` header, if present, must allow `text/event-stream` (`text/event-stream`, `text/*` or `*/*`). Otherwise the request fails with 406 (Not Acceptable). `EventSource` always sends `Accept: text/event-stream`.
6. Authentication. Your [`AuthenticateFn`](./settings-hooks.md#authenticatefn), if any, is called; a non-zero result fails the request with 401 (Unauthorized). If you use [sessions](./settings-session.md), the session is checked or created here.

If any of these steps fails, the client gets an ordinary error response and no stream is opened. With [`HTMLInterface`](./settings-json.md#htmlinterface) enabled, that response has the usual short HTML error body.

If all the steps succeed, `Jarvis` starts the stream:

- It sends a `200 OK` response header with `Content-Type: text/event-stream; charset=utf-8`, `Cache-Control: no-cache`, `Connection: close` and `X-Accel-Buffering: no` (which tells nginx not to buffer the stream). Any headers that your hook functions set on the request's response (for example a session header) are sent too.
- It sends a `: connected` comment, so the client knows at once that the stream is open.
- It calls the endpoint function, if there is one (see below).

The stream has no length. It stays open until the client disconnects, your code closes it, or the server stops. It works with both HTTP/1.0 and HTTP/1.1 clients.

Some features for ordinary requests don't apply to SSE streams:

- [`PostProcessFn`](./settings-hooks.md#postprocessfn) isn't called.
- The stream isn't compressed, even if [`UseZip`](./settings-operational.md#usezip) is set.
- [`ConnectionTimeout`](./settings-operational.md#connectiontimeout) doesn't apply: an idle stream isn't closed. Use [`SSEHeartbeatInterval`](./settings-sse.md#sseheartbeatinterval) to find clients that have gone away.

The [`Request`](./request.md) object's [`IsSSE`](./request.md#issse) field is `1` for a request to an SSE endpoint, so an `AuthenticateFn` can treat streams differently from other requests. `IsSSE` is set after `ValidateRequestFn` is called, so it's still `0` there; a `ValidateRequestFn` can check `req.Endpoint` instead.

## The endpoint function

An SSE endpoint doesn't need a function. Without one, the stream simply opens, and your application sends events to it later.

If `CodeLocation` has a function with the endpoint's name, `Jarvis` calls it once, after the stream has started. The function must be monadic or ambivalent. Its right argument is the [`Request`](./request.md) object, which we'll call `req`. Useful parts of `req` are:

| | |
|--|--|
| `req.Server` | The `Jarvis` instance, for calling `SendSSE`, `SSEConnections` and `FormatSSE`. |
| `req.Connection` | The name of this client's connection. You can keep it and send to this client later. |
| `req.GetHeader 'last-event-id'` | The id of the last event the client received, if it's reconnecting (see [Reconnecting](#reconnecting-and-last-event-id)). |
| `req.QueryParams` | Any query parameters, for example from `new EventSource("events?topic=prices")`. |
| `req.Session` | The session, if you use sessions. |

The function's result decides what happens to the stream:

| Result | Effect |
|--|--|
| `0`, or no result | The stream stays open. |
| any other value | `Jarvis` closes the stream. |
| an APL error | `Jarvis` logs `Error in SSE handler for endpoint …` and closes the stream. |

A shy result is treated like an explicit one.

The function can return straight away, as in the example above, leaving other code to send events later. Or it can loop, sending events to its own client until it's done:

```
      ∇ r←progress req;i;rc
        :For i :In ⍳10
            ⎕DL 1
            :If 0≠rc←req req.Server.SendSSE ('progress' i) req.Server.FormatSSE i×10
                :Leave   ⍝ the client has gone away
            :EndIf
        :EndFor
        r←1   ⍝ done: close the stream
      ∇
```

The function runs on the thread that handled the request, so a looping function doesn't block other requests. If the client disconnects while it's running:

- By default, the function keeps running until its next `SendSSE` fails. Check `SendSSE`'s result, as above.
- If the function sets `req.KillOnDisconnect←1`, `Jarvis` kills its thread as soon as it sees the disconnect.

With [`Debug`](./settings-operational.md#debug) set to `2`, `Jarvis` stops just before calling the endpoint function, as it does for other endpoints.

## Sending events

### `SendSSE`
|--|--|
|Description|`SendSSE` sends an event to one or more open SSE streams.|
|Syntax|`{r}←targets j.SendSSE payload`|
|`targets`|One or more streams to send to. Each target can be either:<ul><li>a connection name, as returned by [`SSEConnections`](#sseconnections) or found in `req.Connection`</li><li>a [`Request`](./request.md) object for an SSE request (`req` in the endpoint function)</li></ul>If `targets` is empty, nothing is sent and `r` is `⍬`.|
|`payload`|What to send:<ul><li>`''` - sends a `:` comment, which the client ignores</li><li>text that is already one or more complete SSE events (see [`IsSSEText`](#isssetext)) - sent as it is. Use this when you've formatted the event with [`FormatSSE`](#formatsse), or by hand.</li><li>anything else (plain text, numbers, namespaces, character matrices, vectors of character vectors and so on) - first formatted with `FormatSSE` as an unnamed event</li></ul>A leading byte order mark (`⎕UCS 65279`) is removed, and the text is sent as UTF-8.|
|`r`|One number per target, in order:<ul><li>`0` - the event was sent</li><li>`¯1` - the target isn't an open SSE stream (for example, it has already closed). `Jarvis` logs it.</li><li>any other non-zero value - the send failed, and this is Conga's return code. `Jarvis` logs it and closes the connection.</li></ul>|
|Examples|`req req.Server.SendSSE 'Welcome!' ⍝ to one client, from its endpoint function`<br>`(j.SSEConnections 'prices') j.SendSSE 'price' j.FormatSSE quote ⍝ broadcast`<br>`(j.SSEConnections '') j.SendSSE '' ⍝ keep-alive comment to every stream`|
|Notes|<ul><li>`targets j.SendSSE 'hello'` and `targets j.SendSSE j.FormatSSE 'hello'` send the same thing.</li><li>Each call sends the event to each target in a single operation. If several threads (for example, your code and the heartbeat) send to the same stream at the same time, their events don't get mixed up.</li><li>To send events from code that runs outside any request, such as a timer thread, keep a reference to the `Jarvis` instance. A monadic [`AppInitFn`](./settings-hooks.md#appinitfn) receives it as its right argument.</li></ul>|

### `SSEConnections`
|--|--|
|Description|`SSEConnections` returns the names of the open SSE connections, either all of them or those for particular endpoints.|
|Syntax|`r←j.SSEConnections endpoints`|
|`endpoints`|One of:<ul><li>`''` - every open SSE connection</li><li>one or more SSE endpoint names, in any of the forms that [`SSEEndpoints`](./settings-sse.md#sseendpoints) accepts (for example `'prices'`, `'/prices'`, `'prices, alerts'` or `'prices' 'alerts'`) - the connections for those endpoints</li></ul>|
|`r`|A vector of connection names, suitable as the left argument to [`SendSSE`](#sendsse). A name that isn't an SSE endpoint matches no connections.|
|Examples|`(j.SSEConnections 'prices') j.SendSSE 'price' j.FormatSSE quote`<br>`≢j.SSEConnections '' ⍝ number of open streams`|
|Notes|<ul><li>Before the server is started, and after it's stopped, `r` is empty.</li><li>A connection can close at any time, so the list may be out of date by the time you use it. That's safe: `SendSSE` checks each connection again, and returns `¯1` for any that have closed.</li></ul>|

### `FormatSSE`
|--|--|
|Description|`FormatSSE` formats one Server-Sent Event, ready to send with [`SendSSE`](#sendsse). It's a shared method, so you can call it as `Jarvis.FormatSSE` or through an instance (`j.FormatSSE`, `req.Server.FormatSSE`).|
|Syntax|`r←{fields} Jarvis.FormatSSE data`|
|`data`|The event's `data:` lines. One of:<ul><li>a character vector. Any line breaks (CR, LF or CRLF) split it into several `data:` lines; the client joins them again with LF.</li><li>a character matrix - one line per row</li><li>a vector of character vectors - one line per element</li><li>any other array (for example a number, a numeric vector or a namespace) - sent as JSON, using `1 ⎕JSON` with `HighRank` set to `'Split'`</li><li>empty - no `data:` lines</li></ul>|
|`fields`|[optional] The event's other fields. One of:<ul><li>a namespace with any of the variables `event` (the event type), `id` (the event id) and `retry` (the client's reconnection delay, in milliseconds)</li><li>a character vector - the event type</li><li>a vector of up to three values - event type, id and retry</li></ul>Empty values are left out, and so is a `retry` value that isn't a non-negative integer. Line breaks are removed from field values.|
|`r`|One complete event: a character vector of SSE lines, ending with a blank line. If there are no fields and no data, `r` is a `:` comment, which is useful as a keep-alive.|
|Examples|<pre style="font-family:APL">      Jarvis.FormatSSE 'hello'<br/>data: hello<br/><br/>      'tick' Jarvis.FormatSSE 'line 1' 'line 2'<br/>event: tick<br/>data: line 1<br/>data: line 2<br/><br/>      q←⎕NS '' ⋄ q.price←101.5<br/>      ('update' 42 3000) Jarvis.FormatSSE q<br/>event: update<br/>id: 42<br/>retry: 3000<br/>data: {"price":101.5}<br/></pre>|
|Notes|<ul><li>In the browser, an event without an `event:` field goes to the `onmessage` handler (event type `message`). A named event goes to a listener for that type, for example:<pre>source.addEventListener("update", e =&gt; {<br/>  const quote = JSON.parse(e.data);   // {"price":101.5}<br/>  console.log(e.lastEventId);         // "42"<br/>});</pre></li><li>Browsers don't deliver an event that has no `data:` lines. So if you send an event with only fields, give it some data.</li></ul>|

### `IsSSEText`
|--|--|
|Description|`IsSSEText` reports whether text is made up of one or more complete SSE events. [`SendSSE`](#sendsse) uses it to decide whether a payload needs formatting. It's a shared method.|
|Syntax|`r←Jarvis.IsSSEText text`|
|`text`|The text to check.|
|`r`|`1` if `text` is a simple character vector made up of one or more complete SSE events, otherwise `0`. To count as complete events:<ul><li>Every line must be a comment (starting with `:`) or a `data`, `event`, `id` or `retry` field. A `retry` value must be an integer.</li><li>The text must end with a blank line. That is, the last event ends with two line breaks.</li></ul>CR, LF and CRLF line breaks are all accepted.|
|Examples|`Jarvis.IsSSEText 'data: hello',⎕UCS 10 10 ⍝ 1`<br>`Jarvis.IsSSEText 'data: hello' ⍝ 0: no blank line at the end`<br>`Jarvis.IsSSEText 'foo: bar',⎕UCS 10 10 ⍝ 0: unknown field`|
|Notes|<ul><li>`IsSSEText ''` is `1`.</li><li>A line with any other field name (for example `foo: bar`) is valid SSE, and browsers ignore it, but `IsSSEText` returns `0`. As a result, `SendSSE` would wrap the whole text in `data:` lines.</li><li>Similarly, text that looks like an event but doesn't end with a blank line, such as `'data: hello'`, is sent as the data `data: hello`.</li><li>To be sure an event is sent as you intend, build it with `FormatSSE`.</li></ul>|

## Heartbeats

Every [`SSEHeartbeatInterval`](./settings-sse.md#sseheartbeatinterval) seconds (30 by default), `Jarvis` sends a `:` comment to every open SSE stream. Heartbeats keep proxies from closing streams that are idle, and they find clients that have disconnected without `Jarvis` noticing: if a heartbeat can't be sent, that connection is closed. Browsers don't pass comments to the page.

Set `SSEHeartbeatInterval←0` to turn heartbeats off. You can still send your own keep-alives with `targets j.SendSSE ''`.

## Reconnecting and `Last-Event-ID`

If a stream drops, for example because the network fails or the server restarts, `EventSource` reconnects by itself after a few seconds. You can set the delay, in milliseconds, with an event's `retry` field.

When it reconnects, the browser sends a `Last-Event-ID` header with the `id` of the last event it received, if any. Your endpoint function can read it with `req.GetHeader 'last-event-id'` and send the events the client missed. `Jarvis` doesn't keep past events: what to replay, and where to keep the events and ids, is up to your application. If the ids must stay valid across server restarts, keep them somewhere outside the workspace.

`EventSource` doesn't reconnect after a response that isn't `200` with `Content-Type: text/event-stream`. For example, a rejected request (401, 405 and so on) stops it for good. Closing the stream from the server (with a non-zero result from the endpoint function) is not an error, so the browser reconnects. To stop a client from reconnecting, call `source.close()` in the page, for example when it receives an event you've named for this purpose.

## Authentication and sessions

`EventSource` can't add headers to its request. So a browser client can't send an `Authorization` header or a session id header such as the one named by [`SessionIdHeader`](./settings-session.md#sessionidheader). Options include:

- Cookies, which the browser sends automatically. For sessions, set [`SessionUseCookie←1`](./settings-session.md#sessionusecookie). For a cross-origin stream, create the `EventSource` with `{withCredentials: true}`, and set [`CORS_Origin`](./settings-cors.md#cors_origin) to the page's origin (or `1`) rather than `'*'`.
- A token in the query string (`events?token=…`), checked in your `AuthenticateFn` with `req.QueryParams`. Remember that URLs tend to be logged.

Clients other than browsers (for example `curl` or an APL HTTP client) can send any headers.

## Things to bear in mind

- Each open stream is a connection that stays open. Over HTTP/1.1, browsers allow only about six connections to the same server, shared by every tab. If a user opens many tabs, each with its own stream, other requests to your service can stall. Use one stream per page, with named events for different kinds of updates.
- Conga supports HTTP/1.x only, so the HTTP/2 multiplexing that avoids this limit isn't available.
- Some proxies buffer responses, which delays events. `Jarvis` sends `X-Accel-Buffering: no` for nginx; other proxies may need their own configuration.
- `Jarvis` doesn't queue events for slow clients. Each `SendSSE` hands the event to Conga at once.

## Sample

`Samples/SSE` in the `Jarvis` repository is a complete example: a page showing a live server clock and a shared chat. It shows:

- an endpoint function that greets each client and reads `Last-Event-ID`
- a thread started by `AppInitFn` that broadcasts a named `tick` event every second
- an ordinary JSON endpoint that broadcasts `chat` events to every stream

See the sample's `README.md` for how to run it.
