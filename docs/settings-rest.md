These settings apply when using **Jarvis**'s REST paradigm.

### `ParsePayload`
|--|--|
|Description|`ParsePayload` controls whether `Jarvis` automatically convert JSON and XML request payload to an APL format using either `⎕JSON` or `⎕XML` as appropriate.Valid settings are:<ul><li>`1` - convert JSON and/or XML payloads</li><li>`0` - do not convert JSON and/or XML payloads</li></ul>|
|Default|`1` - parse JSON and XML payloads|
|Examples|`j.ParsePayload←0 ⍝ do not parse JSON and XML payloads`|
|Notes|The format for parsed JSON payloads is controlled by [`JSONInputFormat`](./settings-json.md#jsoninputformat).|

### `RESTFailProcessing`
|--|--|
|Description|`RESTFailProcessing` controls whether `Jarvis` applies its normal response processing to a **failed** REST request — one whose response status is not in the 2xx (success) range. That processing is: setting the response content-type to [`DefaultContentType`](./settings-operational.md#defaultcontenttype) if the handler didn't set one, and converting the response payload to JSON when the content-type is `application/json`. Valid settings are:<ul><li>`0` - on a non-2xx response, skip this processing and leave the response payload and headers exactly as the handler (or the error) left them</li><li>`1` - process the response payload "as normal" even for a non-2xx response</li></ul>|
|Default|`0`|
|Examples|`j.RESTFailProcessing←1 ⍝ format error responses like successful ones`|
|Notes|Successful (2xx) responses are always processed; this setting affects only error responses. [`PostProcessFn`](./settings-hooks.md#postprocessfn) runs before this step regardless of the setting. This setting applies only in the REST paradigm.|

### `RESTMethods`
|--|--|
|Description|`RESTMethods` specifies which HTTP methods will be supported by your REST web service. It is a comma-delimited character vector of HTTP method names and optionally, the name of the APL function that will service that HTTP method. Each comma-delimited segment consists of a case-insensitive HTTP method name (`'get' 'GET' 'gEt'` will all match GET). The method name can be optionally followed by a `'/'` and the function name which implements the handler for that HTTP method. If no function name is supplied, the function name will be the case-sensitive HTTP method. |
|Default|`'Get,Post,Put,Delete,Patch,Options'`|
|Examples|`j.RESTMethods←'Get,post/handlePOST'`<br>In this example our service will accept HTTP GET and POST requests.<ul><li>GET requests will be by a function named `Get`</li><li>POST requests will be handled by a function called `handlePOST`.</li></ul>|
|Notes|**Jarvis** does not place a restriction on the HTTP method names, meaning that you could potentially invent your own "HTTP" methods.<br>`j.RESTMethods←'Get,Bloofo' ⍝ allow GET and BLOOFO`.|