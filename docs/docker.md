**Jarvis** runs well in a container, which is a convenient way to deploy a web service. Dyalog publishes a `dyalog/jarvis` image, built from the `Docker` directory of the [Jarvis repository](https://github.com/Dyalog/jarvis), that is designed to run your application with little set-up.

!!! note
    The public `dyalog/jarvis` images are **not intended for production use**. For production, build your own image (see [Building your own image](#building-your-own-image)) so you control the Dyalog version, the workspace size, and exactly what is included.

## Quick start

Put your application in a directory, then run the container, mounting that directory as `/app` and mapping a host port to the container's port `8080` (the port **Jarvis** listens on inside the container):

```sh
docker run -p 7777:8080 -v /path/to/app:/app dyalog/jarvis
```

Your service is then reachable on the host at port `7777`. If you don't mount anything at `/app`, the container serves the sample application from `Samples/JSON`, so you can check the container works before supplying your own code.

## How the container finds your application

On start-up the container looks in `/app` and decides what to run, unless you've set [`CodeLocation`](./settings-operational.md#codelocation) or [`JarvisConfig`](./settings-operational.md#jarvisconfig) yourself:

1. If `/app` contains a `jarvis.json` configuration file, the container uses it as the [`JarvisConfig`](./settings-operational.md#jarvisconfig).
2. Otherwise, if `/app` contains any files, they are used as the [`CodeLocation`](./settings-operational.md#codelocation).
3. Otherwise, the sample application is served.

So the two usual patterns are: mount a folder of endpoint code at `/app`, or mount a folder that includes a `jarvis.json` that configures the service (and points at the code).

## Configuration

Most settings belong in a [configuration file](./settings-operational.md#jarvisconfig), which you supply as `jarvis.json` in `/app`. A few [container environment variables](./settings-container.md) are useful when running in Docker, set with `docker run -e`:

| Variable | Purpose |
|---|---|
| [`DYALOG_JARVIS_PORT`](./settings-container.md#dyalog_jarvis_port) | The port **Jarvis** listens on inside the container (default `8080`). |
| [`DYALOG_JARVIS_CODELOCATION`](./settings-container.md#dyalog_jarvis_codelocation) | The directory, as seen inside the container, that holds your endpoint code (default `/app`). |
| [`DYALOG_JARVIS_THREAD`](./settings-container.md#dyalog_jarvis_thread) | Which thread **Jarvis** runs on; the container defaults this to `1`. |

```sh
docker run -p 7777:8080 -v /path/to/app:/app -e DYALOG_JARVIS_CODELOCATION=/code dyalog/jarvis
```

The entrypoint also honours the `MAXWS` environment variable (the Dyalog maximum workspace size, default `256M`) — raise it if your application needs a larger workspace.

## Debugging

The container is built on the `dyalog/dyalog` image, so the same debugging facilities apply. To debug a service interactively, run Dyalog with [RIDE](https://dyalog.github.io/ride/) by setting `RIDE_INIT`, and set [`DYALOG_JARVIS_THREAD`](./settings-container.md#dyalog_jarvis_thread) to `debug`, `''` or `auto` so thread 0 is free for the session:

```sh
docker run -p 7777:8080 -p 4502:4502 \
  -e RIDE_INIT='SERVE:*:4502' -e DYALOG_JARVIS_THREAD=debug \
  -v /path/to/app:/app dyalog/jarvis
```

Then connect RIDE to the mapped RIDE port.

## Building your own image

The repository's `Dockerfile` (and `Dockerfile.20.0`) show the pattern: start from a `dyalog/dyalog` base image of the Dyalog version you want, add the Jarvis source, expose the port, and use the provided `Docker/entrypoint`:

```dockerfile
FROM dyalog/dyalog:20.0
USER root
ADD . /opt/mdyalog/Jarvis
EXPOSE 8080
ENV VERSION=20.0
ADD Docker/entrypoint /entrypoint
USER dyalog
```

For your own application image, start `FROM dyalog/jarvis` (or from a `dyalog/dyalog` base as above) and add your code and a `jarvis.json`.

## Licensing

Dyalog is free for non-commercial use but is not free software, and distributing an image that includes Dyalog APL carries licensing obligations. If you publish an image built on these, include the `LICENSE` file prominently and refer to it. See Dyalog's [Prices and Licences](https://www.dyalog.com/prices-and-licences.htm) and the notes in the repository's `Docker/README.md`.
