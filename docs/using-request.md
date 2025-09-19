A [`Request` object](./request.md) is created for every HTTP request that `Jarvis` receives. It contains information about the request - HTTP headers, HTTP cookies, the client's IP address, certificate information (if you're using HTTPS), etc. It also contains the [`Response` namespace](./request.md#response-namespace) which will have the information to format `Jarvis`' response.

`Request` is also passed as an argument to several of the ["hook" functions](./settings-hooks.md).

### Simple Authentication Example

If your `Jarvis` service used [HTTP Basic](./security.md#httpbasicauthentication), `Jarvis` will populate the [`Userid`](./request.md#userid) and [`Password`](./request.md#password) fields with the credentials supplied in the request. In this example we'll use a somewhat nonsensical validation of checking if the `Password` is the reverse of the `Userid`
```
     ∇ rc←Authenticate req
[1]   ⍝ Perform simple silly HTTP Basic authentication example
[2]   ⍝ check that:
[3]   ⍝   there is a UserID
[4]   ⍝   the Password is the reverse of UserID
[5]   ⍝ req - the request object
[6]   ⍝ rc  - 0 if authentication passes, 1 otherwise
[7]    →0⍴⍨rc←0∊⍴req.UserID        ⍝ fail if UserID is empty
[8]    rc←req.UserID≢⌽req.Password ⍝ fail if UserID is not the reverse of Password
     ∇
```
or more succinctly `Authenticate←{0∊⍴⍵.UserID:1 ⋄ ⍵.UserID≢⌽⍵.Password}`

### Manipulating the Request's Response

`Jarvis` will assume that all responses are of the content-type specified by [`DefaultContentType`](./settings-operational.md#defaultcontenttype) which has a default setting of `'application/json; charset=utf-8'`. You can specify a different `DefaultContentType` if most or all of your endpoints return response payloads other than JSON. You can also set the content-type in your endpoint code by using the request's [`SetContentType`](./request.md#setcontenttype) method. For example:

```
     ∇ r←req ReturnHTML string
[1]   ⍝ Simple example of manipulating the payload
[2]    req.SetContentType'text/html; charset=utf-8'
[3]    r←'<h1>',string,'</h1>'
     ∇
```

       