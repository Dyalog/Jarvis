## Jarvis web service framework

Jarvis is Dyalog's web service framework, written in Dyalog APL. For more information about Jarvis, see [the Jarvis GitHub repository](https://github.com/Dyalog/jarvis). The `dyalog/jarvis` container is built from the Docker subdirectory in that repository, and is designed to make it very easy to deploy Jarvis-based applications.

Jarvis documentation can be found [here](https://dyalog.github.io/jarvis).


## Using the container

If `/path/to/app` contains the application that Jarvis is to serve and `7777` is the port that you would like the service to appear on, then all you need to do to start running a containerised Jarvis server is to use docker run to start the `dyalog/jarvis` container, using the `-v` switch to mount the directory under the name `/app`  and `-p` to map the port number to 8080, which is the port number that Jarvis will use inside the container:

```sh
docker run -p 7777:8080 -v /path/to/app:/app dyalog/jarvis
```
## Demo Application

If you do not map a directory into the container, it will serve up the default application which can be found in the `Samples\JSON` folder in the Jarvis repository. If you direct a web browser at the exposed port, Jarvis will present a simple interactive interface. You can test that it is working by entering "GetSign" as the method to execute, and a date of birth in the form "[mm,dd]" as JSON data, and clicking "send".

## Debugging

See the description of the `dyalog/dyalog` container for information on debugging and other fundamentals. The `dyalog/jarvis` container is built upon that container, adding the code for Jarvis as the main application to be run.

## Configuration

Most Jarvis configuration options should be set using a Jarvis configuration file, which you can read about in the Jarvis documentation. A couple of environment variables are particularly useful in the context of running Jarvis in a container. 

| Variable Name              | Description                                                  |
| -------------------------- | ------------------------------------------------------------ |
| DYALOG_JARVIS_CODELOCATION | The name of the directory (as seen from inside the container) where the application code resides (default is  `/app`) |
| DYALOG_JARVIS_PORT         | The port number to use inside the container (default is 8080) |

You can set environment variables to modify the behaviour of the container. For example, you could insert`-e DYALOG_JARVIS_CODELOCATION=/code ` into the `docker run` command (assuming that was where you had placed the code).

## Licence

Dyalog is free for non-commercial use but is not free software. Please see [here](https://www.dyalog.com/prices-and-licences.htm) for our Licence Agreement and full Terms and Conditions. Note that:

 * Commercial re-distribution of software that includes Dyalog requires a [Run Time Licence](https://www.dyalog.com/prices-and-licences.htm#runtimelic). If you do not have a commercial licence, and you make images available for download, this constitutes acceptance of the default Run Time Licences, which allows non-commercial and limited commercial distribution.
 * If you create docker images which include Dyalog APL in addition to your own work and make them available for download, you must include the LICENSE file in a prominent location and include instructions which make reference to it.

