**Jarvis**'s JSON paradigm was developed to make it easy to expose the functionality of your APL application as a web service. The endpoints of your service are simply APL functions that take an array as a right argument and return an error as a result.
## How **Jarvis**'s JSON mode works
### You write an APL function for each endpoint of your service
Each endpoint function should at a minimum take an APL array as a right argument and return an APL array as its result. The name of the endpoint is the name of your function - so, it's best to not use characters in your endpoint function names that aren't easily supported in URLs. Your functions should reside in the namespace specified by [`CodeLocation] 

### The client sends a request
It doesn't matter what the client is - it could be a browser, an app on a phone, Dyalog's `HttpCommand`, curl, or any program capable of sending and receiving HTTP messages. To call one of your service's endpoints, the client's request should:

* Specify the 
* Use the HTTP POST method in order to send the request payload.
* Include a `content-type: application/json` header in the request's headers. 
* Format its payload as JSON.

!!! Example
    `curl -H "content-type: application/json" -X POST -d [1,3,5] http://localhost:8080/sum`

!!! tip "Advanced Usage"

    * The [`AllowGETs`](./settings-operational.md#allowgets) setting will enable HTTP GET method to be used as well - by default `AllowGETs` is disabled. 
    * The [`AllowFormData`](./settings-operational.md#allowformdata) setting will enable `Jarvis` to receive payloads that use `content-type: multipart/form-data` - by default `AllowFormData` is disabled.

### `Jarvis` receives the request
When `Jarvis` receives the request, it verifies that the request is well-formed. If there is a problem parsing the request, `Jarvis` will respond to the client with a 400-series HTTP status code and message. Assuming the request is well-formed, `Jarvis` will convert the request's JSON payload to an APL array using `⎕JSON`.

### `Jarvis` calls your endpoint function
`Jarvis` passes the APL array as the right argument to your endpoint function.  If your function is dyadic or ambivalent, `Jarvis` will pass the [`HttpRequest`](./reference.md#httprequest) object as the left argument. Your function should return an APL array result.

!!! tip "Advanced Usage"
    **Jarvis** has a few specific places where you can "inject" your own APL code to perform actions like additional request validation, authentication, and so on. Two such places are available after `Jarvis` receives the request, but before calling your endpoint function.  These are:
    
    * [`ValidateRequestFn`](./settings-hooks.md#validaterequestfn) specifies the name of a function to call for every request that `Jarvis` receives.
    * [`AuthenticateFn`](./settings-hooks.md#authenticatefn) specifies the name of a function to call to perform authentication. 

### `Jarvis` sends the response to the client
`Jarvis` will convert the APL array result into JSON format using `⎕JSON⍠'HighRank' 'Split'` and send the JSON back to the client as the payload of the response.