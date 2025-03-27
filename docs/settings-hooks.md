"Hook" functions are functions you write to inject custom behavior at specific points in `Jarvis`'s execution. You then assign the name of the function to the appropriate "hook". Hook functions can be located in `#.CodeLocation` - `Jarvis` will exclude them from being considered as endpoint functions. By default, no hook functions are defined; you need to define only the hook functions, if any, that are needed for your web service.

### `AppCloseFn`
|--|--|
|Description|`AppCloseFn` is the name of the niladic, function to be called when `Jarvis` is stopped. This function could do things like closing database connections, managing log files, etc. The function may return a 2-element array of `(rc msg)` where `rc` is an integer return code (`0` means "okay") and `msg` is a character vector message. If the function does not return a result, the `Jarvis` will return the return code and message that was set prior to calling `AppCloseFn`.|
|Default|`''`|
|Examples|`j.AppCloseFn←'ShutDown'`|

### `AppInitFn`
|--|--|
|Description|`AppInitFn` is the name of the monadic, result-returning function to be called when `Jarvis` is started. This function is called before `Jarvis` starts listening for requests. This function could do things like establishing database connections or other application initialization. The function should return a 2-element array of `(rc msg)` where `rc` is an integer return code (`0` means "okay") and `msg` is a character vector message. If the function is monadic, its right argument is a reference to the `Jarvis` instance.|
|Default|`''`|
|Examples|`j.AppInitFn←'Startup'`|
|Notes|If your function returns a non-`0` return code, `Jarvis` will exit.|

### `AuthenticateFn`
|--|--|
|Description|`AuthenticateFn` is the name of monadic, result-returning function to be called when you need to authenticate a request. The right argument to the function is the [`Request`](./request.md) instance. The function result should either be:<ul><li>`0` - meaning that authentication was successful or that no authentication was necessary for this request</li><li>`1` = meaning that authentication failed in which case `Jarvis` will fail the request with an HTTP status code of 401 (Unauthorized).</li></ul>|
|Default|`''`|
|Examples|`j.AuthenticateFn←'Authenticate'`|
|Notes|See [Authentication](./security.md#authentication) for more information about how to authenticate an HTTP request.|

### `PostProcessFn`
|--|--|
|Description|`PostProcessFn` is the name of monadic, non-result-returning function to be called *after* your endpoint has run but *before* the response is sent to the client. The right argument to the function is the [`Request`](./request.md) instance. The function should not return a result however, if it does, that result is ignored.<br>If you have some treatment that you need to apply to every response, `PostProcessFn` can be used to avoid having to add that treatment to every endpoint.|
|Default|`''`|
|Examples|`j.PostProcessFn←'PostProcess'`<br><br>&emsp;&emsp;&emsp;`∇ PostProcess req`<br>`[1]    'custom-header'req.SetHeader'some value' ⍝ add a custom header`<br>`[2]    req.Reponse.Payload.Message←'Have a nice day!' ⍝ modify the payload`<br>&emsp;&emsp;&emsp;`∇`|



### `SessionInitFn`
|--|--|
|Description|`SessionInitFn` is the name of a monadic, result-returning function that can perform session initialization if your web service is using sessions. The right argument is the [`Request`](./request.md) instance, which we'll call `req`. The reference to the session namespace is `req.Session`. The integer function result should be either:<ul><li>`0` - indicating that the session was successfully initialized</li><li>non-`0` - indicating session initialization failed; in which case `Jarvis` will fail the request with an HTTP status code of 500 ().</li></ul>|
|Default|`''`|
|Examples|`j.SessionInitFn←'InitSession`|
|Notes|See [Using Sessions](./sessions.md) for more information.|

### `ValidateRequestFn`
|--|--|
|Description|`ValidateRequestFn` is the name of a monadic, result-returning function that will be called for every request that `Jarvis` receives. `ValidateRequestFn` gives you the opportunity to perform additional validation on a request. The right argument is the [`Request`](./request.md) instance. The function result should either be:<ul><li>`0` - meaning that validation was successful or that no validation was necessary for this request</li><li>`1` = meaning that validation failed in which case `Jarvis` will fail the request with an HTTP status code of 400 (Bad Request).</li></ul>|
|Default|`''`|
|Examples|`j.ValidateRequestFn←'Validate'`|
|Notes|See [Validation](./security.md#validation) for more information.|