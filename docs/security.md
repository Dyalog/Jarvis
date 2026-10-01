This page covers the security-related features of **Jarvis**: encrypting the connection with TLS, authenticating requests, and validating them before your endpoint code runs.

## Using TLS

By default **Jarvis** serves plain HTTP. To serve HTTPS (TLS), set [`Secure`](./settings-conga.md#secure) to `1` and tell **Jarvis** where to find the server's certificate and private key:

- **Certificate and key files:** set [`ServerCertFile`](./settings-conga.md#servercertfile) to the public certificate file and [`ServerKeyFile`](./settings-conga.md#serverkeyfile) to the private key file.
- **Windows certificate store:** alternatively, on Windows, set [`ServerCertSKI`](./settings-conga.md#servercertski) to the certificate's Subject Key Identifier and **Jarvis** will load it from the Microsoft Certificate Store.
- **Root certificates:** [`RootCertDir`](./settings-conga.md#rootcertdir) names a folder of root CA certificates. On Windows, leaving it empty uses the operating system's certificate store.

```apl
j←Jarvis.New ''
j.Secure←1
j.ServerCertFile←'/path/to/server-cert.pem'
j.ServerKeyFile←'/path/to/server-key.pem'
j.Start
```

[`SSLValidation`](./settings-conga.md#sslvalidation) controls how **Jarvis** treats client certificates. The default, `64`, requests a client certificate but does not require one; when a client presents one, it is available to your code as [`req.PeerCert`](./request.md#peercert). See [`Priority`](./settings-conga.md#priority) for the cipher/protocol settings passed to Conga.

TLS underpins the other features here: HTTP Basic credentials and session tokens are only as safe as the connection carrying them, so run a service that authenticates its users over HTTPS.

## Authentication

Authentication decides *who* may call your service. **Jarvis** runs an authentication hook for each request, before your endpoint code: set [`AuthenticateFn`](./settings-hooks.md#authenticatefn) to the name of a function in [`CodeLocation`](./settings-operational.md#codelocation). The function is passed the [`Request`](./request.md) instance and returns:

- `0` — the request is authenticated, or no authentication is required, so processing continues;
- non-`0` — authentication failed; **Jarvis** fails the request with HTTP status `401` (Unauthorized).

If the function signals an error, **Jarvis** fails the request with `500`.

Your function can base its decision on whatever the request carries — the [`UserID`](./request.md#userid) and [`Password`](./request.md#password) from HTTP Basic authentication (below), a bearer token or API key in a [header](./request.md#getheader), a [cookie](./request.md#getcookie), or [session](./sessions.md) state.

```apl
∇ r←Authenticate req
⍝ AuthenticateFn: allow a request only if it carries a known API key
  r←~(⊂req.GetHeader'x-api-key')∊KnownKeys
∇
```

If no `AuthenticateFn` is defined, every request is allowed (subject to [validation](#validation) and, for WebSockets, [`WsAuthenticateFn`](./settings-websockets.md#wsauthenticatefn)). WebSocket connections authenticate separately; see [Using WebSockets](./websockets.md#authentication).

## HTTP Basic Authentication

[HTTP Basic authentication](https://developer.mozilla.org/docs/Web/HTTP/Authentication) is the scheme in which the client sends a user name and password in the `Authorization` header. It is controlled by [`HTTPAuthentication`](./settings-operational.md#httpauthentication), which defaults to `'basic'`; set it to `''` to disable Basic authentication.

**Jarvis** handles two parts of the scheme for you:

- **Decoding credentials.** When a request carries an `Authorization: Basic …` header, **Jarvis** decodes it and sets [`req.UserID`](./request.md#userid) and [`req.Password`](./request.md#password), ready for your `AuthenticateFn` to check.
- **Challenging the client.** When `HTTPAuthentication` is `'basic'` and your `AuthenticateFn` rejects a request (returns non-`0`), **Jarvis** adds a `WWW-Authenticate: Basic` header to the `401` response, which prompts a browser to ask the user for credentials.

**Jarvis** does not decide whether the credentials are valid — that is your `AuthenticateFn`'s job:

```apl
∇ r←Authenticate req
⍝ AuthenticateFn: check the Basic-auth user name and password
  r←~(req.UserID req.Password)≡'admin' 'secret'
∇
```

Basic authentication sends the user name and password only Base64-encoded, not encrypted, so always use it over [TLS](#using-tls).

## Validation

Validation decides *whether a request is acceptable* — its shape, headers, size, content-type and so on — independently of who sent it. Set [`ValidateRequestFn`](./settings-hooks.md#validaterequestfn) to the name of a function in `CodeLocation`. It is called for every request, is passed the [`Request`](./request.md) instance, and returns:

- `0` — the request is acceptable, so processing continues;
- non-`0` — the request is rejected; **Jarvis** fails it with HTTP status `400` (Bad Request).

`ValidateRequestFn` runs before `AuthenticateFn`, so use it for checks that don't depend on identity — for example rejecting an unexpected content-type or an over-large body:

```apl
∇ r←Validate req
⍝ ValidateRequestFn: require JSON requests no larger than 1 MB
  r←(~'application/json'≡req.ContentType)∨(1e6<≢req.Body)
∇
```

The hook can also adjust the request's [response](./request.md#response-namespace) before failing it — for example to set a custom status or an explanatory payload.
