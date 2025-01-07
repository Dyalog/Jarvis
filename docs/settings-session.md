A stateless web service means that each request from a client to the server is treated as an independent transaction that is unrelated to any previous request. In other words, the server does not store any information about the state of the client between requests. There are many good reasons for implementing a stateless web service including improved scalability, reliability, and independence. However, in some cases it may make sense to maintain some state on the server. **Jarvis**'s sessions are intended to allow you to maintain state in the server.

See [Using Sessions](./sessions.md) for more information.

### `SessionTimeout`
|--|--|
|Description| `SessionTimeout` controls whether `Jarvis` will use sessions. It also specifies how long before a session will time out and be removed. Valid settings are:<ul><li>`0` - do not use sessions</li><li>`n` - the number of minutes of inactivity before a session is timed out and removed</li><li>`¯1` - use sessions without any timeout. In this case it is up to your code to manage any session timeouts.</li></ul>|
|Default|`0` - do not use sessions|
|Examples|`j.SessionTimeout←10 ⍝ timeout after 10 minutes of inactivity`|

### `SessionIdHeader`
|--|--|
|Description| `SessionIdHeader` is the name of the HTTP header or HTTP cookie that will contain the session identifier. Every sessioned request must include this session ID in order to access the session state information on the server.|
|Default|`'Jarvis-SessionID'`|
|Examples|`j.SessionIdHeader←'gandalf'`|

### `SessionUseCookie`
|--|--|
|Description| `SessionUseCookie` controls whether the session id is sent using an HTTP header or an HTTP cookie. In either case, the header or the cookie name will be specified by `SessionIdHeader`. Valid settings are:<ul><li>`0` - use the HTTP header instead of a cookie</li><li>`1` - use an HTTP cookie instead of the header|
|Default|`0`|
|Examples|`j.SessionUseCookie←1 ⍝ use a cookie for the session id`|
|Notes|Using an HTTP cookie can be more convenient, especially if the client is a browser. When `Jarvis` creates session it will send the cookie in its response and then the browser will automatically include the cookie in every subsequent request.| 

### `SessionPollingTime` 
|--|--|
|Description| `SessionPollingTime` controls how often, in minutes, `Jarvis` polls for timed-out sessions.|
|Default|`1`|
|Examples|`j.SessionPollingTime←5`|
|Notes|When using sessions, `Jarvis` starts a session monitor in a separate thread. The session monitor loops continuously checking for timed-out sessions. `SessionPollingTime` controls the time between each loop.|

### `SessionCleanupTime` 
|--|--|
|Description| `SessionCleanupTime` controls how often, in minutes, `Jarvis` purges remaining information about timed-out sessions.|
|Default|`60`|
|Examples|`j.(SessionCleanupTime←SessionTimeout) ⍝ set to not retain any information after a session times out`|
|Notes|When a session times out, `Jarvis` erases the namespace associated with the session, but leaves information about the session having existed. `SessionCleanupTime` determines when that remaining information is removed. The intent was to give you the opportunity to inform the client that their session timed out if they send a request after the session has timed out, but before the remaining information is expunged.|