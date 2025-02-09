### `CodeLocation`
|--|--|
|Description| Prior to starting a `Jarvis` instance, `CodeLocation` specifies where `Jarvis` will look for your endpoint code. `CodeLocation` can be any of:<ul><li>The name of or a reference to an existing namespace that contains your endpoint code.</li><li>A file path to a folder that contains your endpoint code. In this case, `Jarvis` will load the contents of the folder into the namespace `#.CodeLocation`, similar to how [LINK](https://dyalog.github.io/link) works.</li><li>The name of a file containing a namespace definition. In this case, `Jarvis` will use `⎕FIX` to load the namespace into `#` and set `CodeLocation` to a reference to the loaded namespace.</li></ul>After starting, `CodeLocation` is set to a reference to the namespace containing your endpoint code. |
|Default|`'#'`|
|Examples|`j.CodeLocation←#.myEndpoints               ⍝ reference to namespace` <br>`j.CodeLocation←'#.myEndpoints'             ⍝ name of namespace`<br>`j.Codelocation←'/home/me/myEndpoints'      ⍝ folder`<br>`j.CodeLocation←'/home/me/myEndpoints.apln' ⍝ file containing namespace definition` |
|Notes|If the environment variable `DYALOG_JARVIS_CODELOCATION` exists, it will override any other setting for `CodeLocation`.|

### `ConnectionTimeout`
|--|--|
|Description|`ConnectionTimeout` specifies the the amount of time in seconds that a connection may be idle before being closed. `Jarvis` will not close a connection that is currently being serviced by a long-running endpoint.|
|Default|`30`|
|Examples|`j.ConnectionTimeout←120 ⍝ 2 minute timeout`|
|Notes|`ConnectionTimeout` is used by `Jarvis`'s "housekeeping" to prevent inactive connections from accumulating.|

### `Debug`
|--|--|
|Description|Setting `Debug` to a non-zero value will enable various types of debugging and reporting to take place. The valid values for `Debug` are:<ul><li>`0` - all errors are trapped</li><li>`1` - stop when an untrapped error occurs in either the endpoint code or the **Jarvis** framework itself.</li><li>`2` - `Jarvis` will stop execution on the thread handling a request prior to any application code being executed.  This enables the user to debug their code "in situ".</li><li>`4` - `Jarvis` will stop execution on the thread handling a request once the the request is completely received. This is used mostly for tracing and debugging **Jarvis** itself.</li><li>`8` - `Jarvis` will display Conga events other than `'Timeout'` to the APL session.</li></ul>`Debug` values are additive. For example `9` would stop on any error as well as enable Conga event reporting are |
|Default|`0`|
|Examples|`j.Debug←2 ⍝ stop just before executing any user code`|
|Notes|While it is possible to set `Debug` to `¯1` to enable all forms of debugging, be mindful that additional values for `Debug` may be added in the future and this could lead to unintended behavior.|

### `DefaultContentType`
|--|--|
|Description|`DefaultContentType` specifies the HTTP content-type for `Jarvis`'s response if no content-type header has been specified by the user's endpoint code.|
|Default|`'application/json; charset=utf-8'`|
|Examples|`j.DefaultContentType←'application/xml; charset=utf-8'`|
|Notes|`DefaultContentType` should only be set when most of the responses from your endpoints will have a content-type other than `'application/json'`. For individual responses that use a different content-type, set `request.ContentType`.| 

### `ErrorLevelInfo`
|--|--|
|Description|`ErrorLevelInfo` specifies how much information to include in the HTTP status message when an untrapped error occurs and `Jarvis` returns an HTTP status code of 500. Valid settings are:<ul><li>`0` - do not include any information about the error</li><li>`1` - include the APL error name (for example `VALUE ERROR`)</li><li>`2` - include the function and line number where the error occurred.</li></ul>|
|Default|`1`|
|Examples|`j.ErrorInfoLevel←2 ⍝ include function name and line number`|

### `Hostname`
|--|--|
|Description|`Hostname` is the name of the host that `Jarvis` will insert into the "host" header of the response. If a response payload from `Jarvis` needs to include URLs pointing to other endpoints within the service, `Hostname` can be used to construct those URLS.|
|Default|`''` which means that `Jarvis` will use the result of `2 ⎕NQ # 'TCPGetHostID'` (the IP address of the server on the local network) |
|Examples|`j.Hostname←'www.myJarvis.com'`|
|Notes|`2 ⎕NQ # 'TCPGetHostID'` returns the IP address on the local network, which isn't of much use if the client is accessing `Jarvis` from an external network. `Hostame` exists to address this problem by providing an external address to `Jarvis`.|

### `HTTPAuthentication`
|--|--|
|Description|`HTTPAuthentication` indicates the HTTP authentication scheme that will be used to authenticate requests. Currently only HTTP Basic authentication is supported. Valid settings are:<ul><li>`'basic'` to enable HTTP Basic authentication</li><li>`''` to disable HTTP Basic authentication.|
|Default|`'basic'`|
|Examples|`j.HTTPAuthentication←'' ⍝ disable HTTP basic authentication`|
|Notes|See [HTTP Basic Authentication](./security.md) |

### `JarvisConfig`
|--|--|
|Description|`JarvisConfig` is the name of the JSON (or JSON5) file, if any, that contains your **Jarvis** configuration.|
|Default|`''`|
|Examples|`j.JarvisConfig←'/home/myapp/jarvisconfig.json`|
|Notes|If you specify a relative path to the **Jarvis** configuration file, `Jarvis` will consider it to be relative to the current working directory as returned by `1 ⎕NPARTS ''` 

### `LoadableFiles`
|--|--|
|Description|If `CodeLocation` specifies a folder from which to load your endpoints' code, `LoadableFiles` specifies a comma-delimited set of patterns to match when selecting files to load into workspace.|
|Default|`'*.apl?,*.dyalog'`|
|Examples|`j.LoadableFiles←'*.apln,*.aplf,*.aplc'`|
|Notes|Dyalog has evolved its "code in files" methodology. In its early days, the `.dyalog` extension was used almost exclusively. Over time, and with the advent of [`Link`](https://dyalog.github.io/link), the common practice is to the use of file extension to indicate the particular type of APL object contained within the file - `.aplf` for a function, `.apln` for a namespace, `.aplc` for a class, and `.apla` for an array.|

### `Logging`
|--|--|
|Description|`Logging` is a Boolean setting that determines whether `Jarvis` will display certain internal log messages to the session.|
|Default|`1`|
|Examples|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`j←Jarvis.New ''`<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`j.Start ⍝ default is Logging←1`<br>`2024-12-06 @ 11.34.23.890 - Starting  Jarvis  1.18.4`<br>`2024-12-06 @ 11.34.23.913 - Conga copied from C:\Program Files\Dyalog\Dyalog APL-64 19.0 Unicode/ws/conga`<br>`2024-12-06 @ 11.34.23.915 - Local Conga v3.5 reference is #.Jarvis.[LIB]`<br>`2024-12-06 @ 11.34.23.923 - Jarvis starting in "JSON" mode on port 8080`<br>`2024-12-06 @ 11.34.23.927 - Serving code in #`<br>`2024-12-06 @ 11.34.23.931 - Click http://192.168.223.134:8080 to access web interface`<br>`0  Server started`<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`j.Stop`<br>`2024-12-06 @ 11.34.35.564 - Stopping server...`<br>`0  Server stopped `<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`j.Logging←0 ⍝ turn off logging`<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`j.Start`<br>`0  Server started `|
|Notes|The messages controlled by `Logging` are internal, operational, messages.<br>Request and HTTP logging capabilities will be available in a forthcoming **Jarvis** release.|

### `Paradigm`
|--|--|
|Description|`Paradigm` specifies the mode in which `Jarvis` will operate. Current valid values are:<ul><li>`'JSON'` to use the [JSON Paradign](json.md)</li><li>`'REST`' to use the [REST Paradigm](./rest.md)</li></ul>|
|Default|`'JSON`|
|Examples|`j.Paradigm←'REST'`|
|Notes|You should set `Paradigm` before starting your `Jarvis` instance.|

### `UseZip`
|--|--|
|Description|`UseZip` is a Boolean that tells `Jarvis` whether to send a compressed response payload if the client will accept it as indicated by the "accept-encoding" header in the client request. Valid values are:<ul><li>`0` - do not compress the response payload</li><li>`1` use either "gzip" or "deflate" compression if the client will accept them|
|Default|`0`|
|Examples|`j.UseZip←1`|
|Notes|At present only "gzip" and "deflate" content-encodings are supported. [`ZipLevel`](#ziplevel) controls the level of compression employed.|

### `ZipLevel`
|--|--|
|Description|`ZipLevel` is an integer value between 0 and 9 and specifies the level of compression to use when `Jarvis` compresses the response payload (see [`UseZip`](#usezip)). Higher values result in a higher degree of compression albeit at the cost of performance.|
|Default|`3` which seems to provide the best trade-off of compression versus speed.|
|Examples|`j.ZipLevel←6`|