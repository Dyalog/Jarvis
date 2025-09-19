A `Request` object is created for each request `Jarvis` receives from a client. `Request` contains the information from the HTTP request and a [`Response`](#response) namespace that contains information `Jarvis` uses to send the response back to the client.  `Request` is also passed as an argument to several of `Jarvis`' ["hook" functions](./settings-hooks.md). 

We'll use `req` in the documentation and examples to refer to an instance of the `Request` object.

### When using the [JSON paradigm](./json.md)
The `Request` is passed as the left argument to dyadic or ambivalent endpoints. In many cases, your endpoint won't need the `Request`; `Jarvis` handles the details of formatting the response from the result of your endpoint.   

### When using the [REST paradigm](./rest.md)
The `Request` object is passed as the right argument to your HTTP command handlers.

### `Request` Fields

### `Request` Methods

### `Response` Namespace