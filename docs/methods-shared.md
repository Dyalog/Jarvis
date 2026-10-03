### `New`
|--|--|
|Description|`New` creates a new instance of the **Jarvis** class.|
|Syntax|`j←Jarvis.New args`|  
|`args`|One of:<ul><li>`''` - create a **Jarvis** instance with the default configuration</li><li>a character vector full path name to one of<ul><li>a JSON or JSON5 file containing a [JarvisConfig](./settings-operational.md#jarvisconfig) definition</li><li>a file containing a namespace or class script that will be loaded as [CodeLocation](./settings-operational.md#codelocation)</li><li>a folder containing files with code that will be loaded into `j.CodeLocation`</li></ul><li>a reference to a namespace containing named **Jarvis** configuration settings</li><li>a vector of up to 4 positional settings<ul><li>[`Port`](./settings-conga.md#port)</li><li>[`CodeLocation`](./settings-operational.md#codelocation)</li><li>[Paradigm](./settings-operational.md#paradigm)</li><li>[`JarvisConfig`](./settings-operational.md#jarvisconfig)</li></ul></li></ul>|
|`j`|A reference to the newly created **Jarvis** instance|
|Examples|`j←Jarvis.New 5000 #.MyEndpoints`  |
|Notes|With the introduction of APL Array Notation in Dyalog v20.0, namespace arguments are made even more convenient, for example: `j←Jarvis.New (Paradigm:'REST'⋄Port:12345)`|

### `Documentation`
|--|--|
|Description|`Documentation` displays a link to the online **Jarvis** documentation.|
|Syntax|`Jarvis.Documentation`|
|Example|&emsp;&emsp;&emsp;&ensp;`Jarvis.Documentation`<br/>`See https://dyalog.github.io/Jarvis`|

### `Version`
|--|--|
|Description|`Version` returns the `Jarvis` version|
|Syntax|`(what version date)←Jarvis.Version`|  
|`what`|is `'Jarvis'`|
|`version`|is the version number. For example: `'1.20.5'`|
|`date`|is the date when this version was created. For example: `'2025-08-17'`|


### `Run`
|--|--|
|Description|`Run` creates a new instance of the **Jarvis** class using [`Jarvis.New`](#new) and then calling the instance's [`Start`](./methods-instance.md#start)  method to start it.|
|Syntax|`(j (rc msg))←Jarvis.Run args`|  
|`args`|One of:<ul><li>`''` - create a **Jarvis** instance with the default configuration</li><li>a character vector full path name to one of<ul><li>a JSON or JSON5 file containing a [JarvisConfig](./settings-operational.md#jarvisconfig) definition</li><li>a file containing a namespace or class script that will be loaded as [CodeLocation](./settings-operational.md#codelocation)</li><li>a folder containing files with code that will be loaded into `j.CodeLocation`</li></ul><li>a reference to a namespace containing named **Jarvis** configuration settings</li><li>a vector of up to 4 positional settings<ul><li>[`Port`](./settings-conga.md#port)</li><li>[`CodeLocation`](./settings-operational.md#codelocation)</li><li>[Paradigm](./settings-operational.md#paradigm)</li><li>[`JarvisConfig`](./settings-operational.md#jarvisconfig)</li></ul></li></ul>|
|`(j (rc msg)`|`j` is a reference to the newly created **Jarvis** instance created by [`New`](#new)<br>`rc` and `msg` are the return code and message from [`Start`](./methods-instance.md#start)|
|Examples|`(j (rc msg))←Jarvis.New 5000 #.MyEndpoints`  |
|Notes|`Run` was primarily developed as a shortcut method for demos. The recommended technique is to call `New`, then make any additional configuration changes, and then call `Start` and check `rc` to verify that `Jarvis` was started.|

### `MyAddr`
|--|--|
|Description|`MyAddr` returns your machine's IP address on the local network.|
|Syntax|`addr←Jarvis.MyAddr`|  
|Examples|&emsp;&emsp;&emsp;&emsp;`Jarvis.MyAddr`<br>`192.168.1.223`|

### `FormatSSE`
|--|--|
|Description|`FormatSSE` builds one [Server-Sent Event](./sse.md), ready to send with [`SendSSE`](./methods-instance.md#sendsse). As a shared method it can be called on the class (`Jarvis.FormatSSE`) or through an instance (`j.FormatSSE`, `req.Server.FormatSSE`).|
|Syntax|`r←{fields} Jarvis.FormatSSE data`|  
|`data`|The event's `data:` lines: a character vector (line breaks split it into several `data:` lines), a character matrix (one line per row), a vector of character vectors (one line per element), or any other array (sent as JSON). Empty produces no data lines.|
|`fields`|(optional) the event's other fields: a namespace with any of `event`, `id` and `retry`; a character vector (the event type); or a vector of up to three values `event id retry`.|
|`r`|One complete event: a character vector of SSE lines ending with a blank line. If there are no fields and no data, `r` is a `:` comment (useful as a keep-alive).|
|Examples|<pre style="font-family:APL">      'tick' Jarvis.FormatSSE 'hello'<br/>event: tick<br/>data: hello<br/></pre>|
|Notes|See [Using Server-Sent Events](./sse.md#formatsse) for the full rules and more examples.|

### `IsSSEText`
|--|--|
|Description|`IsSSEText` reports whether its argument is a simple character vector made up of one or more complete SSE events. [`SendSSE`](./methods-instance.md#sendsse) uses it to decide whether a payload needs formatting with [`FormatSSE`](#formatsse).|
|Syntax|`r←Jarvis.IsSSEText text`|  
|`text`|The text to check.|
|`r`|`1` if `text` is a simple character vector of one or more complete SSE events (every line a comment or a `data`/`event`/`id`/`retry` field, ending with a blank line; CR, LF and CRLF accepted), otherwise `0`.|
|Examples|`Jarvis.IsSSEText 'data: hi',⎕UCS 10 10 ⍝ 1`<br>`Jarvis.IsSSEText 'data: hi'          ⍝ 0: no blank line at the end`|
|Notes|`IsSSEText ''` is `1`. See [`IsSSEText`](./sse.md#isssetext) for the edge cases.|

