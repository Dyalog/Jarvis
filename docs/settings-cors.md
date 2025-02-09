CORS, or Cross-Origin Resource Sharing, is a security feature implemented by web browsers to control how resources on a web page can be requested from another domain outside the domain from which the resource originated. It helps prevent malicious websites from accessing sensitive data on other websites.

When a web page makes a request to a different domain (cross-origin request), the browser checks if the server allows such requests by looking at the CORS headers in the server's response. If the headers indicate that the request is allowed, the browser permits the resource to be accessed; otherwise, it blocks the request.

CORS is essential for enabling secure communication between different web applications and APIs while protecting users from potential security risks.

Without modification, Jarvis's default CORS settings will allow most CORS requests. For more information about CORS, see [CORS](https://developer.mozilla.org/docs/Web/HTTP/CORS).

### `EnableCORS`
|--|--|
|Description|`EnableCORS` is a Boolean setting which enables or disables CORS support in `Jarvis`. Valid values are:<ul><li>`0` - disable CORS support</li><li>`1` - enable CORS support</li></ul>|
|Default|`1`|
|Examples|`j.EnableCORS←0 ⍝ disable CORS support`|

### `CORS_Origin`
|--|--|
|Description|`CORS_Origin` specifies the domains from which requests are allowed. Valid values are:<ul><li>`'*'` to allow requests from all domains</li><li>`1` - to "reflect" whatever origin is specified in the request's "origin" header</li><li>a domain from which requests will be accepted</li></ul>|
|Default|`'*'` - requests from all domains are allowed.|
|Examples|`j.CORS_Origin←'https://foo.example' ⍝ allow requests only from https://foo.example` |

### `CORS_Methods`
|--|--|
|Description|`CORS_Methods` controls which HTTP methods that will be allowed in cross-origin requests. Valid values are:<ul><li>`¯1`which means `Jarvis` will allow HTTP methods based on the paradigm being used:<ul><li>JSON - `'GET,POST,OPTIONS'`</li><li>REST - whatever methods you have specified in [`RESTMethods`](./settings-rest.md#restmethods)</li></ul></li><li>`1` which means allow the method specified in the request's `Access-Control-Request-Method` header</li><li>a comma-delimited list of methods to allow.</li></ul>|
|Default|`¯1`|
|Examples|`j.CORS_Methods←'GET,POST'`|
|Notes|This setting applies only to [preflighted requests](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS#preflighted_requests). You may also directly set the `Access-Control-Allow-Methods` header, which will override the `CORS_Methods` setting.|

### `CORS_Headers`
|--|--|
|Description|`CORS_Headers` controls what additional headers will be allowed in a CORS request. Valid values are:<ul><li>`'*'` which means any headers will be allowed</li><li>`1` which will allow any header names specified in the request's `Access-Control-Request-Headers` header </li><li>a string of comma-delimited header names</li></ul> is a comma-delimited string specifies what additional HTTP response headers will be exposed |
|Default|`'*'`|
|Examples|`j.CORS_Headers←'X-Custom-Header'`|
|Notes|By default, only the [CORS-safelisted response headers](https://developer.mozilla.org/en-US/docs/Glossary/CORS-safelisted_response_header) are exposed to the client. This setting applies only to [preflighted requests](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS#preflighted_requests). You may also directly set the `Access-Control-Allow-Headers` header, which will override the `CORS_Headers` setting.|

### `CORS_MaxAge`
|--|--|
|Description|`CORS_MaxAge` indicates, in seconds, how long the results of a preflight request can be cached.|
|Default|`60`|
|Examples|`j.CORS_MaxAge←600 ⍝ set to 10 minutes (600 seconds)`|
|Notes|This setting applies only to [preflighted requests](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS#preflighted_requests). You may also directly set the `Access-Control-Max-Age` header, which will override the `CORS_MaxAge` setting.|