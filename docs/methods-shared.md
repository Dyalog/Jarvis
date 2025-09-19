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

