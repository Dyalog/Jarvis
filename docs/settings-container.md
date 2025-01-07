Most Jarvis configuration options should be set using a Jarvis configuration file. A few environment variables are particularly useful in the context of running Jarvis in a container.


### `DYALOG_JARVIS_PORT`
|--|--|
|Description|If set, `DYALOG_JARVIS_PORT` is the port that the **Jarvis** container will listen on. It overrides both the `Jarvis` default and any port specified in the `Jarvis` configuration.|
|Default|`''`|
|Examples|`DYALOG_JARVIS_PORT=8888`|
|Notes|`DYALOG_JARVIS_PORT` allows you to specify different port numbers for each instance of the **Jarvis** container.|

### `DYALOG_JARVIS_CODELOCATION`
|--|--|
|Description|If set, `DYALOG_JARVIS_CODELOCATION` is the path to a folder containing your `Jarvis` endpoint code.|
|Default|`''`|
|Examples|`DYALOG_JARVIS_CODELOCATION=/myJarvisApp` |

### `DYALOG_JARVIS_THREAD`
|--|--|
|Description|`DYALOG_JARVIS_THREAD` controls which thread `Jarvis` will run on. Valid values are:<ul><li>`0` - run in thread 0</li><li>`1` - run in a separate thread, use `⎕TSYNC` to wait for result from `Server` thereby preventing from starting and then immediately signing off</li><li>`'debug'` - run in a separate thread, return thread 0 to immediate execution</li><li>`''` or `'auto'` - if running with an interactive terminal, use `'debug'` otherwise use `1`</li></ul> |
|Default|`''`|
|Examples|`DYALOG_JARVIS_THREAD=1`|
|Notes|If you need to debug your **Jarvis** service in a container, you can configure Dyalog to use [RIDE](https://dyalog.github.io/ride/) and set `DYALOG_JARVIS_THREAD` to any of `debug`, `''` or `'auto'` to remotely access your **Jarvis** service.|