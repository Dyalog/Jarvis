:Class Jarvis
⍝ Dyalog Web Service Server
⍝ See https://github.com/dyalog/jarvis/wiki for documentation

    (⎕ML ⎕IO)←1 1

    :Field Public AcceptFrom←⍬                                 ⍝ IP addresses to accept requests from - empty means accept from any IP address
    :Field Public AllowFormData←0                              ⍝ do we allow POST form data in JSON paradigm?
    :Field Public AppInitFn←''                                 ⍝ name of the application "bootstrap" function
    :Field Public AuthenticateFn←''                            ⍝ function name to perform authentication,if empty, no authentication is necessary
    :Field Public BlockSize←10000                              ⍝ Conga block size
    :Field Public CodeLocation←''                              ⍝ application code location
    :Field Public Debug←0                                      ⍝ 0 = all errors are trapped, 1 = stop on an error, 2 = stop on intentional error before processing request
    :Field Public DefaultContentType←'application/json; charset=utf-8'
    :Field Public DenyFrom←⍬                                   ⍝ IP addresses to refuse requests from - empty means deny none
    :Field Public ErrorInfoLevel←1                             ⍝ level of information to provide if an APL error occurs, 0=none, 1=⎕EM, 2=⎕SI
    :Field Public ExcludeFns←''                                ⍝ vector of vectors for function names to be excluded (can use regex or ? and * as wildcards)
    :Field Public FlattenOutput←0                              ⍝ 0=no, 1=yes, 2=yes with notification
    :Field Public Folder←''                                    ⍝ folder that user supplied in CodeLocation from which to load code
    :Field Public HTMLInterface←¯1                             ⍝ ¯1=unassigned, 0/1=dis/allow the HTML interface, or Path to HTML
    :Field Public Hostname←''                                  ⍝ external-facing host name
    :Field Public HTTPAuthentication←'basic'                   ⍝ valid settings are currently 'basic' or ''
    :Field Public IncludeFns←''                                ⍝ vector of vectors for function names to be included (can use regex or ? and * as wildcards)
    :Field Public JarvisConfig←''                              ⍝ configuration file path (if any). This parameter was formerly named ConfigFile
    :Field Public JSONInputFormat←'D'                          ⍝ set this to 'M' to have Jarvis convert JSON request payloads to the ⎕JSON matrix format
    :Field Public LoadableFiles←'*.apl*,*.dyalog'              ⍝ file patterns that can be loaded if loading from folder
    :Field Public LogFn←''                                     ⍝ Log function name, leave empty to use built in logging
    :Field Public Logging←1                                    ⍝ turn logging on/off
    :Field Public Paradigm←'JSON'                              ⍝ either 'JSON' or 'REST'
    :Field Public ParsePayload←1                               ⍝ 1=parse payload based on content-type header (REST only)
    :Field Public Port←8080                                    ⍝ Default port to listen on
    :Field Public RootCertDir←''                               ⍝ Root CA certificate folder
    :field Public Priority←'NORMAL:!CTYPE-OPENPGP'             ⍝ Priorities for GnuTLS when negotiation connection
    :Field Public Report404InHTML←1                            ⍝ Report HTTP 404 status (not found) in HTML (only valid if HTML interface is enabled)
    :Field Public RESTMethods←'Get,Post,Put,Delete,Patch,Options'
    :Field Public Secure←0                                     ⍝ 0 = use HTTP, 1 = use HTTPS
    :field Public ServerCertSKI←''                             ⍝ Server cert's Subject Key Identifier from store
    :Field Public ServerCertFile←''                            ⍝ public certificate file
    :Field Public ServerKeyFile←''                             ⍝ private key file
    :Field Public SessionCleanupTime←60                        ⍝ how frequently (in minutes) do we clean up timed out session info from _sessionsInfo
    :Field Public SessionIdHeader←'Jarvis-SessionID'           ⍝ Name of the header field for the session tokem
    :Field Public SessionInitFn←''                             ⍝ Function name to call when initializing a session
    :Field Public SessionPollingTime←1                         ⍝ how frequently (in minutes) we should poll for timed out sessions
    :Field Public SessionStartEndpoint←'Login'
    :Field Public SessionStopEndpoint←'Logout'
    :Field Public SessionTimeout←0                             ⍝ 0 = do not use sessions, ¯1 = no timeout , 0< session timeout time (in minutes)
    :Field Public SSLValidation←64                             ⍝ request, but do not require a client certificate
    :Field Public ValidateRequestFn←''                         ⍝ name of the request validation function
    :Field Public WebSocketSupport←0                           ⍝ set to 1 to include WebSocket
    :Field Public WebSocket←''

  ⍝↓↓↓ some of these private fields are also set in ∇init so that a server can be stopped, updated, and restarted
    :Field _rootFolder←''                ⍝ root folder for relative file paths
    :Field _configLoaded←0               ⍝ indicates whether config was already loaded by Autostart
    :Field _htmlFolder←''                ⍝ folder containing HTML interface files, if any
    :Field _htmlDefaultPage←'index.html' ⍝ default page name if HTMLInterface is set to serve from a folder
    :Field _htmlEnabled←0                ⍝ is the HTML interface enabled?
    :Field _stop←0                       ⍝ set to 1 to stop server
    :Field _started←0                    ⍝ is the server started
    :Field _stopped←1                    ⍝ is the server stopped
    :field _paused←0                     ⍝ is the server paused
    :Field _sessionThread←¯1             ⍝ thread for the session cleanup process
    :Field _serverThread←¯1              ⍝ thread for the HTTP server
    :Field _taskThreads←⍬                ⍝ vector of thread handling requests
    :Field _sessions←⍬                   ⍝ vector of session namespaces
    :Field _sessionsInfo←0 5⍴'' '' 0 0 0 ⍝ [;1] id [;2] ip addr [;3] creation time [;4] last active time [;5] ref to session
    :Field _includeRegex←''              ⍝ private compiled regex from IncludeFns
    :Field _excludeRegex←''              ⍝ private compiled regex from ExcludeFns
    :Field _connections                  ⍝ namespace containing open connections

    ∇ r←Version
      :Access public shared
      r←'Jarvis' '1.8.5' '2021-02-03'
    ∇

⍝    ∇ Init
⍝    ⍝ called by ∇Start
⍝    ⍝ see :Field definitions
⍝      _rootFolder←''
⍝      _configLoaded←0
⍝      _htmlFolder←''
⍝      _htmlDefaultPage←'index.html'
⍝      _htmlEnabled←0
⍝      _sessionThread←¯1
⍝      _serverThread←¯1
⍝      _taskThreads←⍬
⍝      _sessions←⍬
⍝      _sessionsInfo←0 5⍴'' '' 0 0 0
⍝      _includeRegex←''
⍝      _excludeRegex←''
⍝      _connections←⎕NS ''
⍝    ∇

    ∇ r←Config
    ⍝ returns current configuration
      :Access public
      r←↑{⍵(⍎⍵)}¨⎕THIS⍎'⎕NL ¯2.2'
    ∇

    ∇ r←trap DebugLevel level
    ⍝ sets trap based on debugging level
    ⍝  the intention is to allow traps to be set for different forms of debugging (e.g. framework, request, application, etc
    ⍝  Example: :Trap 0 DebugLevel 1 ⍝ will disable traps if Debug contains 1
      :Access public
      r←trap/⍨Debug{~∨/{⍵[;1]∨.∧1↓[2]⍵}2⊥⍣¯1⊢⍺,⍵}level
    ∇

    ∇ {r}←{level}Log msg;ts
      :Access public overridable
      :If Logging>0∊⍴msg
          ts←fmtTS ⎕TS
          :If 1=≢⍴msg←⍕msg
          :OrIf 1=⊃⍴msg
              r←ts,' - ',msg
          :Else
              r←ts,∊(⎕UCS 13),msg
          :EndIf
          ⎕←r
      :EndIf
    ∇

    ∇ make
      :Access public
      :Implements constructor
      MakeCommon
    ∇

    ∇ make1 args;rc;msg;char;t
      :Access public
      :Implements constructor
    ⍝ args is one of
    ⍝ - a simple character vector which is the name of a configuration file
    ⍝ - a reference to a namespace containing named configuration settings
    ⍝ - a depth 1 or 2 vector of
    ⍝   [1] integer port to listen on
    ⍝   [2] charvec function folder or ref to code location
    ⍝   [3] paradigm to use ('JSON' or 'REST')
      MakeCommon
      :If char←isChar args ⍝ character argument?  it's either config filename or CodeLocation folder
          :If ~⎕NEXISTS args
              →0⊣Log'Unable to find "',args,'"'
          :ElseIf 2=t←1 ⎕NINFO args ⍝ normal file
              :If (lc⊢/⎕NPARTS args)∊'.json' '.json5' ⍝ json files are configuration
                  :If 0≠⊃(rc msg)←LoadConfiguration JarvisConfig←args
                      Log'Error loading configuration: ',msg
                  :EndIf
              :Else
                  CodeLocation←args ⍝ might be a namespace script or class
              :EndIf
          :ElseIf 1=t ⍝ folder means it's CodeLocation
              CodeLocation←args
          :Else ⍝ not a file or folder
              Log'Invalid constructor argument "',args,'"'
          :EndIf
      :ElseIf 9.1={⎕NC⊂,'⍵'}args ⍝ namespace?
          :If 0≠⊃(rc msg)←LoadConfiguration args
              Log'Error loading configuration: ',msg
          :EndIf
      :Else
          :If 326=⎕DR args
          :AndIf 0∧.=≡¨2↑args   ⍝ if 2↑args is (port ref) (both scalar)
              args[1]←⊂,args[1] ⍝ nest port so ∇default works properly
          :EndIf
     
          (Port CodeLocation Paradigm JarvisConfig)←args default Port CodeLocation Paradigm JarvisConfig
      :EndIf
    ∇

    ∇ MakeCommon
      :Trap 11
          JSONin←{⎕JSON⍠('Dialect' 'JSON5')('Format'JSONInputFormat)⊢⍵} ⋄ {}JSONin 1
          JSONout←⎕JSON⍠'HighRank' 'Split' ⋄ {}JSONout 1
          JSONread←⎕JSON⍠'Dialect' 'JSON5' ⍝ for reading configuration files
      :Else
          JSONin←{⎕JSON⍠('Format'JSONInputFormat)⊢⍵}
          JSONread←JSONout←⎕JSON
      :EndTrap
    ∇

    ∇ r←args default defaults
      args←,⊆args
      r←(≢defaults)↑args,(≢args)↓defaults
    ∇

    ∇ Close
      :Implements destructor
      {0:: ⋄ {}#.DRC.Close ServerName}⍬
    ∇

    ∇ UpdateRegex arg;t
    ⍝ updates the regular expression for inclusion/exclusion of functions whenever IncludeFns or ExcludeFns is changed
      :Implements Trigger IncludeFns, ExcludeFns
      t←makeRegEx¨(⊂'')~⍨∪,⊆arg.NewValue
      :If arg.Name≡'IncludeFns'
          _includeRegex←t
      :Else
          _excludeRegex←t
      :EndIf
    ∇

    ∇ r←Run args;msg;rc
    ⍝ args is one of
    ⍝ - a simple character vector which is the name of a configuration file
    ⍝ - a reference to a namespace containing named configuration settings
    ⍝ - a depth 1 or 2 vector of
    ⍝   [1] integer port to listen on
    ⍝   [2] charvec function folder or ref to code location
    ⍝   [3] paradigm to use ('JSON' or 'REST')
      :Access shared public
      :Trap 0
          (rc msg)←(r←⎕NEW ⎕THIS args).Start
      :Else
          (r rc msg)←'' ¯1 ⎕DMX.EM
      :EndTrap
      r←(r(rc msg))
    ∇

    ∇ (rc msg)←Start;html;homePage
      :Access public
     
      :If _started
          :If 0(,2)≡#.DRC.GetProp ServerName'Pause'
              rc←1⊃#.DRC.SetProp ServerName'Pause' 0
              →0 If(rc'Failed to unpause server')
              (rc msg)←0 'Server resuming operations'
              →0
          :EndIf
          →0 If(rc msg)←¯1 'Server thinks it''s already started'
      :EndIf
     
      :If _stop
          →0 If(rc msg)←¯1 'Server is in the process of stopping'
      :EndIf
     
      :If 'CLEAR WS'≡⎕WSID ⋄ _rootFolder←⊃1 ⎕NPARTS SourceFile
      :Else ⋄ _rootFolder←⊃1 ⎕NPARTS ⎕WSID
      :EndIf
     
      →0 If(rc msg)←LoadConfiguration JarvisConfig
      →0 If(rc msg)←CheckPort
      →0 If(rc msg)←LoadConga
      →0 If(rc msg)←CheckCodeLocation
      →0 If(rc msg)←Setup
     
      →0 If(rc msg)←StartServer
     
      Log'Jarvis started in "',Paradigm,'" mode on port ',⍕Port
      Log'Serving code in ',(⍕CodeLocation),(Folder≢'')/' (populated with code from "',Folder,'")'
     
      homePage←1 ⍝ does
      :Select ⊃HTMLInterface
      :Case 0 ⍝ explicitly no HTML interface, carry on
      :Case 1 ⍝ explicitly turned on
          :If Paradigm≢'JSON'
              Log'HTML interface is only available using JSON paradigm'
          :Else
              _htmlEnabled←1
          :EndIf
      :Case ¯1
          _htmlEnabled←Paradigm≡'JSON' ⍝ if not specified, HTML interface is enabled for JSON paradigm
      :Else
          _htmlEnabled←1
          html←1 ⎕NPARTS((isRelPath HTMLInterface)/_rootFolder),HTMLInterface
          :If isDir∊html
              _htmlFolder←{⍵,('/'=⊢/⍵)↓'/'}∊html
          :Else
              _htmlFolder←1⊃html
              _htmlDefaultPage←∊1↓html
          :EndIf
          homePage←⎕NEXISTS html←_htmlFolder,_htmlDefaultPage
          Log(~homePage)/'HTML home page file "',(∊html),'" not found.'
      :EndSelect
     
      Log(_htmlEnabled∧homePage)/'Click http',(~Secure)↓'s://localhost:',(⍕Port),' to access web interface'
    ∇

    ∇ (rc msg)←Stop;ts
      :Access public
      :If _stop
          →0⊣(rc msg)←¯1 'Server is already stopping'
      :EndIf
      :If ~_started
          →0⊣(rc msg)←¯1 'Server is not running'
      :EndIf
      ts←⎕AI[3]
      _stop←1
      Log'Stopping server...'
      :While ~_stopped
          :If 10000<⎕AI[3]-ts
              →0⊣(rc msg)←¯1 'Server seems stuck'
          :EndIf
      :EndWhile
      (rc msg)←0 'Server stopped'
    ∇

    ∇ (rc msg)←Pause;ts
      :Access public
      :If 0 2≡2⊃#.DRC.GetProp ServerName'Pause'
          →0⊣(rc msg)←¯1 'Server is already paused'
      :EndIf
      :If ~_started
          →0⊣(rc msg)←¯1 'Server is not running'
      :EndIf
      ts←⎕AI[3]
      #.DRC.SetProp ServerName'Pause' 2
      Log'Pausing server...'
      (rc msg)←0 'Server paused'
    ∇

    ∇ (rc msg)←Reset
      :Access Public
      ⎕TKILL _serverThread,_sessionThread,_taskThreads
      _sessions←⍬
      _sessionsInfo←0 5⍴0
      _stopped←~_stop←_started←0
      (rc msg)←0 'Server reset (previously set options are still in effect)'
    ∇

    ∇ r←Running
      :Access public
      r←~_stop
    ∇

    ∇ (rc msg)←CheckPort;p
    ⍝ check for valid port number
      (rc msg)←3('Invalid port: ',∊⍕Port)
      →0 If 0=p←⊃⊃(//)⎕VFI⍕Port
      →0 If{(⍵>32767)∨(⍵<1)∨⍵≠⌊⍵}p
      (rc msg)←0 ''
    ∇

    ∇ (rc msg)←{force}LoadConfiguration value;config;public;set;file
      :Access public
      :If 0=⎕NC'force' ⋄ force←0 ⋄ :EndIf
      (rc msg)←0 ''
      →(_configLoaded>force)⍴0 ⍝ did we already load from AutoStart?
      :Trap 0 DebugLevel 1
          :If isChar value
              :If '#.'≡2↑value ⍝ check if a namespace reference
              :AndIf 9.1=⎕NC⊂value
                  config←⍎value
                  →Load
              :EndIf
              file←JarvisConfig
              :If ~0∊⍴value
                  file←value
              :EndIf
              →0 If 0∊⍴file
              :If ⎕NEXISTS file
                  config←JSONread⊃⎕NGET file
              :Else
                  →0⊣(rc msg)←6('Configuation file "',file,'" not found')
              :EndIf
          :ElseIf 9.1={⎕NC⊂,'⍵'}value ⍝ namespace?
              config←value
          :EndIf
     Load:
          public←⎕THIS⍎'⎕NL ¯2.2' ⍝ find all the public fields in this class
          :If ~0∊⍴set←public{⍵/⍨⍵∊⍺}config.⎕NL ¯2 ¯9
              config{⍎⍵,'←⍺⍎⍵'}¨set
          :EndIf
          _configLoaded←1
      :Else
          →0⊣(rc msg)←⎕DMX.EN ⎕DMX.('Error loading configuration: ',EM,(~0∊⍴Message)/' (',Message,')')
      :EndTrap
    ∇

    ∇ (rc msg)←LoadConga;dyalog
      (rc msg)←0 ''
     
      ⍝↓↓↓ if Conga is not found in the workspace, attempt to use the DYALOG environment variable
      ⍝    however, on when using a bound workspaces DYALOG may not be set,
      ⍝    in which case we look in the same folder at the executable
      :If 0=#.⎕NC'Conga'
          :If 0∊⍴dyalog←2 ⎕NQ'.' 'GetEnvironment' 'DYALOG'
          :Else
              dyalog←1⊃1 ⎕NPARTS⊃2 ⎕NQ'.' 'GetCommandLineArgs'
          :EndIf
          :Trap 0 DebugLevel 4
              'Conga'#.⎕CY dyalog,'ws/conga'
          :Else
              :If 11 19∧.=⎕DMX.(EN ENX) ⍝ DOMAIN ERROR/WS not found
                  :Trap 0 DebugLevel 4
                      dyalog←⊃1 ⎕NPARTS⊃2 ⎕NQ'.' 'GetCommandLineArgs'
                      'Conga'#.⎕CY dyalog,'ws/conga'
                  :Else
                      (rc msg)←1 'Unable to copy Conga'
                      →0
                  :EndTrap
              :Else
                  (rc msg)←1 'Unable to copy Conga'
                  →0
              :EndIf
          :EndTrap
      :EndIf
     
      :Trap 999 DebugLevel 4 ⍝ Conga.Init signals 999 on error
          #.DRC←#.Conga.Init'Jarvis'
      :Else
          (rc msg)←2 'Unable to initialize Conga'
          →0
      :EndTrap
    ∇

    ∇ (rc msg)←CheckCodeLocation;root;m;res;tmp;fn;t;path
      (rc msg)←0 ''
      :If 0∊⍴CodeLocation
          :If 0∊⍴JarvisConfig ⍝ if there's a configuration file, use its folder for CodeLocation
              →0⊣(rc msg)←4 'CodeLocation is empty!'
          :Else
              CodeLocation←⊃1 ⎕NPARTS JarvisConfig
          :EndIf
      :EndIf
      :Select ⊃{⎕NC'⍵'}CodeLocation ⍝ need dfn because CodeLocation is a field and will always be nameclass 2
      :Case 9 ⍝ reference, just use it
      :Case 2 ⍝ variable, could be file path or ⍕ of reference from JarvisConfig
          :If 326=⎕DR tmp←{0::⍵ ⋄ '#'≠⊃⍵:⍵ ⋄ ⍎⍵}CodeLocation
          :AndIf 9={⎕NC'⍵'}tmp ⋄ CodeLocation←tmp
          :Else
              root←(isRelPath CodeLocation)/_rootFolder
              path←∊1 ⎕NPARTS root,CodeLocation
              :Trap 0 DebugLevel 1
                  :If 1=t←1 ⎕NINFO path ⍝ folder?
                      CodeLocation←⍎'CodeLocation'#.⎕NS''
                      →0 If(rc msg)←CodeLocation LoadFromFolder Folder←path
                  :ElseIf 2=t ⍝ file?
                      CodeLocation←#.⎕FIX'file://',path
                  :Else
                      →0⊣(rc msg)←5('CodeLocation "',(∊⍕CodeLocation),'" is not a folder or script file.')
                  :EndIf
              :Case 22 ⍝ file name error
                  →0⊣(rc msg)←6('CodeLocation "',(∊⍕CodeLocation),'" was not found.')
              :Else    ⍝ anything else
                  →0⊣(rc msg)←7((⎕DMX.(EM,' (',Message,') ')),'occured when validating CodeLocation "',(∊⍕CodeLocation),'"')
              :EndTrap
          :EndIf
      :Else
          →0⊣(rc msg)←5 'CodeLocation is not valid, it should be either a namespace/class reference or a file path'
      :EndSelect
     
      :For fn :In AppInitFn ValidateRequestFn AuthenticateFn SessionInitFn~⊂''
          :If 3≠CodeLocation.⎕NC fn
              msg,←(0∊⍴msg)↓',"CodeLocation.',fn,'" was not found '
          :EndIf
      :EndFor
      →0 If rc←8×~0∊⍴msg
     
      :If ~0∊⍴AppInitFn  ⍝ initialization function specified?
          :If 1 0 0≡⊃CodeLocation.⎕AT AppInitFn ⍝ result-returning niladic?
              (stop1/⍨~⊃1 DebugLevel 2)⎕STOP⊃⎕SI
     stop1:   res←CodeLocation⍎AppInitFn        ⍝ run it
              ⍬ ⎕STOP⊃⎕SI
              :If 0≠⊃res
                  →0⊣(rc msg)←2↑res,(≢res)↓¯1('"',(⍕CodeLocation),'.',AppInitFn,'" did not return a 0 return code')
              :EndIf
          :Else
              →0⊣(rc msg)←8('"',(⍕CodeLocation),'.',AppInitFn,'" is not a niladic result-returning function')
          :EndIf
      :EndIf
     
      Validate←{0} ⍝ dummy validation function
      :If ~0∊⍴ValidateRequestFn  ⍝ Request validation function specified?
          :If 1 1 0≡⊃CodeLocation.⎕AT ValidateRequestFn ⍝ result-returning monadic?
              Validate←CodeLocation⍎ValidateRequestFn
          :Else
              →0⊣(rc msg)←8('"',(⍕CodeLocation),'.',ValidateRequestFn,'" is not a monadic result-returning function')
          :EndIf
      :EndIf
     
      Authenticate←{0} ⍝ dummy authentication function
      :If ~0∊⍴AuthenticateFn  ⍝ authentication function specified?
          :If 1 1 0≡⊃CodeLocation.⎕AT AuthenticateFn ⍝ result-returning monadic?
              Authenticate←CodeLocation⍎AuthenticateFn
          :Else
              →0⊣(rc msg)←8('"',(⍕CodeLocation),'.',Authenticate,'" is not a monadic result-returning function')
          :EndIf
      :EndIf
    ∇

    ∇ (rc msg)←Setup
    ⍝ perform final setup before starting server
      (rc msg)←0 ''
      →(Paradigm∘match¨'json' 'rest')/json rest
      →0⊣(rc msg)←¯1 'Invalid paradigm'
     json:RequestHandler←HandleJSONRequest ⋄ →0
     rest:RequestHandler←HandleRESTRequest
      :If 2>≢⍴RESTMethods
          RESTMethods←↑2⍴¨'/'(≠⊆⊢)¨','(≠⊆⊢),RESTMethods
      :EndIf
    ∇

    Exists←{0:: ¯1 (⍺,' "',⍵,'" is not a valid folder name.') ⋄ ⎕NEXISTS ⍵:0 '' ⋄ ¯1 (⍺,' "',⍵,'" was not found.')}

    ∇ (rc msg)←StartServer;r;cert;secureParams;accept;deny;mask;certs;asc;options
      msg←'Unable to start server'
      accept←'Accept'ipRanges AcceptFrom
      deny←'Deny'ipRanges DenyFrom
      secureParams←⍬
      :If Secure
          :If ~0∊⍴RootCertDir ⍝ on Windows not specifying RootCertDir will use MS certificate store
              →0 If(rc msg)←'RootCertDir'Exists RootCertDir
              →0 If(rc msg)←{(⊃⍵)'Error setting RootCertDir'}#.DRC.SetProp'.' 'RootCertDir'RootCertDir
          :EndIf
          :If 0∊⍴ServerCertSKI
              →0 If(rc msg)←'ServerCertFile'Exists ServerCertFile
              →0 If(rc msg)←'ServerKeyFile'Exists ServerKeyFile
              cert←⊃#.DRC.X509Cert.ReadCertFromFile ServerCertFile
              cert.KeyOrigin←'DER'ServerKeyFile
          :Else
              certs←#.DRC.X509Cert.ReadCertUrls
              :If 0∊⍴certs
                  rc←8
                  msg←'No certs in Microsoft Certificate Store'
                  →0
              :EndIf
              mask←ServerCertSKI{∨/¨(⊂⍺)⍷¨2⊃¨⍵}certs.CertOrigin
              :If 1≠+/mask
                  rc←9
                  msg←(1+0<+/mask)⊃(ServerCertSKI,' not found in Microsoft Certificate Store')('More than one certificate with Subject Key Identifier ',ServerCertSKI)
                  →0
              :EndIf
              cert←certs[⊃⍸mask]
          :EndIf
          secureParams←('X509'cert)('SSLValidation'SSLValidation)('Priority'Priority)
      :EndIf
     
      {}#.DRC.SetProp'.' 'EventMode' 1 ⍝ report Close/Timeout as events
     
      options←''
      :If asc←3 3≡2↑#.DRC.Version ⍝ can we set DecodeBuffers at server creation?
          options←⊂'Options' 5 ⍝ DecodeBuffers + WSAutoAccept
      :EndIf
     
      _connections←⎕NS''
     
      :If 0=rc←1⊃r←#.DRC.Srv'' ''Port'http'BlockSize,secureParams,accept,deny,options
          ServerName←2⊃r
          :If ~asc
              {}#.DRC.SetProp ServerName'FIFOMode' 0 ⍝ deprecated in Conga v3.2
              {}#.DRC.SetProp ServerName'DecodeBuffers' 15 ⍝ 15 ⍝ decode all buffers
              {}#.DRC.SetProp ServerName'WSFeatures' 1 ⍝ auto accept WS requests
          :EndIf
          :If 0∊⍴Hostname ⍝ if Host hasn't been set, set it to the default
              Hostname←'http',(~Secure)↓'s://',(2 ⎕NQ'.' 'TCPGetHostID'),((~Port∊80 443)/':',⍕Port),'/'
          :EndIf
          InitSessions
          RunServer
          msg←''
      :Else
          →0⊣msg←'Error creating server',(rc∊98 10048)/': port ',(⍕Port),' is already in use' ⍝ 98=Linux, 10048=Windows
      :EndIf
    ∇

    ∇ RunServer
      _serverThread←Server&⍬
    ∇

    ∇ Server arg;wres;rc;obj;evt;data;ref;ip;congaError
      :If 0≠#.DRC.⎕NC⊂'Error' ⋄ congaError←#.DRC.Error ⍝ Conga 3.2 moved Error into the library instance
      :Else ⋄ congaError←#.Conga.Error                 ⍝ Prior to 3.2 Error was in the namespace
      :EndIf
      (_started _stopped)←1 0
      :While ~_stop
          :Trap 0 DebugLevel 1
              wres←#.DRC.Wait ServerName 2500 ⍝ Wait for WaitTimeout before timing out
          ⍝ wres: (return code) (object name) (command) (data)
              (rc obj evt data)←4↑wres
              :Select rc
              :Case 0
                  :Select evt
                  :Case 'Error'
                      _stop←ServerName≡obj
                      :If 0≠4⊃wres
                          Log'RunServer: DRC.Wait reported error ',(⍕congaError 4⊃wres),' on ',(2⊃wres),GetIP obj
                      :EndIf
                      _connections.⎕EX obj
     
                  :Case 'Connect'
                      obj _connections.⎕NS''
                      (_connections⍎obj).IP←2⊃2⊃#.DRC.GetProp obj'PeerAddr'
     
                  :CaseList 'HTTPHeader' 'HTTPTrailer' 'HTTPChunk' 'HTTPBody'
                      _taskThreads←⎕TNUMS∩_taskThreads,(_connections⍎obj){⍺ HandleRequest ⍵}&wres
     
                  :CaseList 'Closed' 'Timeout'
     
                  :Else ⍝ unhandled event
                      Log'Unhandled Conga event:'
                      Log⍕wres
                  :EndSelect ⍝ evt
     
              :Case 1010 ⍝ Object Not found
                  :If ~_stop
                      Log'Object ''',ServerName,''' has been closed - Jarvis shutting down'
                      _stop←1
                  :EndIf
     
              :Else
                  Log'Conga wait failed:'
                  Log wres
              :EndSelect ⍝ rc
          :Else
              Log'*** Server error ',(JSONout⍠'Compact' 0)⎕DMX
          :EndTrap
      :EndWhile
      Close
      ⎕TKILL _sessionThread
      (_stop _started _stopped)←0 0 1
    ∇

    :Section RequestHandling

    ∇ req←MakeRequest args
    ⍝ create a request, use MakeRequest '' for interactive debugging
      :Access public
      :If 0∊⍴args
          req←⎕NEW Request
      :Else
          req←⎕NEW Request args
      :EndIf
      req.(Server ErrorInfoLevel)←⎕THIS ErrorInfoLevel
    ∇


    ∇ ns HandleRequest req;data;evt;obj;rc;cert;fn
      (rc obj evt data)←req ⍝ from Conga.Wait
      :Hold obj
          :Select evt
          :Case 'HTTPHeader'
              ns.Req←MakeRequest data
              ns.Req.PeerCert←''
              ns.Req.PeerAddr←2⊃2⊃#.DRC.GetProp obj'PeerAddr'
              ns.Req.Server←⎕THIS
     
              :If Secure
                  (rc cert)←2↑#.DRC.GetProp obj'PeerCert'
                  :If rc=0
                      ns.Req.PeerCert←cert
                  :Else
                      ns.Req.PeerCert←'Could not obtain certificate'
                  :EndIf
              :EndIf
     
          :Case 'HTTPBody'
              ns.Req.ProcessBody data
          :Case 'HTTPChunk'
              ns.Req.ProcessChunk data
          :Case 'HTTPTrailer'
              ns.Req.ProcessTrailer data
          :EndSelect
     
          :If ns.Req.Complete
     
              :If ns.Req.Charset≡'utf-8'
                  ns.Req.Body←'UTF-8'⎕UCS ⎕UCS ns.Req.Body
              :EndIf
     
              (stop1/⍨~⊃1 DebugLevel 4+2×~0∊⍴ValidateRequestFn)⎕STOP⊃⎕SI
     stop1: ⍝ intentional stop for request-level debugging
              ⍬ ⎕STOP⊃⎕SI
     
              :If _htmlEnabled∧ns.Req.Response.Status≠200
                  ns.Req.Response.Headers←1 2⍴'Content-Type' 'text/html; charset=utf-8'
                  ns.Req.Response.Payload←'<h3>',(⍕ns.Req.Response.((⍕Status),' ',StatusText)),'</h3>'
                  →resp
              :EndIf
     
            ⍝ Application-specified validation
              rc←Validate ns.Req
              ns.Req.Fail 400×(ns.Req.Response.Status=200)∧0≠rc ⍝ default status 400 if not set by application
              →resp If rc≠0
     
              fn←1↓'.'@('/'∘=)ns.Req.Endpoint
     
            ⍝ Are we sessioned and requesting logout
              →handle↓⍨(0≠SessionTimeout)∧fn≡SessionStopEndpoint
              →resp⊣KillSession⍣(~ns.Req.Fail 400×0∊⍴r)⊢ns.Req.GetHeader SessionIdHeader
     
     handle:  fn RequestHandler ns ⍝ RequestHandler is either HandleJSONRequest or HandleRESTRequest
     
     resp:    obj Respond ns.Req
     
          :EndIf
      :EndHold
    ∇

    ∇ fn HandleJSONRequest ns;payload;resp;valence;nc;debug;ind;file
      →handle If'get'≢ns.Req.Method
      →0 If('Request method should be POST')ns.Req.Fail 405×~_htmlEnabled
      →handleHtml If~0∊⍴_htmlFolder
      ind←'' 'favicon.ico'⍳⊂fn
      →0 If(ind=2)∨'(Bad URI)'ns.Req.Fail 400×ind=3 ⍝ either fail with a bad URI or exit if favicon.ico (no-op)
      ns.Req.Response.Headers←1 2⍴'Content-Type' 'text/html; charset=utf-8'
      ns.Req.Response.Payload←HtmlPage
      →0
     
     handleHtml:
      :If (,'/')≡ns.Req.Endpoint
          file←_htmlFolder,_htmlDefaultPage
      :Else
          file←_htmlFolder,('/'=⊣/ns.Req.Endpoint)↓ns.Req.Endpoint
      :EndIf
      file←∊1 ⎕NPARTS file
      file,←(isDir file)/'/',_htmlDefaultPage
      →0 If ns.Req.Fail 400×~_htmlFolder begins file
      :If 0≠ns.Req.Fail 404×~⎕NEXISTS file
          →0 If 0=Report404InHTML
          ns.Req.Response.Headers←1 2⍴'Content-Type' 'text/html; charset=utf-8'
          ns.Req.Response.Payload←'<h3>Not found: ',(file↓⍨≢_htmlFolder),'</h3>'
          →0
      :EndIf
      ns.Req.Response.Payload←''file
      'Content-Type'ns.Req.DefaultHeader ns.Req.ContentTypeForFile file
      →0
     
     handle:
      →0 If HandleCORSRequest ns.Req
      →0 If('No function specified')ns.Req.Fail 400×0∊⍴fn
      →0 If('Unsupported request method')ns.Req.Fail 405×ns.Req.Method≢'post'
      →0 If('(Content-Type should be application/json',AllowFormData/' or multipart/form-data')ns.Req.Fail 400×(0∊⍴ns.Req.Body)⍱(⊂ns.Req.ContentType)∊(~AllowFormData)↓'multipart/form-data' 'application/json'
      →0 If'(Cannot accept query parameters)'ns.Req.Fail 400×~0∊⍴ns.Req.QueryParams
     
      :Select ns.Req.ContentType
      :Case 'application/json'
          :Trap 0 DebugLevel 1
              ns.Req.Payload←{0∊⍴⍵:⍵ ⋄ 0 JSONin ⍵}ns.Req.Body
          :Else
              →0⊣'Could not parse payload as JSON'ns.Req.Fail 400
          :EndTrap
      :Case 'multipart/form-data'
          :Trap 0 DebugLevel 1
              ns.Req.Payload←ParseMultipartForm ns.Req
          :Else
              →0⊣'Could not parse payload as multipart/form-data'ns.Req.Fail 400
          :EndTrap
      :EndSelect
     
      →0 If~fn CheckAuthentication ns.Req
     
      →0 If('Invalid function "',fn,'"')ns.Req.Fail CheckFunctionName fn
      →0 If('Invalid function "',fn,'"')ns.Req.Fail 404×3≠⌊|{0::0 ⋄ CodeLocation.⎕NC⊂⍵}fn  ⍝ is it a function?
      valence←|⊃CodeLocation.⎕AT fn
      →0 If('"',fn,'" is not a monadic result-returning function')ns.Req.Fail 400×1 1 0≢×valence
     
      ((~⊃1 DebugLevel 2)/stop1,stop2)⎕STOP⊃⎕SI ⍝ application level debugging?
     
      resp←''
      :Trap 0 DebugLevel 1
          :Trap 85
              :If 2=valence[2] ⍝ dyadic
     stop1:       resp←ns.Req{1 CodeLocation.(85⌶)'⍺ ',fn,' ⍵'}ns.Req.Payload ⍝ intentional stop for application-level debugging
              :Else
     stop2:       resp←{1 CodeLocation.(85⌶)fn,' ⍵'}ns.Req.Payload ⍝ intentional stop for application-level debugging
              :EndIf
          :EndTrap
          ⍬ ⎕STOP⊃⎕SI
      :Else
          ⍬ ⎕STOP⊃⎕SI
          →0⊣ns.Req.Fail 500
      :EndTrap
      →0 If 2≠⌊0.01×ns.Req.Response.Status ⍝ exit if not a successful HTTP code
      'content-type'ns.Req.DefaultHeader'application/json; charset=utf-8' ⍝ set the header if not set
      →0 If~'application/json'⍷ns.Req.(Response.Headers GetHeader'content-type') ⍝ if the response is JSON
      ns.Req.Response ToJSON resp ⍝ convert it
    ∇

    ∇ formData←ParseMultipartForm req;boundary;body;part;headers;payload;disposition;type;name;filename;tmp
      boundary←crlf,'--',req.Boundary ⍝ the HTTP standard prepends '--' to the boundary
      body←req.Body
      formData←⎕NS''
      body←⊃body splitOnFirst boundary,'--'  ⍝ drop off trailing boundary ('--' is appended to the trailing boundary)
      :For part :In (crlf,body)splitOn boundary ⍝ split into parts
          (headers payload)←part splitOnFirst crlf,crlf
          (disposition type)←deb¨2↑headers splitOn crlf
          (name filename)←deb¨2↑1↓disposition splitOn';'
          name←'"'~⍨2⊃name splitOn'='
          tmp←⎕NS''
          :If {¯1=⎕NC ⍵}name
              →0⊣'Invalid form field name for Jarvis'req.Fail 400
          :EndIf
          filename←'"'~⍨2⊃2↑filename splitOn'='
          tmp.(Name Filename)←name filename
          tmp.Content←payload
          tmp.Content_Type←deb 2⊃2↑type splitOn':'
          :If 0=formData.⎕NC name ⋄ formData{⍺⍎⍵,'←⍬'}name ⋄ :EndIf
          formData(name{⍺⍎⍺⍺,',←⍵'})tmp
      :EndFor
    ∇

    ∇ fn HandleRESTRequest ns;ind;exec;valence;ct;resp
      →0 If~fn CheckAuthentication ns.Req
     
      :If ParsePayload
          :Trap 0 DebugLevel 1
              :Select ns.Req.ContentType
              :Case 'application/json'
                  ns.Req.Payload←0 JSONin ns.Req.Body
              :Case 'application/xml'
                  ns.Req.(Payload←⎕XML Body)
              :EndSelect
          :Else
              →0⊣('Unable to parse request body as ',ct)ns.Req.Fail 400
          :EndTrap
      :EndIf
     
      ind←RESTMethods[;1](⍳nocase)⊂ns.Req.Method
      →0 If'Method not allowed'ns.Req.Fail 405×(≢RESTMethods)<ind
      exec←⊃RESTMethods[ind;2]
      →0 If'Not implemented'ns.Req.Fail 501×0∊⍴exec
     
      (stop1/⍨~⊃1 DebugLevel 2)⎕STOP⊃⎕SI
     
      resp←''
      :Trap 0 DebugLevel 1
          :Trap 85
     stop1:   resp←{1 CodeLocation.(85⌶)exec,' ⍵'}ns.Req  ⍝ intentional stop for application-level debugging
          :EndTrap
          ⍬ ⎕STOP⊃⎕SI
      :Else
          ⍬ ⎕STOP⊃⎕SI
          →0⊣ns.Req.Fail 500
      :EndTrap
      →0 If 2≠⌊0.01×ns.Req.Response.Status
      :If (ns.Req.(Response.Headers GetHeader'content-type')≡'')∧~0∊⍴DefaultContentType
          'content-type'ns.Req.SetHeader DefaultContentType
      :EndIf
      :If 'application/json'match⊃';'(≠⊆⊢)ns.Req.(Response.Headers GetHeader'content-type')
          ns.Req.Response ToJSON resp
      :EndIf
    ∇

    ∇ z←HandleCORSRequest req
      'Access-Control-Allow-Origin'req.DefaultHeader'*'
      →0 If~z←req.Method≡'options'
      'Access-Control-Allow-Methods'req.DefaultHeader'POST,OPTIONS'
      'Access-Control-Allow-Headers'req.DefaultHeader req.GetHeader'Access-Control-Request-Headers'
      'Access-Control-Max-Age'req.DefaultHeader'86400'
    ∇

    ∇ response ToJSON data
    ⍝ convert APL response payload to JSON
      :Trap 0 DebugLevel 1
          ns.Req.Response.Payload←⎕UCS'UTF-8'⎕UCS 1 JSONout resp
      :Else
          :If FlattenOutput>0
              :Trap 0 DebugLevel 1
                  ns.Req.Response.Payload←⎕UCS'UTF-8'⎕UCS JSON resp
                  :If FlattenOutput=2
                      Log'"',fn,'" returned data of rank > 1'
                  :EndIf
              :Else
                  →0⊣'Could not format result payload as JSON'ns.Req.Fail 500
              :EndTrap
          :Else
              →0⊣'Could not format result payload as JSON'ns.Req.Fail 500
          :EndIf
      :EndTrap
    ∇

    ∇ r←fn CheckAuthentication req
    ⍝ Check request authentication
    ⍝ r is 1 if request processing can continue (0 is returned if new session is created)
      r←0
      :If 0=SessionTimeout ⍝ not using sessions
          r←0=DoAuthentication req ⍝ might still want to do some authentication
      :Else
          :If 0∊⍴req.GetHeader SessionIdHeader ⍝ no session ID?
              :If SessionStartEndpoint≡fn ⍝ is this a session start request?
                  :If 0=DoAuthentication req ⍝ do we require authentication?
                      CreateSession req
                      r←0 ⍝ new session created
                  :EndIf
              :Else ⍝ no session ID and this is not the SessionStartEndpoint
                  'Unauthorized'req.Fail 401
                  :If HTTPAuthentication match'basic'
                      'WWW-Authenticate'req.SetHeader'Basic realm="Jarvis", charset="UTF-8"'
                  :EndIf
              :EndIf
          :Else ⍝ check session id
              r←CheckSession req
          :EndIf
      :EndIf
    ∇

    ∇ rc←DoAuthentication req;debug;old
    ⍝ rc is 0 if either no authentication is required or authentication succeeds
      rc←0
      :Trap 0 DebugLevel 1
          (stop1/⍨~⊃1 DebugLevel 2×~0∊⍴AuthenticateFn)⎕STOP⊃⎕SI
     stop1:rc←Authenticate req ⍝ intentional stop for application-level debugging
          ⍬ ⎕STOP⊃⎕SI
          :If rc≠0
              'Unauthorized'req.Fail 401
              :If HTTPAuthentication match'basic'
                  'WWW-Authenticate'req.SetHeader'Basic realm="Jarvis", charset="UTF-8"'
              :EndIf
          :EndIf
      :Else ⍝ Authenticate errored
          ⍬ ⎕STOP⊃⎕SI
          (⎕DMX.EM,' occured during authentication')req.Fail 500
          r←0
      :EndTrap
    ∇

    ∇ obj Respond req;status;z;res
      res←req.Response
      status←(⊂'HTTP/1.1'),res.((⍕Status)StatusText)
      res.Headers⍪←'server'(⊃Version)
      res.Headers⍪←'date'(2⊃#.DRC.GetProp'.' 'HttpDate')
      :If 0≠1⊃z←#.DRC.Send obj(status,res.Headers res.Payload)1
          Log'Conga error when sending response',GetIP obj
          Log⍕z
      :EndIf
      _connections.⎕EX obj
    ∇

    :EndSection ⍝ Request Handling

    ∇ ip←GetIP objname
      ip←{6::'' ⋄ ' (IP Address ',(⍕(_connections⍎⍵).IP),')'}objname
    ∇

    ∇ r←CheckFunctionName fn
    ⍝ checks the requested function name and returns
    ⍝    0 if the function is allowed
    ⍝  404 (not found) if the list of allowed functions is non-empty and fn is not in the list
    ⍝  403 (forbidden) if fn is in the list of disallowed functions
      :Access public
      r←0
      fn←,⊆fn
      →0 If r←403×fn∊AppInitFn ValidateRequestFn AuthenticateFn SessionStartEndpoint SessionStopEndpoint SessionInitFn
      :If ~0∊⍴_includeRegex
          →0 If r←404×0∊⍴(_includeRegex ⎕S'%')fn
      :EndIf
      :If ~0∊⍴_excludeRegex
          r←403×~0∊⍴(_excludeRegex ⎕S'%')fn
      :EndIf
    ∇

    :class Request
        :Field Public Instance Boundary←''       ⍝ boundary for content-type 'multipart/form-data'
        :Field Public Instance Charset←''        ⍝ content charset (defaults to 'utf-8' if content-type is application/json)
        :Field Public Instance Complete←0        ⍝ do we have a complete request?
        :Field Public Instance ContentType←''    ⍝ content-type header value
        :Field Public Instance Input←''
        :Field Public Instance Headers←0 2⍴⊂''   ⍝ HTTPRequest header fields (plus any supplied from HTTPTrailer event)
        :Field Public Instance Method←''         ⍝ HTTP method (GET, POST, PUT, etc)
        :Field Public Instance Endpoint←''       ⍝ Requested URI
        :Field Public Instance Body←''           ⍝ body of the request
        :Field Public Instance Payload←''        ⍝ parsed (if JSON or XML) payload
        :Field Public Instance PeerAddr←'unknown'⍝ client IP address
        :Field Public Instance PeerCert←0 0⍴⊂''  ⍝ client certificate
        :Field Public Instance HTTPVersion←''
        :Field Public Instance ErrorInfoLevel←2
        :Field Public Instance Response
        :Field Public Instance Server
        :Field Public Instance Session←⍬
        :Field Public Instance QueryParams←0 2⍴0
        :Field Public Instance UserID←''
        :Field Public Instance Password←''
        :Field Public Shared HttpStatus←↑(200 'OK')(201 'Created')(204 'No Content')(301 'Moved Permanently')(302 'Found')(303 'See Other')(304 'Not Modified')(305 'Use Proxy')(307 'Temporary Redirect')(400 'Bad Request')(401 'Unauthorized')(403 'Forbidden')(404 'Not Found')(405 'Method Not Allowed')(406 'Not Acceptable')(408 'Request Timeout')(409 'Conflict')(410 'Gone')(411 'Length Required')(412 'Precondition Failed')(413 'Request Entity Too Large')(414 'Request-URI Too Long')(415 'Unsupported Media Type')(500 'Internal Server Error')(501 'Not Implemented')(503 'Service Unavailable')

        ⍝ Content types for common file extensions
        :Field Public Shared ContentTypes←18 2⍴'txt' 'text/plain' 'htm' 'text/html' 'html' 'text/html' 'css' 'text/css' 'xml' 'text/xml' 'svg' 'image/svg+xml' 'json' 'application/json' 'zip' 'application/x-zip-compressed' 'csv' 'text/csv' 'pdf' 'application/pdf' 'mp3' 'audio/mpeg' 'pptx' 'application/vnd.openxmlformats-officedocument.presentationml.presentation' 'js' 'application/javascript' 'png' 'image/png' 'jpg' 'image/jpeg' 'bmp' 'image/bmp' 'jpeg' 'image/jpeg' 'woff' 'application/font-woff'

        GetFromTable←{(⍵[;1]⍳⊂,⍺)⊃⍵[;2],⊂''}
        split←{p←(⍺⍷⍵)⍳1 ⋄ ((p-1)↑⍵)(p↓⍵)} ⍝ Split ⍵ on first occurrence of ⍺
        lc←0∘(819⌶)
        deb←{{1↓¯1↓⍵/⍨~'  '⍷⍵}' ',⍵,' '}

        ∇ {r}←{message}Fail status
        ⍝ Set HTTP response status code and message if status≠0
          :Access public
          :If r←0≠1↑status
              :If 0=⎕NC'message'
                  :If 500=status
                      message←ErrorInfo
                  :Else
                      message←'' ⋄ :EndIf
              :EndIf
              message SetStatus status
          :EndIf
        ∇

        ∇ make
        ⍝ barebones constructor for interactive debugging (use Jarvis.MakeRequest '')
          :Access public
          :Implements constructor
          Response←⎕NS''
          Response.(Status StatusText Payload)←200 'OK' ''
          Response.Headers←0 2⍴'' ''
        ∇

        ∇ make1 args;query;origin;length;param;value;type
        ⍝ args is the result of Conga HTTPHeader event
          :Access public
          :Implements constructor
         
          (Method Input HTTPVersion Headers)←args
          Headers[;1]←lc Headers[;1]  ⍝ header names are case insensitive
          Method←lc Method
         
          (ContentType param)←deb¨2↑(';'(≠⊆⊢)GetHeader'content-type'),⊂''
          ContentType←lc ContentType
          (type value)←2↑⊆deb¨'='(≠⊆⊢)param
          :Select lc type
          :Case '' ⍝ no parameter set
              Charset←(ContentType≡'application/json')/'utf-8'
          :Case 'charset'
              Charset←lc value
          :Case 'boundary'
              Boundary←value
          :EndSelect
         
          Response←⎕NS''
          Response.(Status StatusText Payload)←200 'OK' ''
          Response.Headers←0 2⍴'' ''
         
          (Endpoint query)←'?'split Input
         
          :Trap 11 ⍝ trap domain error on possible bad UTF-8 sequence
              Endpoint←URLDecode Endpoint
              QueryParams←URLDecode¨2↑[2]↑'='(≠⊆⊢)¨'&'(≠⊆⊢)query
              :If 'basic '≡lc 6↑auth←GetHeader'authorization'
                  (UserID Password)←':'split Base64Decode 6↓auth
              :EndIf
          :Else
              Complete←1 ⍝ mark as complete
              Fail 400   ⍝ 400 = bad request
              →0
          :EndTrap
         
          Complete←('get'≡Method)∨(length←GetHeader'content-length')≡,'0' ⍝ we're a GET or 0 content-length
          Complete∨←(0∊⍴length)>∨/'chunked'⍷GetHeader'transfer-encoding' ⍝ or no length supplied and we're not chunked
        ∇

        ∇ ProcessBody args
          :Access public
          Body←args
          Complete←1
        ∇

        ∇ ProcessChunk args
          :Access public
        ⍝ args is [1] chunk content [2] chunk-extension name/value pairs (which we don't expect and won't process)
          Body,←1⊃args
        ∇

        ∇ ProcessTrailer args;inds;mask
          :Access public
          args[;1]←lc args[;1]
          mask←(≢Headers)≥inds←Headers[;1]⍳args[;1]
          Headers[mask/inds;2]←mask/args[;2]
          Headers⍪←(~mask)⌿args
          Complete←1
        ∇

        ∇ r←Hostname;h
          :Access public
          :If ~0∊⍴h←GetHeader'host'
              r←'http',(~Server.Secure)↓'s://',h
          :Else
              r←Server.Hostname
          :EndIf
        ∇
        ∇ r←URLDecode r;rgx;rgxu;i;j;z;t;m;⎕IO;lens;fill
          :Access public shared
        ⍝ Decode a Percent Encoded string https://en.wikipedia.org/wiki/Percent-encoding
          ⎕IO←0
          ((r='+')/r)←' '
          rgx←'[0-9a-fA-F]'
          rgxu←'%[uU]',(4×⍴rgx)⍴rgx ⍝ 4 characters
          r←(rgxu ⎕R{{⎕UCS 16⊥⍉16|'0123456789ABCDEF0123456789abcdef'⍳⍵}2↓⍵.Match})r
          :If 0≠⍴i←(r='%')/⍳⍴r
          :AndIf 0≠⍴i←(i≤¯2+⍴r)/i
              z←r[j←i∘.+1 2]
              t←'UTF-8'⎕UCS 16⊥⍉16|'0123456789ABCDEF0123456789abcdef'⍳z
              lens←⊃∘⍴¨'UTF-8'∘⎕UCS¨t  ⍝ UTF-8 is variable length encoding
              fill←i[¯1↓+\0,lens]
              r[fill]←t
              m←(⍴r)⍴1 ⋄ m[(,j),i~fill]←0
              r←m/r
          :EndIf
        ∇

          base64←{⎕IO ⎕ML←0 1              ⍝ from dfns workspace - Base64 encoding and decoding as used in MIME.
              chars←'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
              bits←{,⍉(⍺⍴2)⊤⍵}             ⍝ encode each element of ⍵ in ⍺ bits, and catenate them all together
              part←{((⍴⍵)⍴⍺↑1)⊂⍵}          ⍝ partition ⍵ into chunks of length ⍺
              0=2|⎕DR ⍵:2∘⊥∘(8∘↑)¨8 part{(-8|⍴⍵)↓⍵}6 bits{(⍵≠64)/⍵}chars⍳⍵  ⍝ decode a string into octets
              four←{                       ⍝ use 4 characters to encode either
                  8=⍴⍵:'=='∇ ⍵,0 0 0 0     ⍝   1,
                  16=⍴⍵:'='∇ ⍵,0 0         ⍝   2
                  chars[2∘⊥¨6 part ⍵],⍺    ⍝   or 3 octets of input
              }
              cats←⊃∘(,/)∘((⊂'')∘,)        ⍝ catenate zero or more strings
              cats''∘four¨24 part 8 bits ⍵
          }

        ∇ r←{cpo}Base64Encode w
        ⍝ Base64 Encode
        ⍝ Optional cpo (code points only) suppresses UTF-8 translation
        ⍝ if w is numeric (single byte integer), skip any conversion
          :Access public shared
          :If 83=⎕DR w ⋄ r←base64 w
          :ElseIf 0=⎕NC'cpo' ⋄ r←base64'UTF-8'⎕UCS w
          :Else ⋄ r←base64 ⎕UCS w
          :EndIf
        ∇

        ∇ r←{cpo}Base64Decode w
        ⍝ Base64 Decode
        ⍝ Optional cpo (code points only) suppresses UTF-8 translation
          :Access public shared
          :If 0=⎕NC'cpo' ⋄ r←'UTF-8'⎕UCS base64 w
          :Else ⋄ r←⎕UCS base64 w
          :EndIf
        ∇

        ∇ r←{table}GetHeader name
          :Access Public Instance
          :If 0=⎕NC'table' ⋄ table←Headers ⋄ :EndIf
          r←(lc name)GetFromTable table
        ∇

        ∇ name DefaultHeader value
          :Access public instance
          :If 0∊⍴Response.Headers GetHeader name
              name SetHeader value
          :EndIf
        ∇

        ∇ r←{endpoint}MakeURI resource
          :Access public instance
        ⍝ make a URI for a RESTful resource relative to the request endpoint
          :If 0≠⎕NC'endpoint'
              r←Hostname,endpoint,∊'/',¨⍕¨⊆resource
          :Else
              r←Hostname,Endpoint,∊'/',¨⍕¨⊆resource
          :EndIf
        ∇

        ∇ r←ErrorInfo
          r←⍕ErrorInfoLevel↑⎕DMX.(EM({⍵↑⍨⍵⍳']'}2⊃DM))
        ∇

        ∇ name SetHeader value
          :Access Public Instance
          Response.Headers⍪←name value
        ∇

        ∇ {status}←{statusText}SetStatus status
          :Access public instance
          :If status≠0
              :If 0=⎕NC'statusText'
              :OrIf 0∊⍴statusText
                  statusText←(HttpStatus[;1]⍳status)⊃HttpStatus[;2],⊂''
              :EndIf
              Response.(Status StatusText)←status statusText
          :EndIf
        ∇

        ∇ r←ContentTypeForFile filename;ext
          :Access public instance
          ext←⊂1↓3⊃⎕NPARTS filename
          r←(ContentTypes[;1]⍳ext)⊃ContentTypes[;2],⊂'text/html'
          r,←('text/html'≡r)/'; charset=utf-8'
        ∇

    :EndClass

    :Section SessionHandler

    ∇ InitSessions
    ⍝ initialize session handling
      :If 0≠SessionTimeout ⍝ are we using sessions?
          _sessions←⍬
          _sessionsInfo←0 5⍴0 ⍝ [;1] id, [;2] IP address, [;3] creation time, [;4] last active time, [;5] ref to session
          ⎕RL←⍬
          :If 0<SessionTimeout ⍝ is there a timeout set?  0> means no timeout and sessions are managed by the application
              _sessionThread←SessionMonitor&SessionTimeout
          :EndIf
      :EndIf
    ∇

    ∇ SessionMonitor timeout;expired;dead
      :Repeat
          :If 0<≢_sessionsInfo
              :Hold 'Sessions'
                  :If ∨/expired←SessionTimeout IsExpired _sessionsInfo[;4] ⍝ any expired?
                  ⍝ ↓↓↓ if a session expires, remove the namespace from _sessions
                  ⍝     but leave the entry in _sessionsInfo (removing the namespace reference)
                  ⍝     so that we can report to the user that his session timed out
                  ⍝     if he returns before SessionCleanupTime passes
                      _sessions~←expired/_sessionsInfo[;5] ⍝ remove from sessions list
                      (expired/_sessionsInfo[;5])←0        ⍝ remove reference from _sessionsInfo
                  :EndIf
                  ⍝ ↓↓↓ SessionCleanupTime is used to clean up _sessionsInfo after a session has expired
                  ⍝     In general SessionCleanupTime should be set to a value ≥ SessionTimeout
                  :If ∨/dead←(0=_sessionsInfo[;5])∧SessionCleanupTime IsExpired _sessionsInfo[;4] ⍝ any expired sessions need their info removed?
                      _sessionsInfo⌿⍨←~dead ⍝ remove from _sessionsInfo
                  :EndIf
              :EndHold
          :EndIf
          {}⎕DL timeout×60
      :EndRepeat
    ∇

    MakeSessionId←{⎕IO←0 ⋄((0(819⌶)⎕A),⎕A,⎕D)[(?20⍴62),5↑1↓⎕TS]}
    IsExpired←{⍺≤0: 0 ⋄ (Now-⍵)>(⍺×60000)÷86400000}

    ∇ r←DateToIDNX ts
    ⍝ Date to IDN eXtended
      :Access public shared
      r←(2 ⎕NQ'.' 'DateToIDN'(3↑ts))+(0 60 60 1000⊥¯4↑7↑ts)÷86400000
    ∇

    ∇ CreateSession req;ref;now;id;ts;rc
    ⍝ called in response to SessionStartEndpoint request, e.g. http://mysite.com/CreateSession
      id←MakeSessionId''
      now←Now
      :Hold 'Sessions'
          _sessions,←ref←⎕NS''
          _sessionsInfo⍪←id req.PeerAddr now now ref
          req.Session←ref
      :EndHold
      :If ~0∊⍴SessionInitFn
          :If 3=CodeLocation.⎕NC SessionInitFn
              :Trap 0 DebugLevel 1
                  (stop1/⍨~⊃1 DebugLevel 2)⎕STOP⊃⎕SI
                  :Trap 85
     stop1:           rc←SessionInitFn CodeLocation.{1(85⌶)⍺,' ⍵'}req
                  :Else ⋄ rc←0
                  :EndTrap
                  ⍬ ⎕STOP⊃⎕SI
                  :If 0≠rc
                      (_sessions _sessionsInfo)←¯1↓¨_sessions _sessionsInfo
                      →0⊣('Session intialization returned ',⍕rc)req.Fail 500
                  :EndIf
              :Else
                  ⍬ ⎕STOP⊃⎕SI
                  →0⊣(⎕DMX.EM,' occurred during session initialization failed')req.Fail 500
              :EndTrap
          :Else
              →0⊣('Session initialization function "',SessionInitFn,'" not found')req.Fail 500
          :EndIf
      :EndIf
      SessionIdHeader req.SetHeader id
      req.SetStatus 204
    ∇

    ∇ r←KillSession id;ind
    ⍝ forcibly kill a session
    ⍝ r is 1 if session was killed, 0 if not found
      :Hold 'Sessions'
          :If r←(≢_sessionsInfo)≥ind←_sessionsInfo[;1]⍳⊆id
              _sessions~←_sessionsInfo[ind;5]
              _sessionsInfo⌿⍨←ind≠⍳≢_sessionsInfo
          :EndIf
      :EndHold
    ∇

    ∇ req TimeoutSession ind
    ⍝ assumes :Hold 'Sessions' is set in calling environment
    ⍝ removes session from _sessions and marks it as time out in _sessionsInfo
      _sessions~←_sessionsInfo[ind;5]
      _sessionsInfo⌿←ind≠⍳≢_sessionsInfo
      'Session timed out'req.Fail 408
    ∇

    ∇ r←CheckSession req;ind;session;timedOut;id
    ⍝ check for valid session (only called if SessionTimeout≠0)
      r←0
      :Hold 'Sessions'
          ind←_sessionsInfo[;1]⍳⊂id←req.GetHeader SessionIdHeader
          →0 If'Invalid session ID'req.Fail 403×ind>≢_sessionsInfo
          :If 0∊⍴session←⊃_sessionsInfo[ind;5] ⍝ already timed out (session was already removed from _sessions)
          :OrIf SessionTimeout IsExpired _sessionsInfo[ind;4] ⍝ newly expired
              req TimeoutSession ind
          :EndIf
          SessionIdHeader req.SetHeader id
          _sessionsInfo[ind;4]←Now
          req.Session←session
          r←1
      :EndHold
    ∇

    :EndSection

    :Section Utilities

    If←((0∘≠⊃)⊢)⍴⊣
    stripQuotes←{'""'≡2↑¯1⌽⍵:¯1↓1↓⍵ ⋄ ⍵} ⍝ strip leading and ending "
    deb←{{1↓¯1↓⍵/⍨~'  '⍷⍵}' ',⍵,' '} ⍝ delete extraneous blanks
    dlb←{⍵↓⍨+/∧\' '=⍵} ⍝ delete leading blanks
    lc←0∘(819⌶) ⍝ lower case
    nocase←{(lc ⍺)⍺⍺ lc ⍵} ⍝ case insensitive operator
    begins←{⍺≡(⍴⍺)↑⍵} ⍝ does ⍺ begin with ⍵?
    ends←{⍺≡(-≢⍺)↑⍵} ⍝ does ⍺ end with ⍵?
    match←{⍺ (≡nocase) ⍵} ⍝ case insensitive ≡
    sins←{0∊⍴⍺:⍵ ⋄ ⍺} ⍝ set if not set

    ∇ r←crlf
      r←⎕UCS 13 10
    ∇

    ∇ r←Now
      :Access public shared
      r←DateToIDNX ⎕TS
    ∇

    ∇ r←flatten w
    ⍝ "flatten" arrays of rank>1
    ⍝ JSON cannot represent arrays of rank>1, so we "flatten" them into vectors of vectors (of vectors...)
      :Access public shared
      r←{(↓⍣(¯1+≢⍴⍵))⍵}w
    ∇

    ∇ r←{names}TableToNS table
    ⍝ transform a table into a vector of namespaces, one per row
    ⍝ names are the column names, if not supplied, the first row of the table is assumed to be the column names
      :Access public shared
      :If 0∊⍴table ⋄ →0⊣r←0⍴⎕NS'' ⋄ :EndIf
      :If 0=⎕NC'names' ⋄ names←table[1;] ⋄ table←1↓table ⋄ :EndIf
      :If 0∊⍴table ⋄ →0⊣r←0⍴⎕NS'' ⋄ :EndIf
      names←0∘(7162⌶)¨names
      r←⎕NS¨(≢table)⍴⊂''
      r(names{⍺.⍎'(',(⍕⍺⍺),')←⍵'})¨↓table
    ∇

    ∇ r←fmtTS ts
      :Access public shared
      r←,'G⊂9999/99/99 @ 99:99:99⊃'⎕FMT 100⊥6↑ts
    ∇

    ∇ r←a splitOn w
    ⍝ split a where w occurs (removing w from the result)
      :Access public shared
      r←a{⍺{(¯1+⊃¨⊆⍨⍵)↓¨⍵⊆⍺}(1+≢⍵)*⍵⍷⍺}w
    ∇

    ∇ r←a splitOnFirst w
    ⍝ split a on first occurence of w (removing w from the result)
      :Access public shared
      r←a{⍺{(¯1+⊃¨⊆⍨⍵)↓¨⍵⊆⍺}(1+≢⍵)*<\⍵⍷⍺}w
    ∇

    ∇ r←type ipRanges string;ranges
      :Access public shared
      r←''
      :Select ≢ranges←{('.'∊¨⍵){⊂1↓∊',',¨⍵}⌸⍵}string splitOn','
      :Case 0
          →0
      :Case 1
          r←,⊂((1+'.'∊⊃ranges)⊃'IPV6' 'IPV4')(⊃ranges)
      :Case 2
          r←↓'IPV4' 'IPV6',⍪ranges
      :EndSelect
      r←⊂(('Accept' 'Deny'⍳⊂type)⊃'AllowEndPoints' 'DenyEndPoints')r
    ∇

    ∇ r←leaven w
    ⍝ "leaven" JSON vectors of vectors (of vectors...) into higher rank arrays
      :Access public shared
      r←{
          0 1∊⍨≡⍵:⍵
          1=≢∪≢¨⍵:↑∇¨⍵
          ⍵
      }w
    ∇

    ∇ r←isRelPath w
    ⍝ is path w a relative path?
      r←{{~'/\'∊⍨(⎕IO+2×('Win'≡3↑⊃#.⎕WG'APLVersion')∧':'∊⍵)⊃⍵}3↑⍵}w
    ∇

    ∇ r←isDir path
    ⍝ is path a directory?
      r←{22::0 ⋄ 1=1 ⎕NINFO ⍵}path
    ∇

    ∇ r←SourceFile;class
      :Access public shared
      :If 0∊⍴r←4⊃5179⌶class←⊃∊⎕CLASS ⎕THIS
          r←{6::'' ⋄ ∊1 ⎕NPARTS ⍵⍎'SALT_Data.SourceFile'}class
      :EndIf
    ∇

    ∇ r←makeRegEx w
    ⍝ convert a simple search using ? and * to regex
      :Access public shared
      r←{0∊⍴⍵:⍵
          {'^',(⍵~'^$'),'$'}{¯1=⎕NC('A'@(∊∘'?*'))r←⍵:('/'=⊣/⍵)↓(¯1×'/'=⊢/⍵)↓⍵   ⍝ already regex? (remove leading/trailing '/'
              r←∊(⊂'\.')@('.'=⊢)r  ⍝ escape any periods
              r←'.'@('?'=⊢)r       ⍝ ? → .
              ∊(⊂'.*')@('*'=⊢)r    ⍝ * → .*
          }⍵            ⍝ add start and end of string markers
      }w
    ∇

    ∇ (rc msg)←{root}LoadFromFolder path;type;name;nsName;parts;ns;files;folders;file;folder;ref;r;m;findFiles;pattern
      :Access public
    ⍝ Loads an APL "project" folder
      (rc msg)←0 ''
      root←{6::⍵ ⋄ root}#
      findFiles←{
          (names type hidden)←0 1 6(⎕NINFO⍠1)∊1 ⎕NPARTS path,'/',⍵
          names/⍨(~hidden)∧type=2
      }
      files←''
      :For pattern :In ','(≠⊆⊢)LoadableFiles
          files,←findFiles pattern
      :EndFor
      folders←{
          (names type hidden)←0 1 6(⎕NINFO⍠1)∊1 ⎕NPARTS path,'/*'
          names/⍨(~hidden)∧type=1
      }⍬
      :For file :In files
          :Trap 11
              2 root.⎕FIX'file://',file
          :Else
              msg,←'Unable to ⎕FIX ',file,⎕UCS 13
          :EndTrap
      :EndFor
      :For folder :In folders
          nsName←2⊃1 ⎕NPARTS folder
          ref←0
          :Select root.⎕NC⊂nsName
          :Case 9.1 ⍝ namespace
              ref←root⍎nsName
          :Case 0   ⍝ not defined
              ref←⍎nsName root.⎕NS''
          :Else     ⍝ oops
              msg,←'"',folder,'" cannot be mapped to a valid namespace name',⎕UCS 13
          :EndSelect
          :If ref≢0
              (r m)←ref LoadFromFolder folder
              r←rc⌈r
              msg,←m
          :EndIf
      :EndFor
      msg←¯1↓msg
      rc←4××≢msg
    ∇
    :EndSection

    :Section JSON

    ∇ r←{debug}JSON array;typ;ic;drop;ns;preserve;quote;qp;eval;t;n
    ⍝ JSONify namespaces/arrays with elements of rank>1
      :Access public shared
      debug←{6::⍵ ⋄ debug}0
      array←{(↓⍣(¯1+≢⍴⍵))⍵}array
      :Trap debug↓0
          :If {(0∊⍴⍴⍵)∧0=≡⍵}array ⍝ simple?
              r←{⎕PP←34 ⋄ (2|⎕DR ⍵)⍲∨/b←'¯'=r←⍕⍵:r ⋄ (b/r)←'-' ⋄ r}array
              →0⍴⍨2|typ←⎕DR array ⍝ numbers?
              :Select ⎕NC⊂'array'
              :CaseList 9.4 9.2
                  ⎕SIGNAL(⎕THIS≡array)/⊂('EN' 11)('Message' 'Array cannot be a class')
              :Case 9.1
                  r←,'{'
                  :For n :In n←array.⎕NL-2 9.1
                      r,←'"',(∊((⊂'\'∘,)@(∊∘'"\'))n),'":' ⍝ name
                      r,←(debug JSON array⍎n),','  ⍝ the value
                  :EndFor
                  r←'}',⍨(-1<⍴r)↓r
              :Else ⋄ r←1⌽'""',escapedChars array
              :EndSelect
          :Else ⍝ is not simple (array)
              r←'['↓⍨ic←isChar array
              :If 0∊⍴array ⋄ →0⊣r←(1+ic)⊃'[]' '""'
              :ElseIf ic ⋄ r,←1⌽'""',escapedChars,array ⍝ strings are displayed as such
              :ElseIf 2=≡array
              :AndIf 0=≢⍴array
              :AndIf isChar⊃array ⋄ →0⊣r←⊃array
              :Else ⋄ r,←1↓∊',',¨debug JSON¨,array
              :EndIf
              r,←ic↓']'
          :EndIf
      :Else ⍝ :Trap 0
          (⎕SIGNAL/)⎕DMX.(EM EN)
      :EndTrap
    ∇

    isChar←{0 2∊⍨10|⎕DR ⍵}
      escapedChars←{
          str←⍵
          ~1∊b←str∊fnrbt←'"\/',⎕UCS 12 10 13 8 9:str
          (b/str)←'\"' '\\' '\/' '\f' '\n' '\r' '\b' '\t'[fnrbt⍳b/str]
          str
      }

    :EndSection

    :Section HTML
    ∇ r←ScriptFollows
      :Access public shared
      r←{⍵/⍨'⍝'≠⊃¨⍵}{1↓¨⍵/⍨∧\'⍝'=⊃¨⍵}{⍵{((∨\⍵)∧⌽∨\⌽⍵)/⍺}' '≠⍵}¨(1+2⊃⎕LC)↓↓(180⌶)2⊃⎕XSI
      r←2↓∊(⎕UCS 13 10)∘,¨r
    ∇

    ∇ r←HtmlPage
      r←ScriptFollows
⍝<!DOCTYPE html>
⍝<html>
⍝<head>
⍝<meta content="text/html; charset=utf-8" http-equiv="Content-Type">
⍝<title>Jarvis</title>
⍝</head>
⍝<body>
⍝<fieldset>
⍝  <legend>Request</legend>
⍝  <form id="myform">
⍝    <table>
⍝      <tr>
⍝        <td><label for="function">Method to Execute:</label></td>
⍝        <td><input id="function" name="function" type="text"></td>
⍝      </tr>
⍝      <tr>
⍝        <td><label for="payload">JSON Data:</label></td>
⍝        <td><textarea id="payload" cols="100" name="payload" rows="10"></textarea></td>
⍝      </tr>
⍝      <tr>
⍝        <td colspan="2"><button onclick="doit()" type="button">Send</button></td>
⍝      </tr>
⍝    </table>
⍝  </form>
⍝</fieldset>
⍝<fieldset>
⍝  <legend>Response</legend>
⍝  <div id="result">
⍝  </div>
⍝</fieldset>
⍝<script>
⍝function doit() {
⍝  document.getElementById("result").innerHTML = "";
⍝  var xhttp = new XMLHttpRequest();
⍝  var fn = document.getElementById("function").value;
⍝  fn = (0 == fn.indexOf('/')) ? fn : '/' + fn;
⍝
⍝  xhttp.open("POST", fn, true);
⍝  xhttp.setRequestHeader("content-type", "application/json; charset=utf-8");
⍝
⍝  xhttp.onreadystatechange = function() {
⍝    if (this.readyState == 4){
⍝      if (this.status == 200) {
⍝        var resp = "<pre><code>" + this.responseText + "</code></pre>";
⍝      } else {
⍝        var resp = "<span style='color:red;'>" + this.statusText + "</span>";
⍝      }
⍝      document.getElementById("result").innerHTML = resp;
⍝    }
⍝  }
⍝  xhttp.send(document.getElementById("payload").value);
⍝}
⍝</script>
⍝</body>
⍝</html>
    ∇
    :EndSection

:EndClass
