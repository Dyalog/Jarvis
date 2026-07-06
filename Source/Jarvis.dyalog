:Class Jarvis
⍝ Dyalog Web Service Server
⍝ See https://dyalog.github.io/Jarvis for documentation

    (⎕ML ⎕IO)←1 1

    ∇ r←Version
      :Access public shared
      r←'Jarvis' '1.22.5' '2026-07-03'
    ∇

    ∇ Documentation
      :Access public shared
      ⎕←'See https://dyalog.github.io/Jarvis'
    ∇

  ⍝ User hooks settings
    :Field Public AppCloseFn←''                                ⍝ name of the function to run on application (server) shutdown
    :Field Public AppInitFn←''                                 ⍝ name of the application "bootstrap" function
    :Field Public AuthenticateFn←''                            ⍝ name of function to perform authentication,if empty, no authentication is necessary
    :Field Public PostProcessFn←''                             ⍝ name of the function to be called after the endpoint but before the response is sent
    :Field Public SessionInitFn←''                             ⍝ Function name to call when initializing a session
    :Field Public ValidateRequestFn←''                         ⍝ name of the request validation function

   ⍝ Operational settings
    :Field Public CodeLocation←'#'                             ⍝ reference to application code location, if the user specifies a folder or file, that value is saved in CodeSource
    :Field Public ConnectionTimeout←30                         ⍝ HTTP/1.1 connection timeout in seconds
    :Field Public Debug←0                                      ⍝ 0 = all errors are trapped, 1 = stop on an error, 2 = stop on intentional error before processing request, 4 = Jarvis framework debugging, 8 = Conga event logging, 16 = just before response
    :Field Public DefaultContentType←'application/json; charset=utf-8'
    :Field Public ErrorInfoLevel←1                             ⍝ level of information to provide if an APL error occurs, 0=none, 1=⎕EM, 2=⎕SI
    :Field Public Hostname←''                                  ⍝ external-facing host name
    :Field Public HTTPAuthentication←'basic'                   ⍝ valid settings are currently 'basic' or ''
    :Field Public JarvisConfig←''                              ⍝ configuration file path (if any). This parameter was formerly named ConfigFile
    :Field Public LoadableFiles←'*.apl?,*.dyalog'              ⍝ file patterns that can be loaded if loading from folder
    :Field Public Logging←1                                    ⍝ turn logging on/off
    :Field Public Paradigm←'JSON'                              ⍝ either 'JSON' or 'REST'
    :Field Public Report404InHTML←1                            ⍝ Report HTTP 404 status (not found) in HTML (only valid if HTML interface is enabled)
    :Field Public UseZip←0                                     ⍝ Use compression if client allows it, 0- don't compress, 0<- compress if UseZip≤≢payload
    :Field Public ZipLevel←3                                   ⍝ default compression level (0-9)
    :Field APLVersion                                          ⍝ Dyalog APL major.minor version number
    :Field TokenBase←0                                         ⍝ base for tokens (possibly updated in Start if ⎕TALLOC is available)

   ⍝ Container-related settings
    :Field Public DYALOG_JARVIS_THREAD←''                      ⍝ 0 = Run in thread 0, 1 = Use separate thread and ⎕TSYNC, 'DEBUG' = Use separate thread and return to immediate execution, "AUTO" = if InTerm use "DEBUG" otherwise 1
    :Field Public DYALOG_JARVIS_CODELOCATION←''                ⍝ If supplied, overrides CodeLocation in config file
    :Field Public DYALOG_JARVIS_PORT←''                        ⍝ If supplied, overrides Port both default port and config file

   ⍝ Session settings
    :Field Public SessionIdHeader←'Jarvis-SessionID'           ⍝ Name of the header field for the session token
    :Field Public SessionUseCookie←0                           ⍝ 0 - just use the header; 1 - use an HTTP cookie
    :Field Public SessionPollingTime←1                         ⍝ how frequently (in minutes) we should poll for timed out sessions
    :Field Public SessionTimeout←0                             ⍝ 0 = do not use sessions, ¯1 = no timeout , 0< session timeout time (in minutes)
    :Field Public SessionCleanupTime←60                        ⍝ how frequently (in minutes) do we clean up timed out session info from _sessionsInfo

   ⍝ JSON mode settings
    :Field Public AllowFormData←0                              ⍝ do we allow POST form data in JSON paradigm?
    :Field Public AllowGETs←0                                  ⍝ do we allow calling endpoints with HTTP GETs?
    :Field Public JSONInputFormat←'D'                          ⍝ set this to 'M' to have Jarvis convert JSON request payloads to the ⎕JSON matrix format

   ⍝ REST mode settings
    :Field Public ParsePayload←1                               ⍝ 1=parse request payload based on content-type header (REST only)
    :Field Public RESTFailProcessing←0                         ⍝ 0 - don't do anything on failed request, 1 - process response payload as "normal"
    :Field Public RESTMethods←'Get,Post,Put,Delete,Patch,Options'

  ⍝ CORS settings
    :Field Public EnableCORS←1                                 ⍝ set to 0 to disable CORS
    :Field Public CORS_Origin←'*'                              ⍝ default value for Access-Control-Allow-Origin header (set to 1 to reflect request Origin)
    :Field Public CORS_Methods←¯1                              ⍝ ¯1 = set based on paradigm, 1 = reflect the request's requested method
    :Field Public CORS_Headers←'*'                             ⍝ default value for Access-Control-Allow-Headers header (set to 1 to reflect request Headers)
    :Field Public CORS_MaxAge←60                               ⍝ default value (in seconds) for Access-Control-Max-Age header

  ⍝ Conga-related settings
    :Field Public AcceptFrom←⍬                                 ⍝ Conga: IP addresses to accept requests from - empty means accept from any IP address
    :Field Public BufferSize←10000                             ⍝ Conga: buffer size
    :Field Public DenyFrom←⍬                                   ⍝ Conga: IP addresses to refuse requests from - empty means deny none
    :Field Public DOSLimit←¯1                                  ⍝ Conga: DOSLimit, ¯1 means use default
    :Field Public FIFO←1                                       ⍝ Conga: Use FIFO mode?
    :Field Public Port←8080                                    ⍝ Conga: Default port to listen on
    :Field Public RootCertDir←''                               ⍝ Conga: Root CA certificate folder
    :field Public Priority←'NORMAL:!CTYPE-OPENPGP'             ⍝ Conga: Priorities for GnuTLS when negotiation connection
    :Field Public Secure←0                                     ⍝ 0 = use HTTP, 1 = use HTTPS
    :field Public ServerCertSKI←''                             ⍝ Conga: Server cert's Subject Key Identifier from store
    :Field Public ServerCertFile←''                            ⍝ Conga: public certificate file
    :Field Public ServerKeyFile←''                             ⍝ Conga: private key file
    :Field Public ServerName←''                                ⍝ Server name, '' means Conga assigns it
    :Field Public SSLValidation←64                             ⍝ Conga: request, but do not require a client certificate
    :Field Public WaitTimeout←15000                            ⍝ ms to wait in LDRC.Wait

    :Field Public Shared LDRC←''                               ⍝ Jarvis-set reference to Conga after CongaRef has been resolved
    :Field Public Shared CongaPath←''                          ⍝ user-supplied path to Conga workspace and/or shared libraries
    :Field Public Shared CongaRef←''                           ⍝ user-supplied reference to Conga library instance
    :Field CongaVersion←''                                     ⍝ Conga version

    :Property CodeSource
    :Access Public
        ∇ r←get
          r←_codeSource
        ∇
    :EndProperty

    :Property HTMLInterface ⍝ ¯1=unassigned, 0/1=dis/allow the HTML interface, 'Path to HTML[/home-page]', or '' 'fn'
    :Access public
        ∇ r←get
          r←_htmlInterface
        ∇

        ∇ set args;html;t;old_htmlInterface;old_htmlFolder;old_htmlDefaultPage;current;reset
        ⍝ capture current state
          current←⎕NS''
          current.(_htmlInterface _htmlEnabled _htmlRootFn _htmlFolder _htmlDefaultPage _homePage)←_htmlInterface _htmlEnabled _htmlRootFn _htmlFolder _htmlDefaultPage _homePage
         
        ⍝ build function to reset current state to avoid duplication of code below
          reset←{(_htmlInterface _htmlEnabled _htmlRootFn _htmlFolder _htmlDefaultPage _homePage)∘←current.(_htmlInterface _htmlEnabled _htmlRootFn _htmlFolder _htmlDefaultPage _homePage)}
         
        ⍝ set default state
          (_htmlEnabled _htmlRootFn _htmlFolder _htmlDefaultPage _homePage)←0 '' '' 'index.html' 1 ⍝ reset original field values
         
          :Select ⊃_htmlInterface←args.NewValue
          :Case 0 ⍝ explicitly no HTML interface, carry on
          :Case 1 ⍝ explicitly turned on
              :If Paradigm≢⍥⎕C'JSON'
                  reset''
                  'HTML interface is only available using JSON paradigm'⎕SIGNAL 11
              :EndIf
              _htmlEnabled←1
          :Case ¯1 ⍝ turn on if JSON paradigm
              _htmlEnabled←Paradigm≡⍥⎕C'JSON' ⍝ if not specified, HTML interface is enabled for JSON paradigm
          :Else
              :If Paradigm≢⍥⎕C'JSON'
                  reset''
                  'HTML interface is only available using JSON paradigm'⎕SIGNAL 11
              :EndIf
              :If 1<|≡_htmlInterface ⍝ is it '' 'function'?
                  t←2⊃_htmlInterface
                  :If ∧/(⊃({2=⎕NC'⍵':⍎⍵ ⋄ ⍵}CodeLocation).⎕AT t)∊¨1(1 ¯2)0
                      _htmlRootFn←t
                      _htmlEnabled←1
                      _homePage←1
                  :Else
                      reset''
                      ('HTML root function "',(⍕CodeLocation),'.',t,'" is not a monadic or ambivalent, result-returning function.')⎕SIGNAL 11
                  :EndIf
              :Else ⍝  otherwise it's 'file/folder'
                  _htmlEnabled←1
                  html←1 ⎕NPARTS((isRelPath _htmlInterface)/_rootFolder),_htmlInterface
                  :If isDir∊html
                      _htmlFolder←{⍵,('/'=⊢/⍵)↓'/'}∊html
                  :Else
                      _htmlFolder←1⊃html
                      _htmlDefaultPage←∊1↓html
                  :EndIf
                  _homePage←⎕NEXISTS html←_htmlFolder,_htmlDefaultPage
                  :If _started
                  :AndIf ~_homePage
                      reset''
                      ('HTML home page file "',(∊html),'" not found.')⎕SIGNAL 6
                  :EndIf
              :EndIf
          :EndSelect
        ∇
    :EndProperty

  ⍝ IncludeFns/ExcludeFns Properties
    :Property IncludeFns, ExcludeFns
    ⍝ IncludeFns and ExcludeFns are vectors the defined endpoint (function) names to expose or hide respectively
    ⍝ They can be function names, simple wildcarded patterns (e.g. 'Foo*'), or regex
    :Access Public
        ∇ r←get ipa
          r←⍎'_',ipa.Name
        ∇
        ∇ set ipa
          :Select ipa.Name
          :Case 'IncludeFns'
              _includeRegex←makeRegEx¨(⊂'')~⍨∪,⊆_IncludeFns←ipa.NewValue
          :Case 'ExcludeFns'
              _excludeRegex←makeRegEx¨(⊂'')~⍨∪,⊆_ExcludeFns←ipa.NewValue
          :EndSelect
        ∇
    :EndProperty

  ⍝↓↓↓ some of these private fields are also set in ∇init so that a server can be stopped, updated, and restarted
    :Field _rootFolder←''                ⍝ root folder for relative file paths
    :Field _codeSource←''                ⍝ file or folder that code was loaded from, if applicable
    :Field _configLoaded←0               ⍝ indicates whether config was already loaded by Autostart
    :Field _homePage←1                   ⍝ default is to use built-in home page
    :Field _htmlFolder←''                ⍝ folder containing HTML interface files, if any
    :Field _htmlDefaultPage←'index.html' ⍝ default page name if HTMLInterface is set to serve from a folder
    :Field _htmlEnabled←0                ⍝ is the HTML interface enabled?
    :Field _htmlInterface←¯1             ⍝ ¯1=unassigned, 0/1=dis/allow the HTML interface, 'Path to HTML[/home-page]', or '' 'fn'
    :Field _htmlRootFn←''                ⍝ function name if serving HTML root from a function rather than file
    :Field _stop←0                       ⍝ set to 1 to stop server
    :Field _started←0                    ⍝ is the server started
    :Field _stopped←1                    ⍝ is the server stopped
    :field _paused←0                     ⍝ is the server paused
    :Field _sessionThread←¯1             ⍝ thread for the session cleanup process
    :Field _serverThread←¯1              ⍝ thread for the HTTP server
    :Field _taskThreads←⍬                ⍝ vector of thread handling requests
    :Field _sessions←⍬                   ⍝ vector of session namespaces
    :Field _sessionsInfo←0 5⍴'' '' 0 0 0 ⍝ [;1] id [;2] ip addr [;3] creation time [;4] last active time [;5] ref to session
    :Field _IncludeFns←''                ⍝ private IncludeFns
    :Field _ExcludeFns←''                ⍝ private ExcludeFns
    :Field _includeRegex←''              ⍝ private compiled regex from _IncludeFns
    :Field _excludeRegex←''              ⍝ private compiled regex from _ExcludeFns
    :Field _connections                  ⍝ namespace containing open connections

    ∇ r←Config
    ⍝ returns current configuration
      :Access public
      r←↑{⍵(⍎⍵)}¨⎕THIS⍎'⎕NL ¯2.2 ¯2.1 ¯2.3'
    ∇

    ∇ r←{value}DebugLevel level
    ⍝  monadic: return 1 if level is within Debug (powers of 2)
    ⍝    example: stopIf DebugLevel 2  ⍝ sets a stop if Debug contains 2
    ⍝  dyadic:  return value unless level is within Debug (powers of 2)
    ⍝    example: :Trap 0 DebugLevel 5 ⍝ set Trap 0 unless Debug contains 1 or 4 in its
      r←∨/(2 2 2 2 2⊤⊃Debug)∨.∧2 2 2 2 2⊤level
      :If 0≠⎕NC'value'
          r←value/⍨~r
      :EndIf
    ∇

    ∇ r←Thread
    ⍝ return the thread that the server is running in
      :Access public
      r←_serverThread∩⎕TNUMS
    ∇

    ∇ {msg}←{level}Log msg;ts;fmsg
      :Access public overridable
      :If Logging>0∊⍴msg
          ts←((ErrorInfoLevel=2)/(2⊃⎕SI),'[',(⍕2⊃⎕LC),'] '),fmtTS ⎕TS
          :If 1=≢⍴fmsg←⍕msg
          :OrIf 1=⊃⍴fmsg
              fmsg←ts,' - ',fmsg
          :Else
              fmsg←ts,∊(⎕UCS 13),fmsg
          :EndIf
          ⎕←fmsg
      :EndIf
    ∇

    ∇ r←New arg
    ⍝ create a new instance of Jarvis
      :Access public shared
      :If 0∊⍴arg
          r←##.⎕NEW ⎕THIS
      :Else
          r←##.⎕NEW ⎕THIS arg
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
      APLVersion←⊃⊃(//)⎕VFI{⍵/⍨2>+\'.'=⍵}2⊃#.⎕WG'APLVersion'
      :Trap 11
          JSONin←0 ##.⎕JSON⍠('Dialect' 'JSON5')('Format'JSONInputFormat)⊢ ⋄ {}JSONin'1'
          JSONout←1 ##.⎕JSON⍠'HighRank' 'Split'⊢ ⋄ {}JSONout 1
          JSONread←0 ##.⎕JSON⍠'Dialect' 'JSON5'⊢ ⍝ for reading configuration files
      :Else
          JSONin←0 ##.⎕JSON⍠('Format'JSONInputFormat)⊢
          JSONout←1 ##.⎕JSON⊢
          JSONread←0 ##.⎕JSON⊢
      :EndTrap
    ∇

    ∇ r←args default defaults
      args←,⊆args
      r←(≢defaults)↑args,(≢args)↓defaults
    ∇

    ∇ Close
      :Implements destructor
      {0:: ⋄ {}LDRC.Close ServerName}⍬
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
          (rc msg)←(r←New args).Start
      :Else
          (r rc msg)←'' ¯1 ⎕DMX.EM
      :EndTrap
      r←(r(rc msg))
    ∇

    ∇ (rc msg)←Start;html
      :Access public
      :Trap 0 DebugLevel 1
          Log'Starting ',⍕2↑Version
          :If _started
              :If 0(,2)≡LDRC.GetProp ServerName'Pause'
                  rc←1⊃LDRC.SetProp ServerName'Pause' 0
                  →0 If(rc'Failed to unpause server')
                  (rc msg)←0 'Server resuming operations'
                  →0
              :EndIf
              →0 If(rc msg)←¯1 'Server thinks it''s already started'
          :EndIf
     
          :If _stop
              →0 If(rc msg)←¯1 'Server is in the process of stopping'
          :EndIf
     
          :If 'CLEAR WS'≡⎕WSID
              :If ⎕NEXISTS JarvisConfig
              :AndIf 2=⊃1 ⎕NINFO JarvisConfig
                  _rootFolder←⊃1 ⎕NPARTS JarvisConfig
              :Else
                  _rootFolder←⊃1 ⎕NPARTS SourceFile
              :EndIf
          :Else
              _rootFolder←⊃1 ⎕NPARTS ⎕WSID
          :EndIf
     
          →0 If(rc msg)←LoadConfiguration JarvisConfig
          →0 If(rc msg)←CheckPort
          →0 If(rc msg)←CheckCodeLocation
          →0 If(rc msg)←Setup
          →0 If(rc msg)←LoadConga
     
          :If 19≤APLVersion ⍝ ⎕TALLOC appeared in v19.0
              TokenBase←⎕TALLOC 1 'Jarvis'
          :EndIf
     
          HTMLInterface←_htmlInterface ⍝ because _rootFolder might have been set after the property
     
          :If EnableCORS ⍝ if we've enabled CORS
          :AndIf ¯1∊CORS_Methods ⍝ but not set any pre-flighted methods
              :If Paradigm≡'JSON'
                  CORS_Methods←'GET,POST,OPTIONS' ⍝ allowed JSON methods are GET, POST, and OPTIONS
              :Else
                  CORS_Methods←1↓∊',',¨RESTMethods[;1] ⍝ allowed REST methods are what the service supports
              :EndIf
          :EndIf
     
          CORS_Methods←uc CORS_Methods
     
          →0 If(rc msg)←StartServer
     
          Log'Jarvis starting in "',Paradigm,'" mode on port ',⍕Port
          Log'Serving code in ',(⍕CodeLocation),(CodeSource≢'')/' (populated with code from "',CodeSource,'")'
          Log(_htmlEnabled∧_homePage)/'Click http',(~Secure)↓'s://',MyAddr,':',(⍕Port),' to access web interface'
     
      :Else ⍝ :Trap
          (rc msg)←¯1 ⎕DMX.EM
      :EndTrap
    ∇

    ∇ (rc msg)←Stop;ts;tokens
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
      {0:: ⋄ {}LDRC.Close 2⊃LDRC.Clt'' ''Port'http'}''
      :While ~_stopped
          :If WaitTimeout<⎕AI[3]-ts
              →0⊣(rc msg)←¯1 'Server seems stuck'
          :EndIf
      :EndWhile
      :If 0≠TokenBase
          :If ~0∊⍴tokens←TokenBase ⎕TALLOC 2 ⍝ any lingering tokens?
              {}⎕TGET tokens ⍝ remove them
          :EndIf
          TokenBase ⎕TALLOC ¯1 ⍝ remove token pool
      :Else
          {}⎕TGET{⍵/⍨1=1 100000000⍸⍵}⎕TPOOL ⍝ remove tokens in the Conga connection number range
      :EndIf
      (rc msg)←0 'Server stopped'
    ∇

    ∇ (rc msg)←Pause
      :Access public
      →0 If~_started⊣(rc msg)←¯1 'Server is not running'
      →0 If 2=⊃2⊃LDRC.GetProp ServerName'Pause'⊣(rc msg)←¯2 'Server is already paused'
      →0 If 0≠rc←⊃LDRC.SetProp ServerName'Pause' 2⊣msg←'Error attempting to pause server'
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
      r←~_stopped
    ∇

    ∇ (rc msg)←CheckPort;p
    ⍝ check for valid port number
      :If DYALOG_JARVIS_PORT≢''  ⍝ environment variable takes precedence
          Port←DYALOG_JARVIS_PORT
      :EndIf
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
          public←⎕THIS⍎'⎕NL ¯2.2 ¯2.1 ¯2.3' ⍝ find all the public fields in this class
          :If ~0∊⍴set←public∩config.⎕NL ¯2 ¯9
              config{⍎⍵,'←⍺⍎⍵'}¨set
          :EndIf
          _configLoaded←1
      :Else
          →0⊣(rc msg)←⎕DMX.EN ⎕DMX.(EM,(~0∊⍴Message)/' (',Message,')')
      :EndTrap
    ∇

    ∇ (rc msg)←LoadConga;ref;root;nc;n;ns;congaCopied;class;path
      ⍝↓↓↓ Check if LDRC exists (VALUE ERROR (6) if not), and is LDRC initialized? (NONCE ERROR (16) if not)
     
      (rc msg)←1 ''
     
      :Hold 'JarvisInitConga'
          :If {6 16 999::1 ⋄ ''≡LDRC:1 ⋄ 0⊣LDRC.Describe'.'}''
              LDRC←''
              :If ~0∊⍴CongaRef  ⍝ did the user supply a reference to Conga?
                  LDRC←ResolveCongaRef CongaRef
                  →∆END↓⍨0∊⍴msg←(''≡LDRC)/'CongaRef (',(⍕CongaRef),') does not point to a valid instance of Conga'
              :Else
                  :For root :In ## #
                      ref nc←root{1↑¨⍵{(×⍵)∘/¨⍺ ⍵}⍺.⎕NC ⍵}ns←'Conga' 'DRC'
                      :If 9=⊃⌊nc ⋄ :Leave ⋄ :EndIf
                  :EndFor
     
                  :If 9=⊃⌊nc
                      LDRC←ResolveCongaRef root⍎∊ref
                      →∆END↓⍨0∊⍴msg←(''≡LDRC)/(⍕root),'.',(∊ref),' does not point to a valid instance of Conga'
                      →∆COPY↓⍨{999::0 ⋄ 1⊣LDRC.Describe'.'}'' ⍝ it's possible that Conga was saved in a semi-initialized state
                      Log'Conga library found at ',(⍕root),'.',∊ref
                  :Else
     ∆COPY:
                      class←⊃⊃⎕CLASS ⎕THIS
                      congaCopied←0
                      :For n :In ns
                          :For path :In (1+0∊⍴CongaPath)⊃(⊂CongaPath)((DyalogRoot,'ws/')'') ⍝ if CongaPath specified, use it exclusively
                              :Trap Debug↓0
                                  n class.⎕CY path,'conga'
                                  LDRC←ResolveCongaRef(class⍎n)
                                  →∆END↓⍨0∊⍴msg←(''≡LDRC)/n,' was copied from ',path,'conga but is not valid'
                                  Log n,' copied from ',path,'conga'
                                  →∆COPIED⊣congaCopied←1
                              :EndTrap
                          :EndFor
                      :EndFor
                      →∆END↓⍨0∊⍴msg←(~congaCopied)/'Neither Conga nor DRC were successfully copied from [DYALOG]/ws/conga'
     ∆COPIED:
                  :EndIf
              :EndIf
          :EndIf
          CongaVersion←1 0.1+.×2↑LDRC.Version
          LDRC.X509Cert.LDRC←LDRC ⍝ reset X509Cert.LDRC reference
          Log'Local Conga v',(⍕CongaVersion),' reference is ',⍕LDRC
          rc←0
     ∆END:
      :EndHold
    ∇

    ∇ LDRC←ResolveCongaRef CongaRef;z;failed
    ⍝ Attempt to resolve what CongaRef refers to
    ⍝ CongaRef can be a charvec, reference to the Conga or DRC namespaces, or reference to an iConga instance
    ⍝ LDRC is '' if Conga could not be initialized, otherwise it's a reference to the the Conga.LIB instance or the DRC namespace
     
      LDRC←'' ⋄ failed←0
      :Select nameClass CongaRef ⍝ what is it?
      :Case 9.1 ⍝ namespace?  e.g. CongaRef←DRC or Conga
     ∆TRY:
          :Trap 0 DebugLevel 1
              :If ∨/'.Conga'⍷⍕CongaRef ⋄ LDRC←CongaPath CongaRef.Init'Jarvis' ⍝ is it Conga?
              :ElseIf 0≡⊃CongaRef.Init CongaPath ⋄ LDRC←CongaRef ⍝ DRC?
              :Else ⋄ →∆EXIT⊣LDRC←''
              :End
          :Else ⍝ if Jarvis is reloaded and re-executed in rapid succession, Conga initialization may fail, so we try twice
              :If failed ⋄ →∆EXIT⊣LDRC←''
              :Else ⋄ →∆TRY⊣failed←1
              :EndIf
          :EndTrap
      :Case 9.2 ⍝ instance?  e.g. CongaRef←Conga.Init ''
          LDRC←CongaRef ⍝ an instance is already initialized
      :Case 2.1 ⍝ variable?  e.g. CongaRef←'#.Conga'
          :Trap 0 DebugLevel 1
              LDRC←ResolveCongaRef(⍎∊⍕CongaRef)
          :EndTrap
      :EndSelect
     ∆EXIT:
    ∇

    ∇ (rc msg secureParams)←CreateSecureParams;cert;certs;msg;inds
    ⍝ return Conga parameters for running HTTPS, if Secure is set to 1
     
      LDRC.X509Cert.LDRC←LDRC ⍝ make sure the X509 instance points to the right LDRC
      (rc secureParams msg)←0 ⍬''
      :If Secure
          :If ~0∊⍴RootCertDir ⍝ on Windows not specifying RootCertDir will use MS certificate store
              →∆EXIT If(rc msg)←'RootCertDir'Exists RootCertDir
              →∆EXIT If(rc msg)←{(⊃⍵)'Error setting RootCertDir'}LDRC.SetProp'.' 'RootCertDir'RootCertDir
⍝ The following is commented out because it seems the GnuTLS knows to use the operating system's certificate collection even on non-Windows platforms
⍝          :ElseIf ~isWin
⍝              →∆EXIT⊣(rc msg)←¯1 'No RootCertDir spcified'
          :EndIf
          :If 0∊⍴ServerCertSKI ⍝ no certificate ID specified, check for Cert and Key files
              →∆EXIT If(rc msg)←'ServerCertFile'Exists ServerCertFile
              →∆EXIT If(rc msg)←'ServerKeyFile'Exists ServerKeyFile
              :Trap 0 DebugLevel 1
                  cert←⊃LDRC.X509Cert.ReadCertFromFile ServerCertFile
              :Else
                  (rc msg)←⎕DMX.EN('Unable to decode ServerCertFile "',(∊⍕ServerCertFile),'" as a certificate')
                  →∆EXIT
              :EndTrap
              cert.KeyOrigin←'DER'ServerKeyFile
          :ElseIf isWin ⍝ ServerCertSKI only on Windows
              certs←LDRC.X509Cert.ReadCertUrls
              :If 0∊⍴certs
                  →∆EXIT⊣(rc msg)←8 'No certificates found in Microsoft Certificate Store'
              :Else
                  inds←1+('id=',ServerCertSKI,';')⎕S{⍵.BlockNum}⍠'Greedy' 0⊢2⊃¨certs.CertOrigin
                  :If 1≠≢inds
                      rc←9
                      msg←(0 2⍸≢inds)⊃('Certificate with id "',ServerCertSKI,'" was not found in the Microsoft Certificate Store')('There is more than one certificate with Subject Key Identifier "',ServerCertSKI,'" in the Microsoft Certificate Store')
                      →∆EXIT
                  :EndIf
                  cert←certs[⊃inds]
              :EndIf
          :Else ⍝ ServerCertSKI is defined, but we're not running Windows
              →∆EXIT⊣(rc msg)←10 'ServerCertSKI is currently valid only under Windows'
          :EndIf
          secureParams←('X509'cert)('SSLValidation'SSLValidation)('Priority'Priority)
      :EndIf
     ∆EXIT:
    ∇

    ∇ (rc msg)←CheckCodeLocation;root;m;res;tmp;fn;path
      (rc msg)←0 ''
      :If DYALOG_JARVIS_CODELOCATION≢'' ⍝ environment variable take precedence
          CodeLocation←DYALOG_JARVIS_CODELOCATION
      :EndIf
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
                      _codeSource←path
                      →0 If(rc msg)←CodeLocation LoadFromFolder path
                  :ElseIf 2=t ⍝ file?
                      CodeLocation←#.⎕FIX'file://',path
                      _codeSource←path
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
     
      :For fn :In AppInitFn AppCloseFn ValidateRequestFn AuthenticateFn PostProcessFn SessionInitFn _htmlRootFn~⊂''
          :If 3≠CodeLocation.⎕NC fn
              msg,←(0∊⍴msg)↓',"CodeLocation.',fn,'" was not found '
          :EndIf
      :EndFor
      →0 If rc←8×~0∊⍴msg
     
      :If ~0∊⍴AppInitFn  ⍝ initialization function specified?
          :Select ⊃CodeLocation.⎕AT AppInitFn
          :Case 1 0 0 ⍝ result-returning niladic?
              stopIf DebugLevel 2
              res←CodeLocation⍎AppInitFn        ⍝ run it
          :Case 1 1 0 ⍝ result-returning monadic?
              stopIf DebugLevel 2
              res←(CodeLocation⍎AppInitFn)⎕THIS ⍝ run it
          :Else
              →0⊣(rc msg)←8('"',(⍕CodeLocation),'.',AppInitFn,'" is not a niladic or monadic result-returning function')
          :EndSelect
          :If 0≠⊃res
              →0⊣(rc msg)←2↑res,(≢res)↓¯1('"',(⍕CodeLocation),'.',AppInitFn,'" did not return a 0 return code')
          :EndIf
      :EndIf
     
     
      :If ~0∊⍴AppCloseFn ⍝ application close function specified?
          :If 1 0 0≢⊃CodeLocation.⎕AT AppCloseFn ⍝ result-returning niladic?
              →0⊣(rc msg)←8('"',(⍕CodeLocation),'.',AppCloseFn,'" is not a niladic result-returning function')
          :EndIf
      :EndIf
     
      Validate←{0} ⍝ dummy validation function
      :If ~0∊⍴ValidateRequestFn  ⍝ Request validation function specified?
          :If ∧/(⊃CodeLocation.⎕AT ValidateRequestFn)∊¨1(1 ¯2)0 ⍝ result-returning monadic or ambivalent?
              Validate←CodeLocation⍎ValidateRequestFn
          :Else
              →0⊣(rc msg)←8('"',(⍕CodeLocation),'.',ValidateRequestFn,'" is not a monadic result-returning function')
          :EndIf
      :EndIf
     
      Authenticate←{0} ⍝ dummy authentication function
      :If ~0∊⍴AuthenticateFn  ⍝ authentication function specified?
          :If ∧/(⊃CodeLocation.⎕AT AuthenticateFn)∊¨1(1 ¯2)0 ⍝ result-returning monadic or ambivalent?
              Authenticate←CodeLocation⍎AuthenticateFn
          :Else
              →0⊣(rc msg)←8('"',(⍕CodeLocation),'.',AuthenticateFn,'" is not a monadic result-returning function')
          :EndIf
      :EndIf
     
      PostProcess←{} ⍝ dummy postprocessing function
      :If ~0∊⍴PostProcessFn ⍝ postprocessing function specified?
          :If ∧/(⊃CodeLocation.⎕AT PostProcessFn)∊¨(0 1)(1 ¯2)0 ⍝ non-result-returning monadic or ambivalent?
              PostProcess←CodeLocation⍎PostProcessFn
          :Else
              →0⊣(rc msg)←8('"',(⍕CodeLocation),'.',PostProcessFn,'" is not a monadic non-result-returning function')
          :EndIf
      :EndIf
    ∇

    ∇ (rc msg)←Setup
    ⍝ perform final setup before starting server
      (rc msg)←0 ''
      Paradigm←uc Paradigm
      :Select Paradigm
      :Case 'JSON'
          RequestHandler←HandleJSONRequest
      :Case 'REST'
          RequestHandler←HandleRESTRequest
          :If 2>≢⍴RESTMethods
              RESTMethods←↑2⍴¨'/'(≠⊆⊢)¨','(≠⊆⊢),RESTMethods
          :EndIf
      :Else
          (rc msg)←¯1 'Invalid paradigm'
      :EndSelect
    ∇

    Exists←{0:: ¯1 (⍺,' "',⍵,'" is not a valid folder name.') ⋄ ⎕NEXISTS ⍵:0 '' ⋄ ¯1 (⍺,' "',⍵,'" was not found.')}

    ∇ (rc msg)←StartServer;r;cert;secureParams;accept;deny;mask;certs;options
      msg←'Unable to start server'
      accept←'Accept'ipRanges AcceptFrom
      deny←'Deny'ipRanges DenyFrom
      →∆EXIT If⊃(rc msg secureParams)←CreateSecureParams
     
      {}LDRC.SetProp'.' 'EventMode' 1 ⍝ report Close/Timeout as events
     
      options←''
     
      :If 3.3≤CongaVersion ⍝ can we set DecodeBuffers at server creation?
          options←⊂'Options'(5+32×FIFO) ⍝ WSAutoAccept (1) + DecodeBuffers (4) + EnableFifo (32)
      :EndIf
     
      :If 3.4≤CongaVersion ⍝ DOSLimit support started with v3.4
      :AndIf DOSLimit≠¯1  ⍝ not using Conga's default value
          :If 0≠⊃LDRC.SetProp'.' 'DOSLimit'DOSLimit
              →∆EXIT⊣(rc msg)←¯1 'Invalid DOSLimit setting: ',∊⍕DOSLimit
          :EndIf
      :EndIf
     
      _connections←⎕NS''
      _connections.index←2 0⍴'' 0  ⍝ row-oriented for faster lookup
      _connections.lastCheck←0
     
      :If 0=rc←1⊃r←LDRC.Srv ServerName''Port'http'BufferSize,secureParams,accept,deny,options
          ServerName←2⊃r
          :If 3.3>CongaVersion
              {}LDRC.SetProp ServerName'FIFOMode'FIFO ⍝ deprecated in Conga v3.2
              {}LDRC.SetProp ServerName'DecodeBuffers' 15 ⍝ 15 ⍝ decode all buffers
              {}LDRC.SetProp ServerName'WSFeatures' 1 ⍝ auto accept WS requests
          :EndIf
          :If 0∊⍴Hostname ⍝ if Host hasn't been set, set it to the default
              Hostname←'http',(~Secure)↓'s://',(2 ⎕NQ'.' 'TCPGetHostID'),((~Port∊80 443)/':',⍕Port),'/'
          :EndIf
          InitSessions
          (rc msg)←RunServer
      :Else
          Log msg←'Error ',(⍕rc),' creating server',(rc∊98 10048)/': port ',(⍕Port),' is already in use' ⍝ 98=Linux, 10048=Windows
      :EndIf
     ∆EXIT:
    ∇

    ∇ (rc msg)←RunServer;thread
      thread←lc,⍕DYALOG_JARVIS_THREAD
      :If (⊂thread)∊'' 'auto'
          :If InTerm ⍝ do we have an interactive terminal?
              thread←'debug'
          :Else
              thread←,'1'
          :EndIf
      :EndIf
      :Select thread
      :Case ,'0' ⍝ Run in thread 0
          _serverThread←0
          (rc msg)←Server''
          QuadOFF
      :Case ,'1' ⍝ Run in non-0 thread, use ⎕TSYNC
          (rc msg)←⎕TSYNC _serverThread←Server&⍬
          QuadOFF
      :Case 'debug'
          _serverThread←Server&⍬
          (rc msg)←0 'Server started'
      :Else
          (rc msg)←¯1 'Invalid setting for DYALOG_JARVIS_THREAD'
      :EndSelect
    ∇

    ∇ {r}←Server arg;wres;rc;obj;evt;data;ref;ip;msg;tmp;conx;conn
      (_started _stopped)←1 0
      :While ~_stop
          :Trap 0 DebugLevel 1
              wres←LDRC.Wait ServerName WaitTimeout ⍝ Wait for WaitTimeout before timing out
          ⍝ wres: (return code) (object name) (command) (data)
              (rc obj evt data)←4↑wres
              :If DebugLevel 8
              :AndIf evt≢'Timeout'
                  Log'Server: ',∊⍕rc obj evt
              :EndIf
              conx←obj(⍳↓⊣)'.'
              conn←TokenForConnection⍣(~0∊⍴conx)⊢conx ⍝ connection (token) number - need to add 1 because connections start at 0
              :Select rc
              :Case 0
                  :Select evt
                  :Case 'Error'
                      _stop←ServerName≡obj ⍝ if we got an error on the server itself, signal to stop
                      :If 0≠4⊃wres
                          Log'Server: DRC.Wait reported error ',(⍕4⊃wres),' on ',(2⊃wres),GetIP obj
                      :EndIf
                      RemoveConnection conx ⍝ Conga closes object on an Error event
     
                  :Case 'Connect'
                      obj AddConnection conx
     
                  :CaseList 'HTTPHeader' 'HTTPTrailer' 'HTTPChunk' 'HTTPBody'
                      :If (DebugLevel 8)∧evt≡'HTTPHeader'
                          Log'Server: HTTPHeader Method/URL: ',∊⍕2↑4⊃wres
                      :EndIf
                      :If 0≠_connections.⎕NC conx
                          ref←_connections⍎conx
                          wres ⎕TPUT conn
                          _taskThreads←⎕TNUMS∩_taskThreads,ref{⍺ HandleRequest ⍵}&(obj conn)
                          ref.Time←⎕AI[3]
                      :Else
                          Log'Server: Object ''_connections.',conx,''' was not found.'
                          {0:: ⋄ {}LDRC.Close ⍵}obj
                      :EndIf
     
                  :Case 'Closed'
                      RemoveConnection conx
     
                  :Case 'Timeout'
     
                  :Else ⍝ unhandled event
                      Log'Server: Unhandled Conga event:'
                      Log fmtCongaEvent wres
                  :EndSelect ⍝ evt
     
              :Case 1010 ⍝ Object Not found
                  :If ~_stop
                      Log'Server: Object ''',ServerName,''' has been closed - Jarvis shutting down'
                      _stop←1
                  :EndIf
              :Else
                  Log'Server: Conga wait failed:'
                  Log fmtCongaEvent wres
              :EndSelect ⍝ rc
     
              CleanupConnections
     
          :Else ⍝ :Trap
              Log'*** Server error ',msg←1 ⎕JSON⍠'Compact' 0⊢⎕DMX
              r←¯1 msg
              →Exit
          :EndTrap
      :EndWhile
     
      r←0 'Server stopped'
     
     Exit:
     
      :If ~0∊⍴AppCloseFn
          r←CodeLocation⍎AppCloseFn
      :EndIf
     
      Close
      ⎕TKILL _sessionThread
      (_stop _started _stopped)←0 0 1
    ∇

    ∇ r←TokenForConnection conx
    ⍝ return token for connection name (CONnnnnnnnn)
      r←1+⊃⊃(//)⎕VFI conx∩⎕D
      :If 0≠TokenBase ⍝ if ⎕TALLOC is available...
          r←⍎,('<',(⍕TokenBase),'.>,ZI8')⎕FMT r
      :EndIf
    ∇

    ∇ obj AddConnection conx;IP;res
      :Hold '_connections'
          conx _connections.⎕NS''
          _connections.index,←conx(⎕AI[3])
          IP←''
          :Trap 0 DebugLevel 1
              :If 0=⊃res←LDRC.GetProp obj'PeerAddr'
                  IP←2⊃2⊃res
              :EndIf
          :EndTrap
          (_connections⍎conx).IP←IP
      :EndHold
    ∇

    ∇ RemoveConnection conx;ref
      :Hold '_connections'
          :If 0=_connections.⎕NC conx
              Log'Attempt to remove non-existent connection ',⍕conx
          :Else
              ref←_connections⍎conx
              :If 9=|⌊ref.⎕NC⊂'Req'
              :AndIf ref.Req.KillOnDisconnect
                  ⎕TKILL ref.Req.Thread
              :EndIf
          :EndIf
          _connections.⎕EX conx
          _connections.index/⍨←_connections.index[1;]≢¨⊂conx
      :EndHold
      CleanupTokens conx
    ∇

    ∇ CleanupConnections;conxNames;timedOut;dead;kids;connecting;connected;killed
      :If _connections.lastCheck<⎕AI[3]-ConnectionTimeout×1000
          killed←⍬
          :Hold '_connections'
              connecting←connected←⍬
              :If ~0∊⍴kids←2 2⊃LDRC.Tree ServerName ⍝ retrieve children of server
              ⍝ LDRC.Tree
              ⍝ connecting → status 3 1 - incoming connection
              ⍝ connected  → status 3 4 - connected connection
                  (connecting connected)←2↑{((2 2⍴3 1 3 4)⍪⍵[;2 3]){⊂1↓⍵}⌸'' '',⍵[;1]}↑⊃¨kids
              :EndIf
              conxNames←_connections.index[1;]~connecting
              timedOut←_connections.index[1;]/⍨ConnectionTimeout<0.001×⎕AI[3]-_connections.index[2;]
              :If ∨/{~0∊⍴⍵}¨connected conxNames
                  :If ~0∊⍴timedOut
                      timedOut/⍨←{6::1 ⋄ 0=(_connections⍎⍵).⎕NC⊂'Req'}¨timedOut
                  :EndIf
                  :If ~0∊⍴dead←(connected~conxNames),timedOut ⍝ (connections not in the index), timed out
                      {0∊⍴⍵: ⋄ {}LDRC.Close ServerName,'.',⍵}¨dead ⍝ attempt to close them
                  :EndIf
               ⍝ remove timed out, or connections that are
                  _connections.⎕EX killed←(conxNames~connected~dead),timedOut
                  _connections.index/⍨←_connections.index[1;]∊_connections.⎕NL ¯9
              :EndIf
              _connections.lastCheck←⎕AI[3]
          :EndHold
          CleanupTokens killed
      :EndIf
    ∇

    ∇ CleanupTokens conx
    ⍝ remove any lingering tokens from dead/removed connections
      :If ~0∊⍴conx
          conx←,⊆conx
          {}⎕TGET ⎕TPOOL∩TokenForConnection¨{⊃¯1↑⍵(≠⊆⊣)'.'}¨conx
      :EndIf
    ∇

    :Section RequestHandling

    ∇ r←ErrorInfo
      :Trap 0
          r←⍕ErrorInfoLevel↑⎕DMX.(EM({⍵↑⍨⍵⍳']'}2⊃DM))
      :Else
          r←''
      :EndTrap
    ∇

    ∇ req←MakeRequest args
    ⍝ create a request, use MakeRequest '' for interactive debugging
    ⍝ :Access public ⍝ uncomment for debugging
      :If 0∊⍴args
          req←⎕NEW Request
      :Else
          req←⎕NEW Request args
      :EndIf
      req.(Server ErrorInfoLevel)←⎕THIS ErrorInfoLevel
    ∇

    ∇ ns HandleRequest(obj conn);data;evt;obj;rc;cert;fn
      :Hold obj
          (rc obj evt data)←⊃⎕TGET conn ⍝ from Conga.Wait
          :Select evt
          :Case 'HTTPHeader'
              ns.Req←MakeRequest data
              ns.Req.Thread←⎕TID
              ns.Req.PeerCert←''
              ns.Req.PeerAddr←2⊃2⊃LDRC.GetProp obj'PeerAddr'
              ns.Req.Server←⎕THIS
     
              :If Secure
                  (rc cert)←2↑LDRC.GetProp obj'PeerCert'
                  :If rc=0
                      ns.Req.PeerCert←cert
                  :Else
                      ns.Req.PeerCert←'Could not obtain certificate'
                  :EndIf
              :EndIf
     
          :Case 'HTTPBody'
              ⍝↓↓↓ if Req doesn't exist, it's because it was marked complete previously and removed, and we just ignore this event
              ⍝    this can happen in the case where:
              ⍝       - the request is a POST request
              ⍝       - and no content-length header was provided
              ⍝       - and transfer-encoding is not "chunked"
              ⍝ Conga 3.5 addresses this by issuing and HTTPError event, but earlier Conga's
              →0⍴⍨0=ns.⎕NC'Req'
              ns.Req.Thread←⎕TID
              ns.Req.ProcessBody data
          :Case 'HTTPChunk'
              ns.Req.Thread←⎕TID
              ns.Req.ProcessChunk data
          :Case 'HTTPTrailer'
              ns.Req.Thread←⎕TID
              ns.Req.ProcessTrailer data
          :EndSelect
     
          ns.Req.Thread←⎕TID
     
          :If ns.Req.Complete
              :Select lc ns.Req.GetHeader'content-encoding' ⍝ zipped request?
              :Case '' ⍝ no encoding
                  :If ns.Req.Charset≡'utf-8'
                      ns.Req.Body←'UTF-8'⎕UCS ⎕UCS ns.Req.Body
                  :EndIf
              :Case 'gzip'
                  →resp If'gzip'Unzip ns.Req
              :Case 'deflate'
                  →resp If'deflate'Unzip ns.Req
              :Else
                  →resp⊣'Unsupported content-encoding'ns.Req.Fail 400
              :EndSelect
     
            ⍝ Application-specified validation
              stopIf DebugLevel 4+2×~0∊⍴ValidateRequestFn
              :If 0≠Validate ns.Req
                  ns.Req.Fail 400×ns.Req.Response.Status=0 ⍝ default status 400 if not set by application
                  →resp
              :EndIf
     
              ns.Req.Response.(Status←(Status 200)[1+Status=0]) ⍝ if status was not already set, set to default
     
              fn←1↓'.'@('/'∘=)ns.Req.Endpoint
     
              fn RequestHandler ns ⍝ RequestHandler is either HandleJSONRequest or HandleRESTRequest
     
     resp:
              ⍝ if HTML interface is enabled, and there's a problem with the request, and we haven't already set a payload
              :If _htmlEnabled∧(2=⌊0.01×ns.Req.Response.Status)<0∊⍴ns.Req.Response.Payload
                  'content-type'ns.Req.SetHeader'text/html; charset=utf-8'
                  ns.Req.Response.Payload←'<h3>',(⍕ns.Req.Response.((⍕Status),' ',StatusText)),'</h3>'
              :EndIf
     
              obj Respond ns
     
          :EndIf
      :EndHold
    ∇

    ∇ rc←type Unzip req;n
    ⍝ attempt to unzip the request payload
    ⍝ req is the Request instance
    ⍝ type is 'deflate' or 'gzip'
      n←¯2 ¯3['deflate' 'gzip'⍳⊂type]
      :Trap rc←0
          req.Body←⎕UCS 256|n Zipper 83 ⎕DR req.Body
      :Else
          ('Invalid payload for "',type,'" content-encoding')req.Fail 400
          rc←1
      :EndTrap
    ∇

    ∇ fn HandleJSONRequest ns;payload;resp;valence;nc;debug;file;isGET
     
      →handle If~isGET←'get'≡ns.Req.Method
     
      :If AllowGETs ⍝ if we allow GETs
      :AndIf ~'.'∊ns.Req.Endpoint ⍝ and the endpoint doesn't have a '.' (file extension)
          →handle If 3=⌊|{0::0 ⋄ CodeLocation.⎕NC⊂⍵}fn ⍝ handle it if there's a matching function for the endpoint
      :EndIf
     
      →End If'Request method should be POST'ns.Req.Fail 405×~_htmlEnabled
     
      →handleHtml If~0∊⍴_htmlFolder
      ns.Req.Response.Headers←1 2⍴'Content-Type' 'text/html; charset=utf-8'
      ns.Req.Response.Payload←'<!DOCTYPE html><html><head><meta content="text/html; charset=utf-8" http-equiv="Content-Type"><link rel="icon" href="data:,"></head><body><h2>400 Bad Request</h2></body></html>'
      →End If'Bad URI'ns.Req.Fail 400×~0∊⍴fn ⍝ either fail with a bad URI or exit if favicon.ico (no-op)
     
      :If 0∊⍴_htmlRootFn
          ns.Req.Response.Payload←HtmlPage
      :Else
          ns.Req.Response.Payload←{1 CodeLocation.(85⌶)_htmlRootFn,' ⍵'}ns.Req
      :EndIf
      →End
     
     handleHtml:
      :If (,'/')≡ns.Req.Endpoint
          file←_htmlFolder,_htmlDefaultPage
      :Else
          file←_htmlFolder,('/'=⊣/ns.Req.Endpoint)↓ns.Req.Endpoint
      :EndIf
      file←resolveFilename file
      file,←(isDir file)/'/',_htmlDefaultPage
      →End If ns.Req.Fail 400×~_htmlFolder begins file
      :If 0≠ns.Req.Fail 404×~⎕NEXISTS file
          →End If 0=Report404InHTML
          ns.Req.Response.Headers←1 2⍴'Content-Type' 'text/html; charset=utf-8'
          ns.Req.Response.Payload←'<h3>Not found: ',(file↓⍨≢_htmlFolder),'</h3>'
          →End
      :EndIf
      ns.Req.Response.Payload←''file
      'Content-Type'ns.Req.DefaultHeader ns.Req.ContentTypeForFile file
      →End
     
     handle:
      →End If HandleCORSRequest ns.Req
      →End If'No function specified'ns.Req.Fail 400×0∊⍴fn
      →End If'Unsupported request method'ns.Req.Fail 405×(⊂ns.Req.Method)(~∊)(~AllowGETs)↓'get' 'post'
      →End If'Cannot accept query parameters'ns.Req.Fail 400×AllowGETs⍱0∊⍴ns.Req.QueryParams
     
      :Select ns.Req.ContentType
     
      :Case 'application/json'
          :Trap 0 DebugLevel 1
              ns.Req.Payload←{0∊⍴⍵:⍵ ⋄ JSONin ⍵}ns.Req.Body
          :Else
              →End⊣'Could not parse payload as JSON'ns.Req.Fail 400
          :EndTrap
     
      :Case 'multipart/form-data'
          →End If'Content-Type should be "application/json"'ns.Req.Fail 400×~AllowFormData
          →End If 0≠ParseMultipart ns.Req
     
      :Case 'application/x-www-form-urlencoded'
          →End If'Content-Type should be "application/json"'ns.Req.Fail 400×~AllowFormData
          →End If 0≠ParseFormData ns.Req
     
      :Case ''
          →End If'No Content-Type specified'ns.Req.Fail 400×~isGET∧AllowGETs
          :Trap 0 DebugLevel 1
              :If 0∊⍴ns.Req.QueryParams
                  ns.Req.Payload←''
              :ElseIf 1=≢⍴ns.Req.QueryParams ⍝ if a vector, try to parse as JSON
                  ns.Req.Payload←JSONin ns.Req.QueryParams
              :Else ⍝ if a matrix it's [;1] name [;2] value
                  ns.Req.Payload←JSONin 1⌽'}{',1↓∊',',¯1⌽':',⌽JSONout¨ns.Req.QueryParams
              :EndIf
          :Else
              →End⊣'Could not parse query string as JSON'ns.Req.Fail 400
          :EndTrap
     
      :Else
          →End⊣('Content-Type should be "application/json"',AllowFormData/' or "multipart/form-data"')ns.Req.Fail 400
      :EndSelect
     
      →End If CheckAuthentication ns.Req
     
      →End If('Invalid function "',fn,'"')ns.Req.Fail CheckFunctionName fn
      →End If('Invalid function "',fn,'"')ns.Req.Fail 404×3≠⌊|{0::0 ⋄ CodeLocation.⎕NC⊂⍵}fn  ⍝ is it a function?
      valence←|⊃CodeLocation.⎕AT fn
      nc←CodeLocation.⎕NC⊂fn
      →End If('"',fn,'" is not a monadic result-returning function')ns.Req.Fail 400×(1 1 0≢×valence)>(0∧.=valence)∧3.3=nc
     
      resp←''
      :Trap 0 DebugLevel 1
          :Trap 85
              :If (2=valence[2])>3.3=nc ⍝ dyadic and not tacit
                  stopIf DebugLevel 2
                  resp←ns.Req{0 CodeLocation.(85⌶)'⍺ ',fn,' ⍵'}ns.Req.Payload ⍝ intentional stop for application-level debugging
              :Else
                  stopIf DebugLevel 2
                  resp←{0 CodeLocation.(85⌶)fn,' ⍵'}ns.Req.Payload ⍝ intentional stop for application-level debugging
              :EndIf
          :Else ⍝ no result from the endpoint
              :If 0∊⍴ns.Req.Response.Payload ⍝ no payload?
              :AndIf 200=ns.Req.Response.Status  ⍝ endpoint did not change the status
                  →End⊣ns.Req.Fail 204 ⍝ no content
              :EndIf
          :EndTrap
      :Else
          →End⊣ErrorInfo ns.Req.Fail 500
      :EndTrap
     
      →End If 204=ns.Req.Response.Status ⍝ exit on no content
     
     ⍝ Exit if
     ⍝        ↓↓↓↓↓↓↓ no response from endpoint,
     ⍝ and              ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓ endpoint did not set payload
     ⍝ and                                          ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓ endpoint failed the request
      →End If(0∊⍴resp)∧(0∊⍴ns.Req.Response.Payload)∧2≠⌊0.01×ns.Req.Response.Status
     
     ⍝ If the endpoint explicitly sets the payload, use it in preference to any endpoint result
      :If 0∊⍴ns.Req.Response.Payload
          ns.Req.Response.Payload←resp
      :EndIf
     
      stopIf DebugLevel 2×~0∊⍴PostProcessFn
      :Trap 85 ⍝ ignore any result from PostProcess
          {}{1(85⌶)'PostProcess ⍵'}ns.Req ⍝ call postprocessing
      :EndTrap
     
      'Content-Type'ns.Req.DefaultHeader DefaultContentType ⍝ set the header if not set
      :If ∨/'application/json'⍷ns.Req.(Response.Headers GetHeader'content-type') ⍝ if the response is JSON
          ToJSON ns.Req ⍝ convert payload
      :EndIf
     
      :If 0∊⍴ns.Req.Response.Payload
          'Content-Length'ns.Req.DefaultHeader 0
      :EndIf
     End:
    ∇

    ∇ rc←ParseMultipart req
    ⍝ cover for ParseMultipartForm so we can call it from JSON or REST handling
      :Trap 0 DebugLevel 1
          req.Payload←ParseMultipartForm req
          rc←200≠req.Response.Status ⍝ bail if parsing fails
      :Else
          rc←1⊣'Could not parse payload as "multipart/form-data"'req.Fail 400
      :EndTrap
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
          name↓⍨←¯2×'[]'≡¯2↑name ⍝ drop any trailing [] (we handle arrays automatically)
          :If ('.'∊name)∨¯1=⎕NC name
              →0⊣('Invalid form field name "',name,'" for Jarvis')req.Fail 400
          :EndIf
          tmp←⎕NS''
          filename←'"'~⍨2⊃2↑filename splitOn'='
          tmp.(Name Filename)←name filename
          tmp.Content←payload
          tmp.Content_Type←deb 2⊃2↑type splitOn':'
          :If 0=formData.⎕NC name ⋄ formData{⍺⍎⍵,'←⍬'}name ⋄ :EndIf
          formData(name{⍺⍎⍺⍺,',←⍵'})tmp
      :EndFor
    ∇

    ∇ rc←ParseFormData req
    ⍝ cover for ParseUrlencodedForm so we can call it from JSON or REST handling
      :Trap 0 DebugLevel 1
          req.Payload←ParseUrlencodedForm req
          rc←200≠req.Response.Status ⍝ bail if parsing fails
      :Else
          rc←1⊣'Could not parse payload as "application/x-www-form-urlencoded"'req.Fail 400
      :EndTrap
    ∇

    ∇ formData←ParseUrlencodedForm req;data;name;value
    ⍝ parse application/x-www-form-urlencoded content
      formData←⎕NS''
      data←req.URLDecode¨¨(req.Body splitOn'&')splitOn¨'='
      :For (name value) :In data
          :If ('.'∊name)∨¯1=⎕NC name
              →0⊣('Invalid form field name "',name,'" for Jarvis')req.Fail 400
          :EndIf
          :If 0=formData.⎕NC name ⋄ formData{⍺⍎⍵,'←⍬'}name ⋄ :EndIf
          formData(name{⍺⍎⍺⍺,',←⍵'})value
      :EndFor
    ∇


    ∇ fn HandleRESTRequest ns;ind;exec;valence;ct;resp
      →0 If HandleCORSRequest ns.Req
      →0 If CheckAuthentication ns.Req
     
      :If ParsePayload
          :Trap 0 DebugLevel 1
              :Select ct←ns.Req.ContentType
              :Case 'application/json'
                  ns.Req.Payload←JSONin ns.Req.Body
              :Case 'application/xml'
                  ns.Req.(Payload←⎕XML Body)
              :Case 'multipart/form-data'
                  →0 If 0≠ParseMultipart ns.Req
              :Case 'application/x-www-form-urlencoded'
                  →0 If 0≠ParseFormData ns.Req
              :EndSelect
          :Else
              →0⊣('Unable to parse request body as ',ct)ns.Req.Fail 400
          :EndTrap
      :EndIf
     
      ind←RESTMethods[;1](⍳nocase)⊂ns.Req.Method
      →0 If ns.Req.Fail 405×(≢RESTMethods)<ind
      exec←⊃RESTMethods[ind;2]
      →0 If ns.Req.Fail 501×0∊⍴exec
     
      resp←''
      :Trap 0 DebugLevel 1
          :Trap 85
              stopIf DebugLevel 2
              resp←{1 CodeLocation.(85⌶)exec,' ⍵'}ns.Req  ⍝ intentional stop for application-level debugging
          :EndTrap
      :Else
          →0⊣ns.Req.Fail 500
      :EndTrap
     
      :If 0∊⍴ns.Req.Response.Payload ⍝ if the endpoint set Response.Payload, use it
          ns.Req.Response.Payload←resp ⍝ otherwise, use whatever was returned by the endpoint
      :EndIf
     
      stopIf DebugLevel 2×~0∊⍴PostProcessFn
      :Trap 85 ⍝ ignore any result from PostProcess
          {}{1(85⌶)'PostProcess ⍵'}ns.Req ⍝ call postprocessing
      :EndTrap
     
      →0 If(0=RESTFailProcessing)∧2≠⌊0.01×ns.Req.Response.Status
      :If (ns.Req.(Response.Headers GetHeader'content-type')≡'')∧~0∊⍴DefaultContentType
          'content-type'ns.Req.SetHeader DefaultContentType
      :EndIf
     
      :If 'application/json'match⊃';'(≠⊆⊢)ns.Req.(Response.Headers GetHeader'content-type')
          ToJSON ns.Req
      :EndIf
    ∇

    ∇ r←HandleCORSRequest req;origin;reflect
      r←0
      →0 If~EnableCORS
      →0 If 0∊⍴origin←req.GetHeader'Origin'  ⍝ CORS requests have an Origin header
      reflect←{(1+(,⍺)≡,1)⊃⍺ ⍵} ⍝ if CORS_xxx setting is 1, reflect the request's value
      'Access-Control-Allow-Origin'req.DefaultHeader CORS_Origin reflect origin
      →0 If~req.Method≡'options' ⍝ OPTIONS (with an Origin header) indicates a "pre-flighted" CORS request
      →0 If 0∊⍴req.GetHeader'Access-Control-Request-Method' ⍝
      'Access-Control-Allow-Methods'req.DefaultHeader CORS_Methods reflect req.GetHeader'Access-Control-Request-Method'
      'Access-Control-Allow-Headers'req.DefaultHeader CORS_Headers reflect req.GetHeader'Access-Control-Request-Headers'
      'Access-Control-Max-Age'req.DefaultHeader(⍕CORS_MaxAge)
      req.SetStatus 204 ⍝ No Content
      r←1
    ∇

    ∇ ToJSON req
    ⍝ convert APL response payload to JSON
      :Trap 0 DebugLevel 1
          req.Response.Payload←⎕UCS SafeJSON JSONout req.Response.Payload
      :Else
          'Could not format result payload as JSON'req.Fail 500
      :EndTrap
    ∇

    ∇ w←SafeJSON w;i;c;⎕IO
    ⍝ Convert Unicode chars to \uXXXX
      ⎕IO←0
      →0⍴⍨0∊⍴i←⍸127<c←⎕UCS w
      w[i]←{⊂'\u','0123456789ABCDEF'[16 16 16 16⊤⍵]}¨c[i]
      w←∊w
    ∇

    ∇ r←CheckAuthentication req
    ⍝ Check request authentication
    ⍝ r is 0 if request processing can continue
      r←1
      :If 0=DoAuthentication req ⍝ might still want to do some authentication
          :If 0≠SessionTimeout ⍝ using sessions?
              :If 0≠CheckSession req ⍝ session is still valid?
                  CreateSession req
              :EndIf
          :EndIf
          r←0
      :EndIf
    ∇

    ∇ rc←DoAuthentication req;debug;old
    ⍝ rc is 0 if either no authentication is required or authentication succeeds
    ⍝
      rc←0
      :Trap 0 DebugLevel 1
          stopIf DebugLevel 2×~0∊⍴AuthenticateFn
          rc←Authenticate req ⍝ intentional stop for application-level debugging
          :If rc≠0
              req.Fail 401
              :If HTTPAuthentication match'basic'
                  'WWW-Authenticate'req.SetHeader'Basic realm="Jarvis", charset="UTF-8"'
              :EndIf
          :EndIf
      :Else ⍝ Authenticate errored
          (⎕DMX.EM,' occured during authentication')req.Fail 500
          rc←1
      :EndTrap
    ∇

    ∇ obj Respond ns;status;z;res;close;conx
      res←ns.Req.Response
      res.Headers⍪←'Server'(deb⍕2↑Version)
      res.Headers⍪←'Date'(2⊃LDRC.GetProp'.' 'HttpDate')
      conx←lc ns.Req.GetHeader'connection'
      status←(⊂ns.Req.HTTPVersion),res.((⍕Status)StatusText)
     
      close←(('HTTP/1.0'≡ns.Req.HTTPVersion)>'keep-alive'≡conx)∨'close'≡conx
      close∨←2≠⌊0.01×res.Status ⍝ close the connection on non-2XX status
     
      UseZip ContentEncode ns.Req
      stopIf DebugLevel 16
     
      :Select 1⊃z←LDRC.Send obj(status,res.Headers res.Payload)close
      :Case 0 ⍝ everything okay, nothing to do
      :Case 1008 ⍝ Wrong object class likely caused by socket being closed during the request
        ⍝ do nothing for now
      :Else
          Log'Respond: Conga error when sending response',GetIP obj
          Log⍕z
      :EndSelect
      ns.⎕EX'Req'
    ∇

    ∇ UseZip ContentEncode req;enc
      →End If 0=UseZip ⍝ is zipping enabled?
      →End If 0∊⍴enc←req.AcceptEncodings ⍝ does the client accept zipped responses?
      :If UseZip≤≢req.Response.Payload ⍝ payload exceeds size threshhold?
          :Select ⊃enc
          :Case 'gzip'
              :Trap 0
                  req.Response.Payload←2⊃3 ZipLevel Zipper sint req.Response.Payload
              :Else
                  Log'ContentEncode: gzip content-encoding failed'
                  →End
              :EndTrap
              'Content-Encoding'req.SetHeader'gzip'
          :Case 'deflate'
              :Trap 0
                  req.Response.Payload←2⊃2 ZipLevel Zipper sint req.Response.Payload
              :Else
                  Log'ContentEncode: deflate content-encoding failed'
                  →End
              :EndTrap
              'Content-Encoding'req.SetHeader'deflate'
          :Else
              Log'ContentEncode: unsupported content-encoding - ',⊃enc ⍝ this should NEVER happen
          :EndSelect
      :EndIf
     End:
    ∇

    :EndSection ⍝ Request Handling

    ∇ ip←GetIP objname
      ip←{6::'' ⋄ ' (IP Address ',(⍕(_connections⍎⍵).IP),')'}objname
    ∇

    ∇ r←CheckFunctionName fn
    ⍝ checks the requested function name and returns
    ⍝    0 if the function is allowed
    ⍝  404 (not found) either the function name does not exist, is not in IncludeFns (if defined), is in ExcludeFns (if defined)
      :Access public
      r←0
      :If 1<|≡fn
          r←CheckFunctionName¨fn
      :Else
          fn←⊆,fn
          →0 If r←404×fn∊AppInitFn AppCloseFn ValidateRequestFn AuthenticateFn PostProcessFn SessionInitFn _htmlRootFn
          :If ~0∊⍴_includeRegex
              →0 If r←404×0∊⍴(_includeRegex ⎕S'%')fn
          :EndIf
          :If ~0∊⍴_excludeRegex
              r←404×~0∊⍴(_excludeRegex ⎕S'%')fn
          :EndIf
      :EndIf
    ∇

    :class Request
        :Field Public Instance AcceptEncodings←''⍝ content-encodings that the client will accept
        :Field Public Instance Boundary←''       ⍝ boundary for content-type 'multipart/form-data'
        :Field Public Instance Charset←''        ⍝ content charset (defaults to 'utf-8' if content-type is application/json)
        :Field Public Instance Complete←0        ⍝ do we have a complete request?
        :Field Public Instance ContentType←''    ⍝ content-type header value
        :Field Public Instance Cookies←0 2⍴⊂''   ⍝ cookie name/value pairs
        :Field Public Instance Input←''
        :Field Public Instance Headers←0 2⍴⊂''   ⍝ HTTPRequest header fields (plus any supplied from HTTPTrailer event)
        :Field Public Instance Method←''         ⍝ HTTP method (GET, POST, PUT, etc)
        :Field Public Instance Endpoint←''       ⍝ Requested URI
        :Field Public Instance KillOnDisconnect←0⍝ Kill request thread on disconnect
        :Field Public Instance Thread←¯1         ⍝ Thread number handling this request
        :Field Public Instance Body←''           ⍝ body of the request
        :Field Public Instance Payload←''        ⍝ parsed (if JSON or XML) payload
        :Field Public Instance PeerAddr←'unknown'⍝ client IP address
        :Field Public Instance PeerCert←0 0⍴⊂''  ⍝ client certificate
        :Field Public Instance HTTPVersion←''
        :Field Public Instance ErrorInfoLevel←1
        :Field Public Instance Response
        :Field Public Instance Server
        :Field Public Instance Session←⍬
        :Field Public Instance QueryParams←0 2⍴0
        :Field Public Instance UserID←''
        :Field Public Instance Password←''
        :Field Public Shared HttpStatus←↑(200 'OK')(201 'Created')(204 'No Content')(301 'Moved Permanently')(302 'Found')(303 'See Other')(304 'Not Modified')(305 'Use Proxy')(307 'Temporary Redirect')(400 'Bad Request')(401 'Unauthorized')(403 'Forbidden')(404 'Not Found')(405 'Method Not Allowed')(406 'Not Acceptable')(408 'Request Timeout')(409 'Conflict')(410 'Gone')(411 'Length Required')(412 'Precondition Failed')(413 'Request Entity Too Large')(414 'Request-URI Too Long')(415 'Unsupported Media Type')(500 'Internal Server Error')(501 'Not Implemented')(503 'Service Unavailable')

        ⍝ Content types for common file extensions
        :Field Public Shared ContentTypes←79 2⍴'aac' 'audio/aac' 'abw' 'application/x-abiword' 'apng' 'image/apng' 'arc' 'application/x-freearc' 'avif' 'image/avif' 'avi' 'video/x-msvideo' 'azw' 'application/vnd.amazon.ebook' 'bin' 'application/octet-stream' 'bmp' 'image/bmp' 'bz' 'application/x-bzip' 'bz2' 'application/x-bzip2' 'cda' 'application/x-cdf' 'csh' 'application/x-csh' 'css' 'text/css' 'csv' 'text/csv' 'doc' 'application/msword' 'docx' 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' 'eot' 'application/vnd.ms-fontobject' 'epub' 'application/epub+zip' 'gz' 'application/gzip' 'gz' 'application/x-gzip' 'gif' 'image/gif' 'htm' 'text/html' 'html' 'text/html' 'ico' 'image/vnd.microsoft.icon' 'ics' 'text/calendar' 'jar' 'application/java-archive' 'jpeg' 'image/jpeg' 'jpg' 'image/jpeg' 'js' 'text/javascript' 'json' 'application/json' 'jsonld' 'application/ld+json' 'mid ' 'audio/midi' 'midi' 'audio/midi' 'mjs' 'text/javascript' 'mp3' 'audio/mpeg' 'mp4' 'video/mp4' 'mpeg' 'video/mpeg' 'mpkg' 'application/vnd.apple.installer+xml' 'odp' 'application/vnd.oasis.opendocument.presentation' 'ods' 'application/vnd.oasis.opendocument.spreadsheet' 'odt' 'application/vnd.oasis.opendocument.text' 'oga' 'audio/ogg' 'ogv' 'video/ogg' 'ogx' 'application/ogg' 'opus' 'audio/ogg' 'otf' 'font/otf' 'png' 'image/png' 'pdf' 'application/pdf' 'php' 'application/x-httpd-php' 'ppt' 'application/vnd.ms-powerpoint' 'pptx' 'application/vnd.openxmlformats-officedocument.presentationml.presentation' 'rar' 'application/vnd.rar' 'rtf' 'application/rtf' 'sh' 'application/x-sh' 'svg' 'image/svg+xml' 'tar' 'application/x-tar' 'tif ' 'image/tiff' 'tiff' 'image/tiff' 'ts' 'video/mp2t' 'ttf' 'font/ttf' 'txt' 'text/plain' 'vsd' 'application/vnd.visio' 'wav' 'audio/wav' 'weba' 'audio/webm' 'webm' 'video/webm' 'webp' 'image/webp' 'woff' 'font/woff' 'woff2' 'font/woff2' 'xhtml' 'application/xhtml+xml' 'xls' 'application/vnd.ms-excel' 'xlsx' 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' 'xml' 'application/xml' 'xul' 'application/vnd.mozilla.xul+xml' 'zip' 'application/zip' 'zip' 'application/x-zip-compressed' '3gp' 'video/3gpp' '3g2' 'video/3gpp2' '7z' 'application/x-7z-compressed'

        GetFromTable←{(⍵[;1]⍳⊂,⍺)⊃⍵[;2],⊂''}
        split←{p←(⍺⍷⍵)⍳1 ⋄ ((p-1)↑⍵)(p↓⍵)} ⍝ Split ⍵ on first occurrence of ⍺
        lc←{2::0(819⌶)⍵ ⋄ ¯3 ⎕C ⍵}
        deb←{{1↓¯1↓⍵/⍨~'  '⍷⍵}' ',⍵,' '}

        ∇ r←Config
        ⍝ returns current request configuration - useful for debugging
          :Access public
          r←↑{6::⍵'No value' ⋄ ⍵(⍎⍵)}¨(⎕THIS⍎'⎕NL ¯2.2 ¯2.1 ¯2.3')~'ContentTypes' 'HttpStatus'
        ∇

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
          makeResponse
        ∇

        ∇ make1 args;query;origin;length;param;value;type;noLength;len
        ⍝ args is the result of Conga HTTPHeader event
          :Access public
          :Implements constructor
         
          (Method Input HTTPVersion Headers)←args
          HTTPVersion←deb HTTPVersion
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
         
          Cookies←ParseCookies Headers
         
          AcceptEncodings←ParseEncodings GetHeader'accept-encoding'
         
          makeResponse
         
          (Endpoint query)←'?'split Input
         
          :Trap 11 ⍝ trap domain error on possible bad UTF-8 sequence
              Endpoint←URLDecode Endpoint
              QueryParams←ParseQueryString query
              :If 'basic '≡lc 6↑auth←GetHeader'authorization'
                  (UserID Password)←':'split Base64Decode 6↓auth
              :EndIf
          :Else
              Complete←1 ⍝ mark as complete
              Fail 400   ⍝ 400 = bad request
              →0
          :EndTrap
         
          noLength←0∊⍴length←GetHeader'content-length'
          len←⊃⊃(//)⎕VFI length
          Complete←('get'≡Method)∧noLength∨0=len ⍝ we're a GET and there's no content-length or content-length=0
          Complete∨←noLength>∨/'chunked'⍷GetHeader'transfer-encoding' ⍝ or no length supplied and we're not chunked
          Complete∨←noLength<0=len ⍝ or if content-length=0
        ∇

        ∇ makeResponse
        ⍝ create the response namespace
          Response←⎕NS''
          Response.(Status StatusText Payload)←0 'OK' ''
          Response.Headers←0 2⍴'' ''
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

        ∇ params←ParseQueryString query
          params←0 2⍴⊂''
          →0⍴⍨0∊⍴query
          query←'UTF-8'⎕UCS ⎕UCS query
          :If '='∊query ⍝ contains name=value?
              params←URLDecode¨↑{1 ¯1↓¨'='(≠⊆⊢)1⌽'  ',⍵}¨'&'(≠⊆⊢)query
          :Else
              params←URLDecode query
          :EndIf
        ∇

        ∇ r←ParseEncodings encodings
          r←(⎕C(⊃¨';'(≠⊆⊢)¨','(≠⊆⊢)encodings~' '))∩'gzip' 'deflate'
        ∇

        ∇ cookies←ParseCookies headers;cookieHeader;cookie
          :Access public shared
          cookies←0 2⍴⊂''
          :For cookieHeader :In (headers[;1]≡¨⊂'cookie')/headers[;2]
              :For cookie :In (({⍵↓⍨+/∧\' '=⍵}⌽)⍣2)¨';'(≠⊆⊢)cookieHeader
                  cookies⍪←2↑('='(≠⊆⊢)cookie),⊂''
              :EndFor
          :EndFor
          cookies←(⌽≠⌽cookies[;1])⌿cookies
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
          table[;1]←lc table[;1]
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
          :Trap 0
              r←⍕ErrorInfoLevel↑⎕DMX.(EM({⍵↑⍨⍵⍳']'}2⊃DM))
          :Else
              r←''
          :EndTrap
        ∇

        ∇ {(name value)}←name SetHeader value
          :Access Public Instance
          Response.Headers⍪←name(∊⍕value)
        ∇

        ∇ {(name cookie)}←name SetCookie cookie
          :Access public instance
        ⍝ create a response "set-cookie" header
        ⍝ cookie is the cookie value followed by any ;-delimited attributes
          'set-cookie'SetHeader name,'=',cookie
        ∇

        ∇ {(name value)}←SetContentType contentType
          :Access public instance
        ⍝ shortcut function to set the response content-type header
          (name value)←'Content-Type'SetHeader contentType
        ∇

        ∇ value←GetCookie name
          :Access public instance
        ⍝ retrieve a request cookie
          value←(Cookies[;1]⍳⊆,name)⊃Cookies[;2],⊂''
        ∇

        ∇ {status}←{statusText}SetStatus status
          :Access public instance
          :If status≠0
              :If 0=⎕NC'statusText' ⋄ statusText←'' ⋄ :EndIf
              statusText←{0∊⍴⍵:⍵ ⋄ '('=⊣/⍵:⍵ ⋄ '(',⍵,')'}statusText
              statusText←deb((HttpStatus[;1]⍳status)⊃HttpStatus[;2],⊂''),' ',statusText
              Response.(Status StatusText)←status statusText
          :EndIf
        ∇

        ∇ r←ContentTypeForFile filename;ext
          :Access public instance
          ext←1↓3⊃⎕NPARTS'..',filename
          r←(ContentTypes[;1]⍳⊂ext)⊃ContentTypes[;2],⊂'application/octet-stream'
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

    MakeSessionId←{⎕IO←0 ⋄'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'[(?20⍴62),5↑1↓⎕TS]}
    IsExpired←{⍺≤0: 0 ⋄ (Now-⍵)>(⍺×60000)÷86400000}

    ∇ r←DateToIDNX ts
    ⍝ Date to IDN eXtended (will be replaced by ⎕DT when ⎕DT is in the latest 3 versions of Dyalog APL)
      r←(2 ⎕NQ'.' 'DateToIDN'(3↑ts))+(0 60 60 1000⊥¯4↑7↑ts)÷86400000
    ∇

    ∇ CreateSession req;ref;now;id;ts;rc
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
                  :Trap 85
                      stopIf DebugLevel 2
                      rc←SessionInitFn CodeLocation.{1(85⌶)⍺,' ⍵'}req
                  :Else ⋄ rc←0
                  :EndTrap
     
                  :If 0≠rc
                      (_sessions _sessionsInfo)←¯1↓¨_sessions _sessionsInfo
                      →0⊣('Session intialization returned ',⍕rc)req.Fail 500
                  :EndIf
              :Else
                  →0⊣(⎕DMX.EM,' occurred during session initialization failed')req.Fail 500
              :EndTrap
          :Else
              →0⊣('Session initialization function "',SessionInitFn,'" not found')req.Fail 500
          :EndIf
      :EndIf
      :If SessionUseCookie
          SessionIdHeader req.SetCookie id,(SessionTimeout>0)/'; Max-Age=',⍕⌈60×SessionTimeout
      :Else
          SessionIdHeader req.SetHeader id
      :EndIf
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
    ∇

    ∇ ref←GetSession req;id
      :Access public
      ref←''
      →0⍴⍨0∊⍴id←GetSessionId req
      ref←(_sessionsInfo[;1]⍳⊂id)⊃(_sessionsInfo[;5],⊂'')
    ∇

    ∇ id←GetSessionId req
      :If SessionUseCookie
          id←req.GetCookie SessionIdHeader
      :Else
          id←req.GetHeader SessionIdHeader
      :EndIf
    ∇

    ∇ r←CheckSession req;ind;session;timedOut;id
    ⍝ check for valid session (only called if SessionTimeout≠0)
      r←1
      :Hold 'Sessions'
          id←GetSessionId req
          ind←_sessionsInfo[;1]⍳⊂id
          →0⍴⍨ind>≢_sessionsInfo
     
          :If 0∊⍴session←⊃_sessionsInfo[ind;5] ⍝ already timed out (session was already removed from _sessions)
          :OrIf SessionTimeout IsExpired _sessionsInfo[ind;4] ⍝ newly expired
              req TimeoutSession ind
              →0
          :EndIf
    ⍝ we have a valid session, refresh the cookie or set the header
          :If SessionUseCookie
              SessionIdHeader req.SetCookie id,(SessionTimeout>0)/'; Max-Age=',⍕⌈60×SessionTimeout
          :ElseIf
              SessionIdHeader req.SetHeader id
          :EndIf
          _sessionsInfo[ind;4]←Now
          req.Session←session
          r←0
      :EndHold
    ∇

    :EndSection

    :Section Utilities

    If←((0≠⊃)⊢)⍴⊣ ⍝ test for 0 return
    isChar←{0 2∊⍨10|⎕DR ⍵}
    toChar←{(⎕DR'')⎕DR ⍵}
    stripQuotes←{'""'≡2↑¯1⌽⍵:¯1↓1↓⍵ ⋄ ⍵} ⍝ strip leading and ending "
    deb←{{1↓¯1↓⍵/⍨~'  '⍷⍵}' ',⍵,' '} ⍝ delete extraneous blanks
    dlb←{⍵↓⍨+/∧\' '=⍵} ⍝ delete leading blanks
    lc←{2::0(819⌶)⍵ ⋄ ¯3 ⎕C ⍵} ⍝ lower case
    uc←{2::1(819⌶)⍵ ⋄ 1 ⎕C ⍵} ⍝ upper case
    nameClass←{⎕NC⊂,'⍵'} ⍝ name class of argument
    nocase←{(lc ⍺)⍺⍺ lc ⍵} ⍝ case insensitive operator
    begins←{⍺≡(⍴⍺)↑⍵} ⍝ does ⍺ begin with ⍵?
    ends←{⍺≡(-≢⍺)↑⍵} ⍝ does ⍺ end with ⍵?
    match←{⍺ (≡nocase) ⍵} ⍝ case insensitive ≡
    sins←{0∊⍴⍺:⍵ ⋄ ⍺} ⍝ set if not set
    stopIf←{1∊⍵:-⎕TRAP←0 'C' '⎕←''Stopped for debugging... (Press Ctrl-Enter)''' ⋄ shy←0} ⍝ faster alternative to setting ⎕STOP
    show←{(2⊃⎕SI),'[',(⍕2⊃⎕LC),'] ',⍵} ⍝ debugging utility
    utf8←{3=10|⎕DR ⍵: 256|⍵ ⋄ 'UTF-8' ⎕UCS ⍵}
    fromutf8←{0::(⎕AV,'?')[⎕AVU⍳⍵] ⋄ 'UTF-8'⎕UCS ⍵} ⍝ Turn raw UTF-8 input into text
    sint←{⎕IO←0 ⋄ 83=⎕DR ⍵:⍵ ⋄ 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 ¯128 ¯127 ¯126 ¯125 ¯124 ¯123 ¯122 ¯121 ¯120 ¯119 ¯118 ¯117 ¯116 ¯115 ¯114 ¯113 ¯112 ¯111 ¯110 ¯109 ¯108 ¯107 ¯106 ¯105 ¯104 ¯103 ¯102 ¯101 ¯100 ¯99 ¯98 ¯97 ¯96 ¯95 ¯94 ¯93 ¯92 ¯91 ¯90 ¯89 ¯88 ¯87 ¯86 ¯85 ¯84 ¯83 ¯82 ¯81 ¯80 ¯79 ¯78 ¯77 ¯76 ¯75 ¯74 ¯73 ¯72 ¯71 ¯70 ¯69 ¯68 ¯67 ¯66 ¯65 ¯64 ¯63 ¯62 ¯61 ¯60 ¯59 ¯58 ¯57 ¯56 ¯55 ¯54 ¯53 ¯52 ¯51 ¯50 ¯49 ¯48 ¯47 ¯46 ¯45 ¯44 ¯43 ¯42 ¯41 ¯40 ¯39 ¯38 ¯37 ¯36 ¯35 ¯34 ¯33 ¯32 ¯31 ¯30 ¯29 ¯28 ¯27 ¯26 ¯25 ¯24 ¯23 ¯22 ¯21 ¯20 ¯19 ¯18 ¯17 ¯16 ¯15 ¯14 ¯13 ¯12 ¯11 ¯10 ¯9 ¯8 ¯7 ¯6 ¯5 ¯4 ¯3 ¯2 ¯1[utf8 ⍵]}
    Zipper←219⌶

    ∇ r←DyalogRoot
      r←{⍵,('/\'∊⍨⊢/⍵)↓'/'}{0∊⍴t←2 ⎕NQ'.' 'GetEnvironment' 'DYALOG':⊃1 ⎕NPARTS⊃2 ⎕NQ'.' 'GetCommandLineArgs' ⋄ t}''
    ∇

    ∇ r←MyAddr
      :Access public shared
      :Trap 0
          r←2 ⎕NQ #'TCPGetHostID'
      :Else
          r←'localhost'
      :EndTrap
    ∇

    ∇ r←crlf
      r←⎕UCS 13 10
    ∇

    ∇ QuadOFF
    ⍝ cover for ⎕OFF in case we want to add debugging
      ⎕OFF
    ∇

    ∇ r←Now
      r←DateToIDNX ⎕TS
    ∇

    ∇ r←fmtCongaEvent evt
    ⍝ formats the result of LDRC.Wait
      r←(⍕3↑evt),' ',{500≥≢⍵:⍵ ⋄ (⍕≢⍵),'⍴ ',(250↑⍵),' ... ',(¯250↑⍵)}4⊃evt,'' '' ⍝ ensure evt has a 4th element
    ∇

    ∇ r←InTerm;system
      :Access Public Shared
    ⍝ determine if interactive terminal is available
      →0⍴⍨r←~0∊⍴2 ⎕NQ'.' 'GetEnvironment' 'RIDE_INIT'
      →0⍴⍨r←'Win' 'Dev'≡system←3↑¨(⊂1 4)⌷'.'⎕WG'APLVersion'
      r←('Lin' 'Dev'≡system)∧{0::0 ⋄ 1⊣⎕SH'test -t 0'}''
    ∇

    ∇ r←fmtTS ts
      r←∊'YYYY-MM-DD @ hh.mm.ss.fff'(1200⌶)1 ⎕DT⊂⎕TS
    ∇

    ∇ r←a splitOn w
    ⍝ split a where w occurs (removing w from the result)
      r←a{⍺{(¯1+⊃¨⊆⍨⍵)↓¨⍵⊆⍺}(1+≢⍵)*⍵⍷⍺}w
    ∇

    ∇ r←a splitOnFirst w
    ⍝ split a on first occurence of w (removing w from the result)
      r←a{⍺{(¯1+⊃¨⊆⍨⍵)↓¨⍵⊆⍺}(1+≢⍵)*<\⍵⍷⍺}w
    ∇

    ∇ r←type ipRanges string;ranges
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

    ∇ r←isWin
    ⍝ are we running under Windows?
      r←'Win'≡3↑⊃#.⎕WG'APLVersion'
    ∇

    ∇ r←isRelPath w
    ⍝ is path w a relative path?
      r←{{~'/\'∊⍨(⎕IO+2×isWin∧':'∊⍵)⊃⍵}3↑⍵}w
    ∇

    ∇ r←isDir path
    ⍝ is path a directory?
      r←{11 22::0 ⋄ 1=1 ⎕NINFO ⍵}path
    ∇

    ∇ r←SourceFile;class
      :If 0∊⍴r←4⊃5179⌶class←⊃∊⎕CLASS ⎕THIS
          r←{6::'' ⋄ ∊1 ⎕NPARTS ⍵⍎'SALT_Data.SourceFile'}class
      :EndIf
    ∇

    ∇ r←resolveFilename filename
    ⍝ resolve filename to an absolute path even if it contains . .. or symbolic links
    ⍝ under Windows 1 ⎕NPARTS does this, but not on non-Windows
    ⍝ so, on non-Windows, we try to use the "realpath" command
    ⍝ NB: realpath might need to be installed if you're running on AIX     
      :If isWin
          r←∊1 ⎕NPARTS filename
      :Else
          filename←1⌽'''''',''''⎕R'''\\'''''⊢filename ⍝ enclose in quotes, escaping existing quotes
          r←{0::'' ⋄ ⊃⎕SH'realpath ',filename,' 2>/dev/null'}filename
      :EndIf
    ∇

    ∇ r←makeRegEx w
      :Access public shared
    ⍝ convert a simple search using ? and * to regex
      r←{0∊⍴⍵:⍵
          {'^',(⍵~'^$'),'$'}{¯1=⎕NC('A'@(∊∘'?*'))r←⍵:('/'=⊣/⍵)↓(¯1×'/'=⊢/⍵)↓⍵   ⍝ already regex? (remove leading/trailing '/'
              r←∊(⊂'\.')@('.'=⊢)r  ⍝ escape any periods
              r←'.'@('?'=⊢)r       ⍝ ? → .
              r←∊(⊂'\/')@('/'=⊢)r  ⍝ / → \/
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
              2(root ⍙FIX)'file://',file
          :Else
              msg,←'Unable to load file: ',file,⎕UCS 13
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

    ∇ {r}←{larg}(ref ⍙FIX)rarg;isArrayNotation;t;f;p
    ⍝ ⎕FIX cover that accommodates Array Notation and .apla files
    ⍝ revert to using ⎕FIX when it supports them
      larg←{6::⍵ ⋄ larg}1
      isArrayNotation←{~0 2∊⍨10|⎕DR ⍵:0 ⋄ {(⊃⍵)∊d←'[''¯.⊂⎕⍬',⎕D:1 ⋄ (2⊃2↑⍵)∊d,'( '}(∊⍵)~⎕UCS 9 32}
      :Trap 0
          :If 1=≡rarg
          :AndIf 'file://'≡7↑rarg
          :AndIf '.apla'≡lc⊃⌽p←⎕NPARTS f←7↓rarg
              :If larg=2
                  r←(2⊃p)ref.{⍎⍺,'←⍵'}1 Deserialise⊃⎕NGET f
              :Else
                  r←ref⍎0 Deserialise⊃⎕NGET f
              :EndIf
          :ElseIf isArrayNotation 1↓∊(⎕UCS 13),¨⊆rarg
              r←ref⍎0 Deserialise rarg
          :Else
              r←larg ref.⎕FIX rarg
          :EndIf
      :Else
          ⎕SIGNAL⊂t,⍪⎕DMX⍎1⌽')(',∊⍕t←'EN' 'EM' 'Message'
      :EndTrap
    ∇

    ∇ r←a Deserialise w;DEBUG;sysVars;Num;FirstNum;FirstNs
      :Access public shared
    ⍝ attempt to use the installed Deserialise
      :If 3=⎕SE.⎕NC'Dyalog.Array.Deserialise'
          r←a ⎕SE.Dyalog.Array.Deserialise w
          →0
      :EndIf
    ⍝ If Deserialise is not available in ⎕SE, the code below was lifted from the qSE repository commit 67a9ca1
    ⍝ Rather than embed the entirety of the Array namespace, just use Deserialise and the bits it depends on
      DEBUG←0
      sysVars←'⎕CT' '⎕DIV' '⎕IO' '⎕ML' '⎕PP' '⎕RL' '⎕RTL' '⎕WX' '⎕USING' '⎕AVU' '⎕DCT' '⎕FR'
      Num←2|⎕DR
      FirstNum←Num¨⊃⍤/⊢
      FirstNs←{9∊⎕NC'⍵'}¨⊃⍤/⊢
     
    ⍝ Deserialise code follows
      r←a{ ⍝ Convert text to array
          ⍺←⍬ ⍝ 1=safe exec expr; 0=return expr; ¯1=unsafe exec expr; ¯2=force APL model
          (model beSafe execute)←(¯2∘=,0∘⌈,1⌊|)FirstNum ⍺,1
          caller←FirstNs ⍺,⊃⎕RSI
     
          ⍝ Make normalised simple vector:
          w←↓⍣(2=≢⍴⍵)⊢⍵                  ⍝ if mat, make nested
          w←{¯1↓∊⍵,¨⎕UCS 13}⍣(2=|≡w)⊢w   ⍝ if nested, make simple
     
          beSafe>Safe w:⎕SIGNAL⊂('EN' 11)('Message' 'Unsafe array notation')
                                                          ⍝ fall back to APL model on error
          ⍝ model<execute∧'AIX'≢3↑⊃# ⎕WG'APLVersion':caller ∇{2::⍵ ⍺⍺⍨¯2,⍺ ⋄ ⍺ ∆APLAN,⍵}w
     
          q←''''
          ⎕IO←0
          SEP←'⋄',⎕UCS 10 13
     
          Unquot←{(⍺⍺ ⍵)×~≠\q=⍵}
          SepMask←∊∘SEP Unquot
          ParenLev←+\(×¯3+7|¯3+'([{)]}'∘⍳)Unquot
     
          Paren←1⌽')(',⊢
          Split←{1↓¨⍺⍺⊂Over(1∘,)⍵}
     
          Over←{(⍵⍵ ⍺)⍺⍺(⍵⍵ ⍵)}
          EachIfAny←{0=≢⍵:⍵ ⋄ ⍺ ⍺⍺¨⍵}
          EachNonempty←{⍺ ⍺⍺ EachIfAny Over((×≢¨⍵~¨' ')/⊢)⍵}
     
          Parse←{
              0=≢⍵:''
              bot←0=⍺
              (2≤≢⍵)>∨/¯1↓bot:⍺ SubParse ⍵
              p←bot×SepMask ⍵
              ∨/p:∊{1=≢⍵:',⊂',⍵ ⋄ ⍵}⍺(Paren ∇)EachNonempty Over(p Split)⍵
              p←2(1,>/∨¯1↓0,</)bot
              ∨/1↓p:∊(p⊂⍺)∇¨p⊂⍵
              ⍵
          }
     
          ErrIfEmpty←{⍵⊣'Array doesn''t have a prototype'⎕SIGNAL 11/⍨(0=≢⍵)}
     
          SubParse←{
              ('})]'⍳⊃⌽⍵)≠('{(['⍳⊃⍵):'Bad bracketing'⎕SIGNAL 2
              (a w)←(1↓¯1∘↓)¨(⍺-1)⍵
              '['=⊃⍵:Paren'{⎕ML←1⋄↑⍵}1/¨',Paren ErrIfEmpty a Parse w ⍝ high-rank
              ':'∊⍵/⍨(1=⍺)×~≠\q=⍵:a Namespace w ⍝ ns
              '('=⊃⍵:Paren{⍵,'⎕NS⍬'/⍨0=≢⍵}a Parse w ⍝ vector/empty ns
              ⍵ ⍝ dfn
          }
     
          SysVar←(⎕C sysVars)∊⍨' '~¨⍨⎕C∘⊆
     
          ParseLine←{
              c←⍵⍳':'
              1≥≢(c↓⍵)~' ':'Missing value'⎕SIGNAL 6
              name←c↑⍵
              (SysVar⍱¯1≠⎕NC)name:'Invalid name'⎕SIGNAL 2
              name(name,'←',⍺ Parse Over((c+1)↓⊢)⍵)
          }
     
          Namespace←{
              p←(0=⍺)×SepMask ⍵
              (names assns)←↓⍉↑⍺ ParseLine EachNonempty Over(p Split)⍵
              quadMask←SysVar names
              quadAssns←'{⍵.(⍵',(∊'⊣',¨quadMask/assns),')}'
              names/⍨←~quadMask
              assns/⍨←~quadMask
              names,←(0=≢names)/⊂''
              ∊'({'(assns,¨'⋄')quadAssns'⎕NS'('(, '∘,¨q,¨names,¨⊂q')')'}⍬)'
          }
     
          Execute←{   ⍝ overcome LIMIT ERROR on more than 4096 parenthesised expressions
              ExecuteEach←{         ⍝ split at level-1 parentheses and execute each
                  l←(t=¯1)++\t←{1 ¯1 0['()'⍳⍵]}Unquot ⍵ ⍝ parenthesis type and level
                  (h x t l)←(1 0 0 0=⊂∧\l=0)/¨⍵ ⍵ t l   ⍝ extract header before first opening parenthesis
                  ⍺{0::0 ⋄ r←⍺⍎⍵ ⋄ ~(⊃⎕NC'r')∊3 4}h:⍺⍎⍵ ⍝ header must be an functional expression
                  H←⍺{⍺⍺⍎⍵⍵,'⍵'}h                       ⍝ function to apply header to array
                  ' '∨.≠(l=0)/x:⍺⍎⍵                     ⍝ something outside level-1 parentheses - must fall back to ⍎
                  x←(((l>0)∧(l≠1)∨(t=0))×+\(t=1)∧(l=1))⊆x   ⍝ cut expression within level-1 parentheses
                  1=≢x:H ⍺ ∇⊃x                          ⍝ single expression : don't enclose with ¨
                  DEBUG∧1<⌈/l:H ⍺ ∇¨x                    ⍝ force going through the hard code
                  10::H ⍺ ∇¨x ⋄ H ⍺⍎¨x                  ⍝ attempt to ⍎¨ with a single guard - otherwise dig each
              }
              DEBUG:⍺ ExecuteEach ⍵           ⍝ force going through the hard code
              10::⍺ ExecuteEach ⍵ ⋄ ⍺⍎⍵       ⍝ attempt simple ⍎ and catch LIMIT ERROR
          }
     
          w←'''[^'']*''' '⍝.*'⎕R'&' ''⊢w ⍝ strip comments
          w/⍨←{(∨\⍵)∧⌽∨\⌽⍵}33≤⎕UCS w     ⍝ strip leading/trailing non-printables
     
          pl←ParenLev w
          (0≠⊢/pl)∨(∨/0>pl):'Unmatched brackets'⎕SIGNAL 2
          ∨/(pl=0)×SepMask w:'Multi-line input'⎕SIGNAL 11
          caller Execute⍣execute⊢pl Parse w ⍝ materialise namespace as child of calling namespace
      }w
    ∇

    :EndSection

    :Section HTML
    ∇ r←ScriptFollows
    ⍝ return the subsequent block of comments as a text script
      r←{⍵/⍨'⍝'≠⊃¨⍵}{1↓¨⍵/⍨∧\'⍝'=⊃¨⍵}{⍵{((∨\⍵)∧⌽∨\⌽⍵)/⍺}' '≠⍵}¨(1+2⊃⎕LC)↓↓(180⌶)2⊃⎕XSI
      r←2↓∊(⎕UCS 13 10)∘,¨r
    ∇

    ∇ r←{path}EndPoints ref;ns
      :Access public
      :If 0=⎕NC'path' ⋄ path←''
      :Else ⋄ path,←'.'
      :EndIf
      r←path∘,¨{(⊂'')~⍨⍵.{⍵/⍨1 1 0≡×|⎕IO⊃⎕AT ⍵}¨⍵.⎕NL ¯3}ref ⍝ limit to result-returning monadic/dyadic/ambivalent functions
      :For ns :In ref.⎕NL ¯9.1
          r,←(path,ns)EndPoints ref⍎ns
      :EndFor
    ∇

    ∇ r←HtmlPage;endpoints
      :Access public
      r←ScriptFollows
⍝<!DOCTYPE html>
⍝<html>
⍝<head>
⍝<meta content="text/html; charset=utf-8" http-equiv="Content-Type">
⍝<link rel="icon" href="data:,">
⍝<title>Jarvis</title>
⍝ <style>
⍝   body {color:#000000;background-color:white;font-family:Verdana;margin-left:0px;margin-top:0px;}
⍝   button {display:inline-block;font-size:1.1em;}
⍝   legend {font-size:1.1em;}
⍝   select {font-size:1.1em;}
⍝   label  {display:inline-block;margin-bottom:7px;}
⍝   div {padding:5px;}
⍝   label input textarea button #result {display:flex;}
⍝   textarea {width:100%;font-size:18px;}
⍝   #result {font-size:18px;}
⍝   #result code {white-space:pre-line;word-wrap:break-word;}
⍝ </style>
⍝</head>
⍝<body>
⍝<div id="content">
⍝<fieldset>
⍝  <legend>Request</legend>
⍝  <form id="myform">
⍝    <div>
⍝      <label for="function">Endpoint:</label>
⍝      ⌹
⍝    </div>
⍝    <div>
⍝      <label for="payload">JSON Payload:</label>
⍝      <textarea id="payload" name="payload"></textarea>
⍝    </div>
⍝    <div>
⍝      <button onclick="doit()" type="button">Send</button>
⍝    </div>
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
⍝  var payload = document.getElementById("payload").value;
⍝  if (0 == payload.length) {
⍝    document.getElementById("result").innerHTML = "<span style='color:red;'>Please enter a valid JSON payload</span>";
⍝    } else {
⍝    var xhttp = new XMLHttpRequest();
⍝    var fn = document.getElementById("function").value;
⍝    fn = (0 == fn.indexOf('/')) ? fn : '/' + fn;
⍝
⍝    xhttp.open("POST", fn, true);
⍝    xhttp.setRequestHeader("content-type", "application/json; charset=utf-8");
⍝
⍝    xhttp.onreadystatechange = function() {
⍝      if (this.readyState == 4){
⍝        if (this.status == 200) {
⍝          try {
⍝            var resp = "<pre><code>" + JSON.stringify(JSON.parse(this.responseText)) + "</code></pre>";;
⍝          }
⍝          catch(err) {
⍝            var resp = "<pre><code>" + this.responseText + "</code></pre>";
⍝          }
⍝        } else {
⍝          var resp = "<span style='color:red;'>" + this.statusText + "</span> <pre><code>" + this.responseText + "</code></pre>";
⍝        }
⍝        document.getElementById("result").innerHTML = resp;
⍝      }
⍝    }
⍝    xhttp.send(document.getElementById("payload").value);
⍝  }
⍝}
⍝</script>
⍝</div>
⍝</body>
⍝</html>
      endpoints←{⍵/⍨0=CheckFunctionName ⍵}EndPoints CodeLocation
      :If 0∊⍴endpoints
          endpoints←'<b>No Endpoints Found</b>'
      :Else
          endpoints←∊{'<option value="',⍵,'">',⍵,'</option>'}¨'/'@('.'=⊢)¨endpoints
          endpoints←'<select id="function" name="function">',endpoints,'</select>'
      :EndIf
      r←endpoints{i←⍵⍳'⌹' ⋄ ((i-1)↑⍵),⍺,i↓⍵}r
      r←'UTF-8'⎕UCS r
    ∇
    :EndSection

:EndClass
