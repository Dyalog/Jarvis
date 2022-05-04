# Configuration

## Conga Dependence
Jarvis relies on Conga, the Dyalog TCP/IP utility library, for its communications. Conga itself requires two components:

- the platform-dependent Conga shared library
- Conga namespace which is platform independent and implements the interface from APL to the shared library

## Configuration Settings
| Setting Name | Description | Example(s)  |
|`AcceptFrom`|Conga setting to restrict which IP addresses Jarvis will accept requests from||