Most of `Jarvis`' instance methods return a return code, `rc`, and a message, `msg`.

* `rc` is 0 to indicate success, a non-zero value indicates some error or warning condition
* `msg` is a (hopefully) meaningful message describing the success or error 

Below, the methods you are more likely to use are presented first.

### `Start`
|--|--|
|Description|`Start` starts or resumes a `Jarvis` instance.|
|Syntax|`(rc msg)←j.Start`|  
|Examples|<pre style="font-family:APL">      j.Start<br/>2025-09-01 @ 10.14.54.476 - Starting  Jarvis  1.20.6<br/>2025-09-01 @ 10.14.54.493 - Conga copied from C:\Program Files\Dyalog\Dyalog APL-64 20.0 Unicode/ws/conga<br/>2025-09-01 @ 10.14.54.494 - Local Conga v3.6 reference is #.Jarvis.[LIB]<br/>2025-09-01 @ 10.14.54.499 - Jarvis starting in "JSON" mode on port 8080<br/>2025-09-01 @ 10.14.54.500 - Serving code in #<br/>2025-09-01 @ 10.14.54.506 - Click http://192.168.223.137:8080 to access web interface<br/>0  Server started</pre>|

### `Stop`
|--|--|
|Description|`Stop` stops a running `Jarvis` instance.|
|Syntax|`(rc msg)←j.Stop`|  
|Examples|<pre style="font-family:APL">      j.Stop<br/>2025-09-01 @ 10.54.24.701 - Stopping server...<br/>0  Server stopped <br/><br/>     j.Stop ⍝ try stopping a stopped server<br/>¯1  Server is not running </pre>|

### `Config`
|--|--|
|Description|`Config` returns all of the settings for a `Jarvis` instance.|
|Syntax|`r←j.Config`|  
|`r`|is a 2-column matrix of `[;1]` setting names, `[;2]` setting values.|
|Examples|<pre style="font-family:APL">       j.Config<br/> AcceptFrom</br/> AllowFormData                                               0 <br/> AllowGETs                                                   0 <br/> AppCloseFn<br/> AppInitFn<br/> AuthenticateFn<br/> BufferSize                                              10000 <br/> CORS_Headers                                                * <br/> CORS_MaxAge                                                60 <br/> CORS_Methods                                 GET,POST,OPTIONS <br/> ORS_Origin                                                 * <br/> ... and so on and so forth</pre>|
|Notes|At present, there are about 60 settings that are displayed.|

### `EndPoints`
|--|--|
|Description||
|Syntax||  
|``||
|Examples||
|Notes||

### `Pause`
|--|--|
|Description|`Pause` "pauses" a running `Jarvis` instance. Pausing causes `Jarvis` to refuse any new connections. Existing connections will continue to be served. The [`Start`](#start) method will "unpause" a paused `Jarvis`.|
|Syntax|`(rc msg)←j.Pause`|  
|Examples|<pre style="font-family:APL">      j.Pause<br/>2025-09-01 @ 10.57.13.275 - Pausing server...<br/>0  Server paused <br/>      j.Pause ⍝ try pausing a paused server<br/>¯2  Server is already paused <br/>      j.Start ⍝ restart a paused server<br/>2025-09-01 @ 11.03.31.296 - Starting  Jarvis  1.20.6<br/>0  Server resuming operations <br/>      j.Stop<br/>2025-09-01 @ 10.58.36.630 - Stopping server...<br/>0  Server stopped <br/>      j.Pause ⍝ try pausing a stopped server<br/>¯1  Server is not running </pre>|
|Notes||

### `Running`
|--|--|
|Description|`Running` returns a `1` if `Jarvis` is running or paused, `0` otherwise.|
|Syntax|`r←j.Running`|  

### `Thread`
|--|--|
|Description|`Thread` returns the thread number if the server is running or `⍬` if the server is not running.|
|Syntax|`thread←j.Thread`|  

### `Log`
|--|--|
|Description|`Log` is an overridable method used to log messages. By default if [`Logging`](./settings-operational.md#logging) is set to `1` the message passed as the right argument is displayed with a timestamp in the APL session.|
|Syntax|`{msg}←{level}Log msg`|  
|`msg`|The message to be displayed. This is also returned as the shy result.|
|`level`|(optional) The message level. This is not used in the default `Log` method, but is included so that an overriding method can make use of it to distinguish between different types of messages, for instance informational, warning, and error messages.|
|Examples|To use `Log` from an endpoint, you need to use the [reference to the `Jarvis` server](./request.md#server) that is supplied in the [Request](./request.md) object. One might write something like<br/><pre style="font-family:APL">req.server.Log 'Endpoint "',(⊃⎕SI),'" called'</pre> to log whenever an endpoint is called.|
|Notes|We intend to implement more comprehensive logging in a future release of **Jarvis**.|

### `Reset`
|--|--|
|Description|`Reset` "resets" `Jarvis` by killing all `Jarvis`-related threads and clearing any session information. `Reset` does not affect any `Jarvis` settings.|
|Syntax|`(rc msg)←j.Reset`|  
|Examples|<pre style="font-family:APL">      j.Reset<br/>0  Server reset (previously set options are still in effect)</pre>|
|Notes|`Reset` is rarely needed but can be useful during endpoint development.|
