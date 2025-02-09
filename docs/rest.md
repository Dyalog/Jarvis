Jarvis's REST paradigm was developed to make it possible to deploy your APL application using a REST API. REST APIs are more applicable when managing a collection of resources. HTTP-based REST web services, like Jarvis, use standard HTTP methods (GET, POST, PUT, DELETE, etc) to create, retrieve, and manipulate resources.

There are [six guiding principles of REST](https://en.wikipedia.org/wiki/REST#Architectural_constraints). The degree to which you adhere to these principles is completely up to you.

## How Jarvis's REST mode works

### You write an APL function for each HTTP method your service will support
Rather than writing a function for each endpoint as in the JSON paradigm, you will write a monadic function for each of the HTTP methods that your web service will support. Your functions should reside in the namespace specified by [`CodeLocation`](settings-operational.md#codelocation). 

You specify which HTTP methods your REST service will support using the [`RESTMethods`](settings-rest.md#restmethods) setting. For instance, setting `RESTMethods←'Get'` indicates that your service will support only HTTP GET requests. Such requests will call the `#.CodeLocation.Get` function, passing the HTTP request as its right argument. For the purposes of this document, we'll call the request right argument `Request`.

Your `Get` function would then look at the resource being requested by parsing [`Request.Endpoint`](httprequest.md#endpoint) element. If [`DefaultContentType`](.settings-operational.md#defaultcontenttype) is set to `'application/json'` (the default), your function can return an APL array which `Jarvis` will convert to JSON. If you are not using `'application/json'`, then you will need to:

1. use [`Request.SetContentType`](httprequest.md#contenttype) to set an appropriate content type
2. set the `Request.Response.Payload` to the content you want to send back to the client

### The client sends a request
It doesn't matter what the client is - it could be a browser, an app on a phone, Dyalog's `HttpCommand`, curl, or any program capable of sending and receiving HTTP messages. To interact with a resource, the client should:

* Specify the resource in the request URL
* Specify the HTTP method appropriate to the operation being requested
* If the request includes a payload, specify an appropriate `content-type` header 

!!! Example

    To retrieve a hypothetical list of orders for customer with id 123, one might make a request like: 
    `resp←HttpCommand.Get 'http://localhost:8080/customers/123/orders'`

### `Jarvis` receives the request
When `Jarvis` receives the request, it verifies that the request is well-formed. If there is a problem parsing the request, `Jarvis` will respond to the client with a 400-series HTTP status code and message.

### `Jarvis` calls your method function
`Jarvis` passes the [`Request`](./reference.md#request) object as the right argument to the function appropriate for the HTTP method being used. It is up to your function to parse `Request.Endpoint` to determine the resource being requested. As noted above, if the response payload's `content-type` is `'application/json'` your function can return an APL array which `Jarvis` will automatically convert to JSON. Otherwise, your function is responsible for setting the `Request.Response.Payload` and `Request.ContentType` appropriately.

If the requested resource is not found, or some other issue occurs, your function should fail the request with an appropriate HTTP status code using [`Request.Fail`](./httprequest.md#fail). For example, an HTTP status code of 404 means that the requested resource was not found and you would use `Request.Fall 404` to set the status code.

!!! tip "Advanced Usage"
    Jarvis has a few specific places where you can "inject" your own APL code to perform actions like additional request validation, authentication, and so on. Two such places are available after `Jarvis` receives the request, but before calling your function.  These are:
    
    * [`ValidateRequestFn`](./settings-hooks.md#validaterequestfn) specifies the name of a function to call for every request that `Jarvis` receives.
    * [`AuthenticateFn`](./settings-hooks.md#authenticatefn) specified the name of a function to call to perform authentication. 

### `Jarvis` sends the response to the client
`Jarvis` will format a proper HTTP response and send it to the client.