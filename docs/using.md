## Best Practices
For all but the simplest of Jarvis-based services, we recommend:

* Store the code that implements your endpoints in text files which Jarvis will load upon startup. Set the `CodeLocation` configuration setting to the folder name that contains the text files.
* Use a Jarvis configuration file to specify all non-default configuration settings. 

## Core Usage Pattern

There are four basic steps to running a Jarvis service.

1. Write the APL code which implements the endpoints of your service.
1. Create an instance of the `Jarvis` class.
1. Configure the instance.
1. Run the instance.

Everything else - from running the service locally to deploying it as a secure, cloud-hosted, load-balanced service is built on upon these four steps.

### Write the APL code that implements the endpoints

The Jarvis paradigm you choose (JSON or REST) will determine how to write your endpoints.

* **JSON** - you will write an APL function to implement each endpoint. The function name is the endpoint name.  See the [JSON Paradigm](./json.md) section for more information.
* **REST** - you will write an APL function for each HTTP method your service will support.  The function name is the same as the HTTP method name. See the [REST Paradigm](./rest.md) section for more information.

### Create an instance of the `Jarvis` class
While you can use the `⎕NEW` system function to create an instance of `Jarvis`, the recommended technique is to use `Jarvis.New`.

<code>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;j←Jarvis.New args</code>

`args` can be one of:

* `''` - create the instance using the default settings. Any non-default settings that you plan to use will need to be set before starting the instance.
*  `'path-to-a-Jarvis-config-file'` - create the instance using the settings specified in a Jarvis config file. A Jarvis config file is a JSON (or JSON5) file that contains Jarvis configuration settings.
* `namespace-reference` - create the instance using the named settings contained in a namespace. The namespace can contain only variables with names of Jarvis configuration settings.
* A positional vector of up to 4 elements containing `Port CodeLocation 'Paradigm' 'JarvisConfig'`.  You do not need to provide all parameters - only those up to the last parameter you need to use.  For instance, if you need to specify `'REST'` as the paradigm, you'll also need to supply `Port` and `CodeLocation`.   

Note that you can always set additional configuration settings after creating the instance with any of the above methods (but before running the instance).

Assuming that the file `/JarvisConfig.json` contains:<br/>
<code>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{"Port":80, "CodeLocation":"/myJarvisApp/", "Paradigm":"REST"}</code><br/>
and<br/>
<code>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;namespace←⎕JSON ⊃⎕NGET '/JarvisConfig.json'</code><br/>
the following are equivalent.
```
j←Jarvis.New '' ⋄ j.(Port CodeLocation Paradigm)←80 '/myJarvisApp' 'REST'
j←Jarvis.New '/JarvisConfig.json'
j←Jarvis.New namespace
j←Jarvis.New 80 '/myJarvisApp/' 'REST'
```
#### `CodeLocation`
`CodeLocation` specifies where Jarvis should look for the code that implements your endpoints. It can be

* a reference to, or the name of, a namespace in the workspace. For example, either `#.MyApp` and `'#.MyApp'` will work if your application code is in the namespace `#.MyApp`.
* a character vector representing the path to the folder that contains your application code.  If the path is relative, Jarvis attempts to determine the root folder from which to the path is relative to what it's relative to as follows:
    * If Jarvis is running in a saved workspace, it uses the folder where the workspace is located.
    * Otherwise, if you have specified a Jarvis config file, Jarvis will use the folder where the config file is located.
    * Otherwise, if Jarvis can determine the path for its source file, it will use that.
    * Finally, it will default to the current folder for your Dyalog session as determined by  `(1 ⎕NPARTS '')`. 
    Using a relative path can be useful for making your Jarvis service more portable, but it's important to make sure to understand the process above. For instance, if you have been running Jarvis from a `CLEAR WS` by dynamically loading it and then you save your application to a named workspace, Jarvis could wind up looking in a potentially different folder if the workspace is stored elsewhere than the Jarvis config file.
### Configure the `Jarvis` instance
Having created a `Jarvis` instance, you can set any configuration parameter prior to starting the instance.  This includes being able to override parameters that may have been loaded from a Jarvis config file. Details about each of the parameters can be found in [Settings](./settings-overview.md).
### Run the `Jarvis` instance
Use `j.Start` to start the `Jarvis` instance. Use `j.Stop` to stop `Jarvis`. You can run `j.Start` again to restart `Jarvis`. 