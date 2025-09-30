`Jarvis` uses Conga, Dyalog's TCP/IP utility library, for communications. In general most of `Jarvis`' default [Conga-related settings](./settings-conga.md) can be left unchanged.  The most likely setting you will want to change is the [port number](./settings-conga.md#port).

`Jarvis` requires Conga version 3.0 or later. Conga consists of two elements:

* Two shared library files whose names begin with "conga" and are found in the Dyalog installation folder. The names of the files varies based on the platform they are running on and the specific version of Conga; for instance `conga34_64.dll` and `conga34ssl64.dll` are the shared library files for Conga version 3.4 for the 64-bit version of Dyalog for Windows.
* An APL-based API to communicate with the shared libraries. There are two versions of the API both of which are available in the `conga` workspace.
    * A namespace named `Conga` which was introduced with Conga version 3.0 and implements behavior that makes it easier to run multiple Conga-based utilities in the same workspace. `Conga` is the recommended API version to use.
    * A namespace named `DRC` which is retained for backward-compatibility with applications which use earlier versions of Conga. `DRC` should only be used in an application where backward compatibility is necessary.

The Conga API looks for a matching version of the shared libraries; as such the version of the API and the shared libraries must be the same. For more information on Conga please refer to the [Conga User Guide](https://docs.dyalog.com/latest/Conga%20User%20Guide.pdf).

### Default Behavior
When first run, `Jarvis` will attempt to find or copy the Conga API and then initialize it. `Jarvis` will attempt to use the `Conga` version of the API in preference to the `DRC` version. In general, all of this is transparent to the user.

* Look in the current workspace for the Conga API:
    * First look in the namespace where `Jarvis` resides for a namespace named either `Conga` or `DRC`, in that order.
    * Failing that, look in the root namespace `#` for a namespace named either `Conga` or `DRC`, in that order.
* If neither version of the API is found in the current workspace, `Jarvis` will attempt to copy the API (first `Conga` then `DRC`) from the `conga` workspace. The API is copied into the `Jarvis` class which means there will be no additional footprint in workspace. `Jarvis` will attempt to copy the API as follows:
    * If the `DYALOG` environment variable exists, use its folder. Otherwise use the folder from the command line used to start Dyalog.
    * If that fails, then attempt to copy from the "current" folder as determined by `⊃1 ⎕NPARTS ''`
* If the API was found or successfully copied, `Jarvis` will initialize Conga as follows:
    * If the `Conga` version of the API is used, `Jarvis` will initialize it with a root name of `'Jarvis'`.
    * If the `DRC` version of the API is used, `Jarvis` will simply initialize it. As `DRC` does not support multiple roots, care should be taken if other Conga-using utilities also reside in the workspace.
* If the API was successfully initialized, a reference to the API root can be found in the shared [`LDRC`](./settings-shared.md#ldrc) field.

### Overriding Default Locations
There are two methods to tell `Jarvis`'s default behavior, both of which involve setting a shared public field in the `Jarvis` class.

* If you have the `Conga` namespace in your workspace in other than default locations the `Jarvis` will search, [`Jarvis.CongaRef`](./settings-shared.md#congaref) can be used to specify its location. `CongaRef` can be an actual reference to the namespace or a character array representing the location. For instance:<br>
`Jarvis.CongaRef←#.Utils.Conga` or<br>
`Jarvis.CongaRef←'#.Utils.Conga'`<br>
This can be useful when integrating `Jarvis` into an application that also uses Conga.
* [`Jarvis.CongaPath`](./settings-shared.md#congapath) can be used to specify the path to the shared library files and optionally the conga workspace. This can be useful when bundling `Jarvis` in a distributed application. For instance:<br>
`Jarvis.CongaPath←(⊃1 ⎕NPARTS ''),'/conga/'` would tell `Jarvis` to find the shared libraries in the `/conga/` subfolder of the current folder.

### Using Other Versions of Conga
If you need to use a version of Conga other than the one in the Dyalog installation folder, there are two ways to accomplish this:

* Put the shared libraries and the `conga` workspace in a folder and set [`Jarvis.CongaPath`](./settings-shared.md#congapath) to point to that folder.
* Put the `Conga` namespace in your workspace (pointing [`Jarvis.CongaRef`](./settings-shared.md#congaref)  to it if necessary) and the shared libraries in a folder set [`Jarvis.CongaPath`](./settings-shared.md#congapath) to point to that folder.

### Multiple Conga-using Components
Conga is used by several Dyalog utilities and packages including [Jarvis](https://github.com/Dyalog/Jarvis), [HttpCommand](https://github.com/Dyalog/HttpCommand), [isolate](https://github.com/Dyalog/isolate), [EWC](https://github.com/Dyalog/ewc), and DFS (Dyalog File Server). You might also use it in your application. When you have multiple Conga-using components in your application it is recommended to have a single instance of the `Conga` namespace which loads the Conga shared libraries once. Each component should then create their own Conga root.