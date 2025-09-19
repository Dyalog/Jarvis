**Jarvis** uses Conga for TCP/IP communications. `Jarvis`'s Conga settings are used to configure the Conga's operation. In most cases `Jarvis`' default Conga-settings are sufficient. See the [Conga User Guide](https://docs.dyalog.com/latest/Conga%20User%20Guide.pdf) for more detailed information on specific settings. See [Jarvis and Conga](./conga.md) if your application has other components that also use Conga, such as HttpCommand or isolates, or if you are using Conga that is not located in the Dyalog installation folder. 

Once started, `Jarvis` maintains a reference to to Conga library in the shared [`LDRC`](./settings-shared.md#ldrc) setting. This enables you to manage query and/or manage Conga settings directly if you need to.  For instance, `j.LDRC.Tree '.'` will return the entire Conga object tree.

`Jarvis` has two shared Conga-related settings - [`CongaPath`](./settings-shared.md#congapath) and [`CongaRef`](./settings-shared.md#congaref).

### `AcceptFrom`
|--|--|
|Description|`AcceptFrom` allows you to limit `Jarvis` incoming connections to a specific set of IP address ranges. `AcceptFrom` is either one or two character vectors that specify IPV4 and/or IPV6 address ranges. Each vector is a comma-delimited set of IP ranges. |
|Default|`''`|
|Examples|`j.AcceptFrom←'192.168.1.1/127,10.17.221.67/75'` |
|Notes|This setting is documented as `AllowEndPoints` in the [Conga User Guide](https://docs.dyalog.com/latest/Conga%20User%20Guide.pdf). Unlike `AllowEndPoints`, you do not need to specify `'IPV4'` or `'IPV6'` as `Jarvis` can automatically determine which IP version is intended.|

### `BufferSize`
|--|--|
|Description|`BufferSize` specifies the maximum HTTP headers length that `Jarvis` will accept. The intent is to block malicious requests that attempt to overwhelm the server by sending huge requests.|
|Default|`10000`|
|Examples|`j.BufferSize←5000 ⍝ allow up to 5000 bytes of HTTP header data` |
|Notes|`BufferSize` can be used in conjunction with [`DOSLimit`](#doslimit) to mitigate Denial of Service (DOS) attacks.|

### `DenyFrom`
|--|--|
|Description|Similar to [`AcceptFrom`](#acceptfrom), `DenyFrom` allows you to deny incoming connections from a specific set of IP address ranges. `DenyFrom` is either one or two character vectors that specify IPV4 and/or IPV6 address ranges. Each vector is a comma-delimited set of IP ranges.|
|Default|`''`|
|Examples|`j.DenyFrom←'192.168.1.1/127,10.17.221.67/75'`|
|Notes|This setting is documented as `DenyEndPoints` in the [Conga User Guide](https://docs.dyalog.com/latest/Conga%20User%20Guide.pdf). Unlike `DenyEndPoints`, you do not need to specify `'IPV4'` or `'IPV6'` as `Jarvis` can automatically determine which IP version is intended.|

### `DOSLimit`
|--|--|
|Description|To reduce possible Denial Of Service (DOS) attacks, `DOSLimit` is used to limit the size of HTTP payloads that `Jarvis` will accept. |
|Default|`¯1` which indicates to use the Conga default value of 10485760|
|Examples|`j.DOSLimit←100000 ⍝ assumes no message will exceed 100000 bytes`|
|Notes|You should specify a `DOSLimit` large enough to accept the largest message you anticipate receiving.|

### `FIFO`
|--|--|
|Description|`FIFO` controls how Conga will process incoming requests. Setting `FIFO` to `1` will cause Conga to process requests in a "First In, First Out" order. Setting `FIFO` to `0` will cause Conga to process requests according to Conga's `ReadyStrategy` setting.|
|Default|`1`|
|Examples|`j.FIFO←0 ⍝ turn FIFO mode off`|
|Notes|This setting is documented as `EnableFifo` in the [Conga User Guide](https://docs.dyalog.com/latest/Conga%20User%20Guide.pdf).|

### `Port`
|--|--|
|Description|`Port` is port number that `Jarvis` will listen on.|
|Default|`8080`|
|Examples|`j.Port←22361`|
|Notes|Allocating ports below 1024 on Linux typically requires root privileges due to security reasons.|

### `RootCertDir`
|--|--|
|Description|When running `Jarvis` over HTTPS, `RootCertDir` is the path to a folder containing public root certificates.|
|Default|`''`|
|Examples|Set `RootCertDir` to the public root certificates folder installed with Dyalog.<br>`dir←1 1⊃1 ⎕NPARTS 2 ⎕NQ '.' 'GetCommandLineArgs'`<br>`j.RootCertDir←dir,'PublicCACerts'`|
|Notes|This setting is documented as `RootCertDir` in the [Conga User Guide](https://docs.dyalog.com/latest/Conga%20User%20Guide.pdf). See [`Security`](./security.md) for more information.|

### `Priority`
|--|--|
|Description|`Priority` is the [GnuTLS priority string](https://www.gnutls.org/manual/gnutls.html#Priority-Strings) when using secure communications. `Priority` specifies the TLS session's handshake algorithms when negotiating a secure connection.|
|Default|'NORMAL:!CTYPE-OPENPGP'|
|Examples|`j.Priority←'NORMAL:-MD5' ⍝ use the default without HMAC-MD5` |
|Notes|Setting `Priority` to something other than the default requires an in-depth understanding of TLS session negotiation. Don't change it unless you know know what you're doing.|

### `Secure`
|--|--|
|Description|`Secure` is a Boolean setting that controls whether `Jarvis` will use TLS. Valid settings are:<ul><li>`0` - do not use TLS</li><li>`1` - attempt to use TSL (see notes below)</li></ul>|
|Default|`0`|
|Examples|`j.Secure←1 ⍝ enable secure communications`|
|Notes|Using TLS requires configuring several settings, see [Using TLS](./security.md#usingtls).|

### `ServerCertSKI`
|--|--|
|Description|Under Windows, when using the Microsoft Certificate Store to obtain the server certificate for `Jarvis` to use, `ServerCertSKI` is the **Serv**er **Cert**ificate **S**ubject **K**ey **I**dentifier of the certificate.|
|Default|`''`|
|Examples|`j.ServerCertSKI←'aca7d8f00691129ea0bc3613a00ed8ea9a5e55f5'`|
|Notes|The subject key identifier is a 40 byte hexadecimal string. For more information, see [Using TLS](./security.md#usingtls).|

### `ServerCertFile`
|--|--|
|Description|`ServerCertFile` is the name of the file containing the server's public certificate.|
|Default|`''`|
|Examples|`j.ServerCertFile←'/etc/mycerts/publiccert.pem'`|
|Notes|For more information, see [Using TLS](./security.md#usingtls).|

### `ServerKeyFile`
|--|--|
|Description|`ServerKeyFile` is the name of the file containing the server's private key.|
|Default|`''`|
|Examples|`j.ServerKeyFile←'/etc/mycerts/privatekey.pem'`|
|Notes|**Never** share your private key file. For more information, see [Using TLS](./security.md#usingtls).|

### `ServerName`
|--|--|
|Description|`ServerName` is the Conga name for the `Jarvis` server. You can specify the name or have it Conga assign it.|
|Default|Assigned by Conga in the format `'SRVnnnnnnnn'` where `nnnnnnnn` begins at `00000000` and is incremented when a `Jarvis` server using the same Conga instance is started.|
|Examples|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`      )copy conga Conga`<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`      j1←Jarvis.New 8080`<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`      j2←Jarvis.New 8081`<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`      j3←Jarvis.New 8082`<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`      j3.ServerName←'MyJarvis'`<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`      (j1 j2 j3).Start`<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`      (j1 j2 j3).ServerName`<br>` SRV00000000  SRV00000001  MyJarvis`|
|Notes|`ServerName` can be useful when interacting with Conga, particularly when debugging. For example:<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`      j3.(LDRC.Describe ServerName)`<br>`0   MyJarvis  Server  Listen`<br>[`LDRC`](./settings-shared.md#ldrc) is `Jarvis`'s local reference to the Conga library.|

### `SSLValidation`
|--|--|
|Description|`SSLValidation` is employed as part of the certificate checking process and is more fully documented in the [Conga User Guide](https://docs.dyalog.com/latest/Conga%20User%20Guide.pdf).|
|Default|`64` - request but do not require a client certificate|
|Examples|`j.SSLValidation←128 ⍝ require a valid certificate`|
|Notes|For more information, see [Using TLS](./security.md#usingtls).|

### `WaitTimeout`
|--|--|
|Description|`WaitTimeout` is the number of milliseconds that `Jarvis` will wait in its listening loop before timing out.|
|Default|`15000` - 15 seconds|
|Examples|`j.WaitTimeout←60000 ⍝ wait a minute before timing out`|
|Notes|Conga servers sit in a "wait" loop listening for communications from clients. If no communications occur before `WaitTimeout` has passed, Conga will signal a "Timeout" event and reiterate the "wait" loop.|