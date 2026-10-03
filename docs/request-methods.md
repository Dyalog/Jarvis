### `AddHeader`

|--|--|
|Description|`AddHeader` adds an HTTP response header, but only if a header with that name is not already set. (Use `SetHeader` to set a header unconditionally, replacing any existing value.)|
|Syntax|`{(name value)}←name req.AddHeader value`|
|`name`|The header name.|
|`value`|The header value to add if the header isn't already present.|
|Notes|Returns the header's name and its resulting value — the value just added, or the existing value if the header was already set. `Jarvis` uses `AddHeader` to set the default Server-Sent Event response headers, which an application's [`ValidateRequestFn`](./settings-hooks.md#validaterequestfn) can therefore pre-empt.|

### `GetHeader`

|--|--|
|Description|`GetHeader` returns the value of a named request header (or `''` if there is no such header). Header names are matched case-insensitively.|
|Syntax|`r←{table} req.GetHeader name`|
|`name`|The header name to look up.|
|`table`|(optional) a 2-column name/value matrix to search instead of the request's own headers — for example the response headers, `req.Response.Headers`.|
|Examples|`req.GetHeader 'content-type'`<br>`req.(Response.Headers GetHeader 'content-type')`|

### `SetHeader`

|--|--|
|Description|`SetHeader` sets a response header, adding it (or appending another header of the same name). Use [`AddHeader`](#addheader) to set one only if it isn't already present.|
|Syntax|`{(name value)}←name req.SetHeader value`|
|`name`|The header name.|
|`value`|The header value.|

### `DefaultHeader`

|--|--|
|Description|`DefaultHeader` sets a response header only if no header of that name is already set. (Like [`AddHeader`](#addheader), but it returns no result.)|
|Syntax|`name req.DefaultHeader value`|

### `SetContentType`

|--|--|
|Description|`SetContentType` is a shortcut that sets the response's `Content-Type` header.|
|Syntax|`{(name value)}←req.SetContentType contentType`|
|Examples|`req.SetContentType 'text/csv; charset=utf-8'`|

### `GetCookie`

|--|--|
|Description|`GetCookie` returns the value of a named request cookie (or `''` if there is none).|
|Syntax|`value←req.GetCookie name`|
|Notes|The request's cookies are also available as the [`Cookies`](#cookies) matrix.|

### `SetCookie`

|--|--|
|Description|`SetCookie` adds a `Set-Cookie` response header for a named cookie.|
|Syntax|`{(name cookie)}←name req.SetCookie cookie`|
|`name`|The cookie name.|
|`cookie`|The cookie value, optionally followed by `;`-delimited cookie attributes (for example `'abc123; Path=/; HttpOnly'`).|

### `SetStatus`

|--|--|
|Description|`SetStatus` sets the response's HTTP status code (and, optionally, status text). `Jarvis` fills in the standard reason phrase for the code; any text you supply is appended in parentheses.|
|Syntax|`{status}←{statusText} req.SetStatus status`|
|`status`|The HTTP status code.|
|`statusText`|(optional) extra text to append to the standard reason phrase.|
|Examples|`req.SetStatus 201`<br>`'created in archive' req.SetStatus 201`|
|Notes|To report a failure, [`Fail`](#fail) is usually more convenient.|

### `Fail`

|--|--|
|Description|`Fail` sets the response status (and message) for a failed request, when the status is non-zero. It returns `1` if it set a failure status, `0` otherwise, which makes it convenient to both set and test a condition in one expression.|
|Syntax|`{r}←{message} req.Fail status`|
|`status`|The HTTP status code. `0` means "no failure" — nothing is set and the result is `0`.|
|`message`|(optional) a status message. If omitted, a `500` status uses [`ErrorInfo`](#errorinfo); other statuses use the standard reason phrase.|
|Examples|`→0 If req.Fail 405×'GET'≢req.Method ⍝ 405 unless it's a GET`|

### `MakeURI`

|--|--|
|Description|`MakeURI` builds an absolute URI for a RESTful resource, using [`Hostname`](./settings-operational.md#hostname) and, by default, the request's own [`Endpoint`](#endpoint).|
|Syntax|`r←{endpoint} req.MakeURI resource`|
|`resource`|One or more resource path segments (joined with `/`).|
|`endpoint`|(optional) a base endpoint to use instead of the request's `Endpoint`.|
|Examples|`req.MakeURI 231 'invoice' 45`|

### `ContentTypeForFile`

|--|--|
|Description|`ContentTypeForFile` returns the content-type that matches a file's extension. Use it to set the content-type when you send a file in the response.|
|Syntax|`r←req.ContentTypeForFile filename`|
|`filename`|A file name or path, such as `'report.csv'` or `'/var/www/img/logo.png'`. You can also pass just the extension, with or without the leading `.` (`'.csv'` or `'csv'`).|
|`r`|The content-type, as a character vector. `text/html` is returned as `'text/html; charset=utf-8'`. If the extension isn't recognised, `r` is `'application/octet-stream'`.|
|Examples|`req.ContentTypeForFile 'report.csv' ⍝ text/csv`<br>`req.ContentTypeForFile 'index.html' ⍝ text/html; charset=utf-8`<br>`req.ContentTypeForFile 'data.xyz' ⍝ application/octet-stream`<br><br>Send a file with a matching content-type:<br>`req.SetContentType req.ContentTypeForFile file`<br>`req.Response.Payload←'' file`|
|Notes|<ul><li>`Jarvis` looks up the extension in its shared `ContentTypes` table, a 2-column matrix of `[;1]` extensions (without the `.`) and `[;2]` content-types. It covers almost 80 common types, including web formats (`html`, `css`, `js`, `json`, `svg`), images, audio, video, fonts, archives and office documents.</li><li>The lookup ignores case. `'REPORT.CSV'` returns `'text/csv'`.</li><li>Only the last extension counts. `'archive.tar.gz'` returns `'application/gzip'`.</li><li>`Jarvis` uses `ContentTypeForFile` itself to set the content-type when it serves files from the [`HTMLInterface`](./settings-json.md#htmlinterface) folder.</li></ul>|

### `Config`

|--|--|
|Description|`Config` returns the request's fields as a 2-column name/value matrix — useful when debugging an endpoint.|
|Syntax|`r←req.Config`|

### `ErrorInfo`

|--|--|
|Description|`ErrorInfo` returns a description of the most recent APL error, trimmed to the request's [`ErrorInfoLevel`](./settings-operational.md#errorinfolevel). `Fail 500` uses it by default.|
|Syntax|`r←req.ErrorInfo`|
