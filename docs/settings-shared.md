Shared settings are shared between all instances of `Jarvis` in the workspace.

### `LDRC`
|--|--|
|Description|`LDRC` is a reference to the initialized Conga library. It can be used to access Conga functions. See the [Conga User Guide](https://docs.dyalog.com/latest/Conga%20User%20Guide.pdf) for more information on Conga's functions.|
|Default|`LDRC` is initially `''` and is set by `Jarvis` to the Conga library reference upon initialization.|
|Examples|`j.LDRC.Names '.'`|
|Notes|You should not attempt to set `LDRC` yourself.|

### `CongaPath`
|--|--|
|Description|`CongaPath` is a pathname to the folder pathname used to tell `Jarvis` where to look for either the Conga workspace or the Conga shared libraries.|
|Default|`''`|
|Examples|`Jarvis.CongaPath←'c:\myapp\Conga\'`|
|Notes|See [Jarvis and Conga](./conga.md) for more information.| 

### `CongaRef`
|--|--|
|Description|`CongaRef` is a name of or reference to the `Conga` namespace in workspace.|
|Default|`''`|
|Examples|`Jarvis.CongaRef←#.MyApp.Conga`|
|Notes|See [Jarvis and Conga](./conga.md) for more information| 
