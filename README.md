# Jarvis

**Jarvis** is Dyalog's web service framework, written in Dyalog APL. It makes your APL functions available over HTTP, so any client that can make an HTTP request can call your APL code. That includes a browser, a phone app, or a program written in Python, C#, JavaScript or APL.

The name is a pseudo-acronym for **J**SON **a**nd **R**EST Ser**vice**.

## Features

- **Two paradigms**
  - In the **[JSON paradigm](https://dyalog.github.io/Jarvis/latest/json/)**, each APL function is an endpoint. `Jarvis` converts JSON to and from APL arrays for you.
  - In the **[REST paradigm](https://dyalog.github.io/Jarvis/latest/rest/)**, you write one function per HTTP method (`Get`, `Post` and so on) and decide how to handle each resource.
- **A built-in HTML interface** lets you try your endpoints from a browser, with no client code.
- **[Hooks](https://dyalog.github.io/Jarvis/latest/settings-hooks/)** for validation, authentication, session start-up and post-processing.
- **[Sessions](https://dyalog.github.io/Jarvis/latest/sessions/)**, **[HTTPS and client certificates](https://dyalog.github.io/Jarvis/latest/security/)**, **[CORS](https://dyalog.github.io/Jarvis/latest/settings-cors/)** and gzip/deflate compression.
- **[Server-Sent Events](docs/sse.md)** and **[WebSockets](docs/websockets.md)** for pushing data to clients.
- **[Docker](https://hub.docker.com/r/dyalog/jarvis)** support through the public `dyalog/jarvis` container.

Jarvis runs on Windows, Linux and macOS. It needs Dyalog APL 18.0 or later.

## Quick start

Load `HttpCommand`, then download and fix the `Jarvis` class:

```APL
      ]load HttpCommand
      HttpCommand.Fix 'https://raw.githubusercontent.com/Dyalog/Jarvis/master/Source/Jarvis.dyalog'
```

This downloads the latest, possibly pre-release, source. For production use, download a [released version](https://github.com/Dyalog/Jarvis/releases).

Write an endpoint, then start a server on port 8080 that serves the code in `#`:

```APL
      sum←{+/⍵}
      j←Jarvis.New ''
      (rc msg)←j.Start
```

Call it from APL:

```APL
      (HttpCommand.Do 'POST' 'localhost:8080/sum' '[1,3,5]' ('content-type' 'application/json')).Data
9
```

Or from the command line:

```sh
curl -H "content-type: application/json" -d "[1,3,5]" http://localhost:8080/sum
```

You can also open http://localhost:8080 in a browser to use the HTML interface. To stop the server, run `j.Stop`.

## Documentation

The full documentation is at **https://dyalog.github.io/Jarvis**. It covers [concepts](https://dyalog.github.io/Jarvis/latest/concepts/), [settings](https://dyalog.github.io/Jarvis/latest/settings-overview/), the [`Request` object](https://dyalog.github.io/Jarvis/latest/request/) and [release notes](https://dyalog.github.io/Jarvis/latest/release-notes/).

The source for the documentation is in [`docs`](docs). To preview it locally, run `mkdocs serve`.

## Repository layout

|Folder|Contents|
|--|--|
|[`Source`](Source)|The `Jarvis` class, `Jarvis.dyalog`. This single file is all you need to use Jarvis.|
|[`Samples`](Samples)|Example services: JSON endpoints, a REST service, and live HTML, SSE and WebSocket demos.|
|[`Demos`](Demos), [`Jarvis.demo`](Jarvis.demo)|Scripts that walk through Jarvis, using either two interpreters (a server and a client) or one.|
|[`Docker`](Docker)|Files for building the `dyalog/jarvis` container image.|
|[`Service`](Service)|Support for running Jarvis as a Windows service.|
|[`Distribution`](Distribution)|Prebuilt `Jarvis.dws` and `JarvisService.dws` workspaces.|
|[`Tests`](Tests)|`dyalogscript` test suites.|
|[`docs`](docs)|Documentation source, built with MkDocs.|
|[`Plans`](Plans)|Design documents for features in development.|

## Running the tests

The test suites need `dyalogscript`, which must be on your `PATH` or in `$DYALOG/scriptbin`. To run every suite:

```sh
Tests/run-all.sh
```

## License

Jarvis is released under the [MIT License](LICENSE).
