These settings apply when using **Jarvis**'s REST paradigm.

### `ParsePayload`
|--|--|
|Description|`ParsePayload` controls whether `Jarvis` automatically convert JSON and XML request payload to an APL format using either `⎕JSON` or `⎕XML` as appropriate.Valid settings are:<ul><li>`1` - convert JSON and/or XML payloads</li><li>`0` - do not convert JSON and/or XML payloads</li></ul>|
|Default|`1` - parse JSON and XML payloads|
|Examples|`j.ParsePayload←0 ⍝ do not parse JSON and XML payloads`|
|Notes|The format for parsed JSON payloads is controlled by [`JSONInputFormat`](./settings-json.md#jsoninputformat).|

### `RESTMethods`
|--|--|
|Description|`RESTMethods` specifies which HTTP methods will be supported by your REST web service. It is a comma-delimited character vector of HTTP method names and optionally, the name of the APL function that will service that HTTP method. Each comma-delimited segment consists of a case-insensitive HTTP method name (`'get' 'GET' 'gEt'` will all match GET). The method name can be optionally followed by a `'/'` and the function name which implements the handler for that HTTP method. If no function name is supplied, the function name will be the case-sensitive HTTP method. |
|Default|`'Get,Post,Put,Delete,Patch,Options'`|
|Examples|`j.RESTMethods←'Get,post/handlePOST'`<br>In this example our service will accept HTTP GET and POST requests.<ul><li>GET requests will be by a function named `Get`</li><li>POST requests will be handled by a function called `handlePOST`.</li></ul>|
|Notes|**Jarvis** does not place a restriction on the HTTP method names, meaning that you could potentially invent your own "HTTP" methods.<br>`j.RESTMethods←'Get,Bloofo' ⍝ allow GET and BLOOFO`.|