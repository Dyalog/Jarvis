These settings apply when using Jarvis's JSON paradigm.

### `AllowFormData`
|--|--|
|Description|`AllowFormData` controls whether `Jarvis` will accept requests with a content-type of `'multipart/form-data'`. This makes it more convenient when using a form in a web browser as the client or to upload a file. Valid settings are:<ul><li>`1` - allow content-type `'multipart/form-data'`</li><li>`0` - Do not allow content-type `'multipart/form-data'`|
|Default|`0`|
|Examples|`j.AllowFormData←1 ⍝ enable multipart/form-data content`|

### `AllowGETs`
|--|--|
|Description|`AllowGETs` controls whether `Jarvis` will accept HTTP GET requests to call endpoints. Normally, `Jarvis` will accept only HTTP POST requests to access an endpoint, but there may be cases when it's convenient to all simple requests using HTTP GET. Valid settings are:<ul><li>`0` - do not allow HTTP GET requests</li><li>`1` - allow HTTP GET requests</li></ul>|
|Default|`0`|
|Examples|`j.AllowGETs←1 ⍝ accept GET requests`|
|Notes|Parameters to the endpoint being called should be specified using URL-encoded properly formatted JSON in the URL query string.  For instance, if you have a `sum←+/` endpoint and you want to sum the array `[1,2,3]`, you would need to use the endpoint and query string `/sum?%5B1%2C2%2C3%5D` (which is URL-encoded `/sum?[1,2,3]`).| 

### `HTMLInterface`
|--|--|
|Description|`HTMLInterface` controls whether and how `Jarvis` will provide an HTML interface. Valid settings are:<ul><li>`0` - do not enable the HTML interface</li><li>`1` - enable the Jarvis's built-in HTML interface</li><li>`'path'` - a character vector naming a folder (or file) that contains the HTML content to serve. If `'path'` is a folder name, `Jarvis` will look for a file named "index.html" in that folder.</li><li>`'' 'function'` - where `function` is the name of a monadic, result-returning function. The function is passed the [`Request`](./request.md) object and should return HTML content.|
|Default|`1` if using JSON mode, `0` otherwise|
|Examples|`j.HTMLInterface←'/myjarvis/web/' ⍝ HTML content is in the folder /myjarvis/web/`|

### `JSONInputFormat`
|--|--|
|Description|`JSONInputFormat` controls the format of the request's JSON payload when converted to APL. Valid settings are:<ul><li>`'D'` - return the payload as data</li><li>`'M'` - return the payload in a matrix format.</li></ul>These settings are the same as the `'Format`' option for `⎕JSON`.|
|Default|`D`|
|Examples|`j.JSONInputFormat←'M' ⍝ use the matrix inport format for ⎕JSON`|
|Notes|`JSONInputFormat` also has effect when using Jarvis`s REST paradigm if [`ParsePayload`](./settings-rest.md#parsepayload) is set to `1`.|

### `Report404InHTML`
|--|--|
|Description|When a requested endpoint is not found, `Jarvis` will always respond by setting the response HTTP status code to `404` and HTTP status message to `'Not Found'`.  `Report404InHTML` controls whether `Jarvis` will also return a simple "not found" HTML page in its response payload. This is potentially useful when the client is a web browser. Valid settings are:<ul><li>`1` - return a simple HTML page in the response payload indicating the requested endpoint was not found.  This is useful when the client connecting to `Jarvis` is a web browser.</li><li>`0` - Do not return any information in the response payload.|
|Default|`1`|
|Examples|`j.Report404←0 ⍝ disable sending the "not found" HTML page`|
|Notes|`Report404InHTML` has effect only if the [`HTMLInterface`](.settings-json.md) is enabled.|