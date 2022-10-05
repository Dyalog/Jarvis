:Class Jarvis
⍝ Dyalog Web Service Server
⍝ See https://github.com/dyalog/jarvis/wiki for documentation

    (⎕ML ⎕IO)←1 1

  ⍝ User hooks settings
    :Field Public AppCloseFn←''                                ⍝ name of the function to run on application (server) shutdown
    :Field Public AppInitFn←''                                 ⍝ name of the application "bootstrap" function
    :Field Public AuthenticateFn←''                            ⍝ name of function to perform authentication,if empty, no authentication is necessary
    :Field Public SessionInitFn←''                             ⍝ Function name to call when initializing a session
    :Field Public ValidateRequestFn←''                         ⍝ name of the request validation function

   ⍝ Operational settings
    :Field Public CodeLocation←''                              ⍝ reference to application code location, if the user specifies a folder, that value is saved in Folder
    :Field Public ConnectionTimeout←30                         ⍝ HTTP/1.1 connection timeout in seconds
    :Field Public Debug←0                                      ⍝ 0 = all errors are trapped, 1 = stop on an error, 2 = stop on intentional error before processing request, 4 = Jarvis framework debugging
    :Field Public DefaultContentType←'application/json; charset=utf-8'
    :Field Public ErrorInfoLevel←1                             ⍝ level of information to provide if an APL error occurs, 0=none, 1=⎕EM, 2=⎕SI
    :Field Public ExcludeFns←''                                ⍝ vector of vectors for function names to be excluded (can use regex or ? and * as wildcards)
    :Field Public Folder←''                                    ⍝ folder that user supplied in CodeLocation from which to load code
    :Field Public Hostname←''                                  ⍝ external-facing host name
    :Field Public HTTPAuthentication←'basic'                   ⍝ valid settings are currently 'basic' or ''
    :Field Public IncludeFns←''                                ⍝ vector of vectors for function names to be included (can use regex or ? and * as wildcards)
    :Field Public JarvisConfig←''                              ⍝ configuration file path (if any). This parameter was formerly named ConfigFile
    :Field Public LoadableFiles←'*.apl?,*.dyalog'              ⍝ file patterns that can be loaded if loading from folder
    :Field Public Logging←1                                    ⍝ turn logging on/off
    :Field Public Paradigm←'JSON'                              ⍝ either 'JSON' or 'REST'
    :Field Public Report404InHTML←1                            ⍝ Report HTTP 404 status (not found) in HTML (only valid if HTML interface is enabled)

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
    :Field Public HTMLInterface←¯1                             ⍝ ¯1=unassigned, 0/1=dis/allow the HTML interface, or Path to HTML[/home-page]
    :Field Public JSONInputFormat←'D'                          ⍝ set this to 'M' to have Jarvis convert JSON request payloads to the ⎕JSON matrix format

   ⍝ REST mode settings
    :Field Public ParsePayload←1                               ⍝ 1=parse request payload based on content-type header (REST only)
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
    :Field _conxRef                      ⍝ reference to _connections⍎ServerName

    ∇ r←Version
      :Access public shared
      r←'Jarvis' '1.11.8' '2022-10-04'
    ∇

    ∇ r←Config
    ⍝ returns current configuration
      :Access public
      r←↑{⍵(⍎⍵)}¨⎕THIS⍎'⎕NL ¯2.2 ¯2.1'
    ∇

    ∇ r←{value}DebugLevel level
    ⍝  monadic: return 1 if level is within Debug (powers of 2)
    ⍝    example: stopIf DebugLevel 2  ⍝ sets a stop if Debug contains 2
    ⍝  dyadic:  return value unless level is within Debug (powers of 2)
    ⍝    example: :Trap 0 DebugLevel 5 ⍝ set Trap 0 unless Debug contains 1 or 4 in its
      :Access public
      r←∨/(2 2 2⊤⊃Debug)∨.∧2 2 2⊤level
      :If 0≠⎕NC'value'
          r←value/⍨~r
      :EndIf
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
      :Trap 11
          JSONin←{##.##.⎕JSON⍠('Dialect' 'JSON5')('Format'JSONInputFormat)⊢⍵} ⋄ {}JSONin 1
          JSONout←##.##.⎕JSON⍠'HighRank' 'Split' ⋄ {}JSONout 1
          JSONread←##.##.⎕JSON⍠'Dialect' 'JSON5' ⍝ for reading configuration files
      :Else
          JSONin←{##.##.⎕JSON⍠('Format'JSONInputFormat)⊢⍵}
          JSONread←JSONout←##.##.⎕JSON
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
     
          homePage←1 ⍝ default is to use built-in home page
          :Select ⊃HTMLInterface
          :Case 0 ⍝ explicitly no HTML interface, carry on
              _htmlEnabled←0
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
          Log'Serving code in ',(⍕CodeLocation),(Folder≢'')/' (populated with code from "',Folder,'")'
          Log(_htmlEnabled∧homePage)/'Click http',(~Secure)↓'s://',MyAddr,':',(⍕Port),' to access web interface'
     
      :Else ⍝ :Trap
          (rc msg)←¯1 ⎕DMX.EM
      :EndTrap
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
      {0:: ⋄ LDRC.Close 2⊃LDRC.Clt'' ''Port'http'}''
      :While ~_stopped
          :If WaitTimeout<⎕AI[3]-ts
              →0⊣(rc msg)←¯1 'Server seems stuck'
          :EndIf
      :EndWhile
      (rc msg)←0 'Server stopped'
    ∇

    ∇ (rc msg)←Pause;ts
      :Access public
      :If 0 2≡2⊃LDRC.GetProp ServerName'Pause'
          →0⊣(rc msg)←¯1 'Server is already paused'
      :EndIf
      :If ~_started
          →0⊣(rc msg)←¯1 'Server is not running'
      :EndIf
      ts←⎕AI[3]
      LDRC.SetProp ServerName'Pause' 2
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
          public←⎕THIS⍎'⎕NL ¯2.2 ¯2.1' ⍝ find all the public fields in this class
          :If ~0∊⍴set←public{⍵/⍨⍵∊⍺}config.⎕NL ¯2 ¯9
              config{⍎⍵,'←⍺⍎⍵'}¨set
          :EndIf
          _configLoaded←1
      :Else
          →0⊣(rc msg)←⎕DMX.EN ⎕DMX.('Error loading configuration: ',EM,(~0∊⍴Message)/' (',Message,')')
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
                  :For root :In ##.## #
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
          CongaVersion←0.1⊥2↑LDRC.Version
          LDRC.X509Cert.LDRC←LDRC ⍝ reset X509Cert.LDRC reference
          Log'Local Conga reference is ',⍕LDRC
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
              :ElseIf 0≡⊃CongaPath CongaRef.Init'' ⋄ LDRC←CongaRef ⍝ DRC?
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

    ∇ (rc msg secureParams)←CreateSecureParams;cert;certs;msg;mask;matchID
    ⍝ return Conga parameters for running HTTPS, if Secure is set to 1
     
      LDRC.X509Cert.LDRC←LDRC ⍝ make sure the X509 instance points to the right LDRC
      (rc secureParams msg)←0 ⍬''
      :If Secure
          :If ~0∊⍴RootCertDir ⍝ on Windows not specifying RootCertDir will use MS certificate store
              →∆EXIT If(rc msg)←'RootCertDir'Exists RootCertDir
              →∆EXIT If(rc msg)←{(⊃⍵)'Error setting RootCertDir'}LDRC.SetProp'.' 'RootCertDir'RootCertDir
          :ElseIf 0∊⍴ServerCertSKI
              →∆EXIT If(rc msg)←'ServerCertFile'Exists ServerCertFile
              →∆EXIT If(rc msg)←'ServerKeyFile'Exists ServerKeyFile
              :Trap 0 DebugLevel 1
                  cert←⊃LDRC.X509Cert.ReadCertFromFile ServerCertFile
              :Else
                  (rc msg)←⎕DMX.EN('Unable to decode ServerCertFile "',(∊⍕ServerCertFile),'" as a certificate')
                  →∆EXIT
              :EndTrap
              cert.KeyOrigin←'DER'ServerKeyFile
          :ElseIf isWin
              certs←LDRC.X509Cert.ReadCertUrls
              :If 0∊⍴certs
                  →∆EXIT⊣(rc msg)←8 'No certificates found in Microsoft Certificate Store'
              :Else
                  matchID←{'id=(.*);'⎕S'\1'⍠'Greedy' 0⊢2⊃¨z.CertOrigin}2⊃¨certs.CertOrigin
                  mask←ServerCertSKI{∨/¨(⊂⍺)⍷¨2⊃¨⍵}certs.CertOrigin
                  :If 1≠+/mask
                      rc←9
                      msg←(0 2⍸+/mask)⊃('Certificate with id "',ServerCertSKI,'" was not found in the Microsoft Certificate Store')('There is more than one certificate with Subject Key Identifier "',ServerCertSKI,'" in the Microsoft Certificate Store')
                      →∆EXIT
                  :EndIf
                  cert←certs[⊃⍸mask]
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
     
      :For fn :In AppInitFn AppCloseFn ValidateRequestFn AuthenticateFn SessionInitFn~⊂''
          :If 3≠CodeLocation.⎕NC fn
              msg,←(0∊⍴msg)↓',"CodeLocation.',fn,'" was not found '
          :EndIf
      :EndFor
      →0 If rc←8×~0∊⍴msg
     
      :If ~0∊⍴AppInitFn  ⍝ initialization function specified?
          :If 1 0 0≡⊃CodeLocation.⎕AT AppInitFn ⍝ result-returning niladic?
              stopIf DebugLevel 2
              res←CodeLocation⍎AppInitFn        ⍝ run it
              :If 0≠⊃res
                  →0⊣(rc msg)←2↑res,(≢res)↓¯1('"',(⍕CodeLocation),'.',AppInitFn,'" did not return a 0 return code')
              :EndIf
          :Else
              →0⊣(rc msg)←8('"',(⍕CodeLocation),'.',AppInitFn,'" is not a niladic result-returning function')
          :EndIf
      :EndIf
     
     
      :If ~0∊⍴AppCloseFn ⍝ application close function specified?
          :If 1 0 0≢⊃CodeLocation.⎕AT AppCloseFn ⍝ result-returning niladic?
              →0⊣(rc msg)←8('"',(⍕CodeLocation),'.',AppCloseFn,'" is not a niladic result-returning function')
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
          options←⊂'Options' 5 ⍝ DecodeBuffers + WSAutoAccept
      :EndIf
     
      _connections←⎕NS''
      _connections.index←2 0⍴'' 0
      _connections.lastCheck←0
     
      :If 0=rc←1⊃r←LDRC.Srv ServerName''Port'http'BufferSize,secureParams,accept,deny,options
          ServerName←2⊃r
          ServerName _connections.⎕NS''
          _conxRef←_connections⍎ServerName
          :If 3.3>CongaVersion
              {}LDRC.SetProp ServerName'FIFOMode' 0 ⍝ deprecated in Conga v3.2
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

    ∇ {r}←Server arg;wres;rc;obj;evt;data;ref;ip;msg;tmp
      (_started _stopped)←1 0
      :While ~_stop
          :Trap 0 DebugLevel 1
              wres←LDRC.Wait ServerName WaitTimeout ⍝ Wait for WaitTimeout before timing out
          ⍝ wres: (return code) (object name) (command) (data)
              (rc obj evt data)←4↑wres
              :Select rc
              :Case 0
                  :Select evt
                  :Case 'Error'
                      _stop←ServerName≡obj ⍝ if we got an error on the server itself, signal to stop
                      :If 0≠4⊃wres
                          Log'Server: DRC.Wait reported error ',(⍕4⊃wres),' on ',(2⊃wres),GetIP obj
                      :EndIf
                      RemoveConnection obj ⍝ Conga closes object on an Error event
     
                  :Case 'Connect'
                      AddConnection obj
     
                  :CaseList 'HTTPHeader' 'HTTPTrailer' 'HTTPChunk' 'HTTPBody'
                      :If 0≠_connections.⎕NC obj
                          ref←_connections⍎obj
                          _taskThreads←⎕TNUMS∩_taskThreads,ref{⍺ HandleRequest ⍵}&wres
                          ref.Time←⎕AI[3]
                      :Else
                          Log'Server: Object ''_connections.',obj,''' was not found.'
                          {}{0:: ⋄ LDRC.Close ⍵}obj
                      :EndIf
     
                  :Case 'Closed'
                      RemoveConnection obj
     
                  :Case 'Timeout'
     
                  :Else ⍝ unhandled event
                      Log'Server: Unhandled Conga event:'
                      Log⍕wres
                  :EndSelect ⍝ evt
     
              :Case 1010 ⍝ Object Not found
                  :If ~_stop
                      Log'Server: Object ''',ServerName,''' has been closed - Jarvis shutting down'
                      _stop←1
                  :EndIf
              :Else
                  Log'Server: Conga wait failed:'
                  Log wres
              :EndSelect ⍝ rc
     
              CleanupConnections
     
          :Else ⍝ :Trap
              Log'*** Server error ',msg←(JSONout⍠'Compact' 0)⎕DMX
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

    ∇ AddConnection name
      :Hold '_connections'
          name _connections.⎕NS''
          _connections.index,←(name(⍳↓⊣)'.')(⎕AI[3])
          (_connections⍎name).IP←2⊃2⊃LDRC.GetProp obj'PeerAddr'
      :EndHold
    ∇

    ∇ RemoveConnection name
      :Hold '_connections'
          _connections.⎕EX name
          _connections.index/⍨←_connections.index[1;]≢¨⊂name(⍳↓⊣)'.'
      :EndHold
    ∇

    ∇ CleanupConnections;conxNames;timedOut;dead;kids;connecting;connected
      :If _connections.lastCheck<⎕AI[3]-ConnectionTimeout×1000
          :Hold '_connections'
              connecting←connected←⍬
              :If ~0∊⍴kids←2 2⊃LDRC.Tree ServerName
                  (connecting connected)←2↑{((2 2⍴3 1 3 4)⍪⍵[;2 3]){⊂1↓⍵}⌸'' '',⍵[;1]}↑⊃¨kids
              :EndIf
              conxNames←_connections.index[1;]~connecting
              timedOut←_connections.index[1;]/⍨ConnectionTimeout<0.001×⎕AI[3]-_connections.index[2;]
              :If ∨/~0∘∊∘⍴¨connected conxNames
                  {0∊⍴⍵: ⋄ {}LDRC.Close ServerName,'.',⍵}¨dead←(connected~conxNames),timedOut
                  _conxRef.⎕EX(conxNames~connected~dead),timedOut
                  _connections.index/⍨←_connections.index[1;]∊_conxRef.⎕NL ¯9
              :EndIf
              _connections.lastCheck←⎕AI[3]
          :EndHold
      :EndIf
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
     
              :If _htmlEnabled∧ns.Req.Response.Status≠200
                  ns.Req.Response.Headers←1 2⍴'Content-Type' 'text/html; charset=utf-8'
                  ns.Req.Response.Payload←'<h3>',(⍕ns.Req.Response.((⍕Status),' ',StatusText)),'</h3>'
                  →resp
              :EndIf
     
            ⍝ Application-specified validation
              stopIf DebugLevel 4+2×~0∊⍴ValidateRequestFn
              rc←Validate ns.Req
              ns.Req.Fail 400×(ns.Req.Response.Status=200)∧0≠rc ⍝ default status 400 if not set by application
              →resp If rc≠0
     
              fn←1↓'.'@('/'∘=)ns.Req.Endpoint
     
              fn RequestHandler ns ⍝ RequestHandler is either HandleJSONRequest or HandleRESTRequest
     
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
     
      →0 If CheckAuthentication ns.Req
     
      →0 If('Invalid function "',fn,'"')ns.Req.Fail CheckFunctionName fn
      →0 If('Invalid function "',fn,'"')ns.Req.Fail 404×3≠⌊|{0::0 ⋄ CodeLocation.⎕NC⊂⍵}fn  ⍝ is it a function?
      valence←|⊃CodeLocation.⎕AT fn
      nc←CodeLocation.⎕NC⊂fn
      →0 If('"',fn,'" is not a monadic result-returning function')ns.Req.Fail 400×(1 1 0≢×valence)>(0∧.=valence)∧3.3=nc
     
      resp←''
      :Trap 0 DebugLevel 1
          :Trap 85
              :If (2=valence[2])>3.3=nc ⍝ dyadic and not tacit
                  stopIf DebugLevel 2
                  resp←ns.Req{1 CodeLocation.(85⌶)'⍺ ',fn,' ⍵'}ns.Req.Payload ⍝ intentional stop for application-level debugging
              :Else
                  stopIf DebugLevel 2
                  resp←{1 CodeLocation.(85⌶)fn,' ⍵'}ns.Req.Payload ⍝ intentional stop for application-level debugging
              :EndIf
          :EndTrap
      :Else
          →0⊣ns.Req.Fail 500
      :EndTrap
    ⍝ ↓↓↓ removed this next line because a non-2XX response might still have a payload
    ⍝ →0 If 2≠⌊0.01×ns.Req.Response.Status ⍝ exit if not a successful HTTP code
      →0 If 0∊⍴resp ⍝ exit if there's no response payload
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
      →0 If HandleCORSRequest ns.Req
      →0 If CheckAuthentication ns.Req
     
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
     
      resp←''
      :Trap 0 DebugLevel 1
          :Trap 85
              stopIf DebugLevel 2
              resp←{1 CodeLocation.(85⌶)exec,' ⍵'}ns.Req  ⍝ intentional stop for application-level debugging
          :EndTrap
      :Else
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

    ∇ response ToJSON data
    ⍝ convert APL response payload to JSON
      :Trap 0 DebugLevel 1
          ns.Req.Response.Payload←⎕UCS'UTF-8'⎕UCS 1 JSONout resp
      :Else
          'Could not format result payload as JSON'ns.Req.Fail 500
      :EndTrap
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
              'Unauthorized'req.Fail 401
              :If HTTPAuthentication match'basic'
                  'WWW-Authenticate'req.SetHeader'Basic realm="Jarvis", charset="UTF-8"'
              :EndIf
          :EndIf
      :Else ⍝ Authenticate errored
          (⎕DMX.EM,' occured during authentication')req.Fail 500
          rc←1
      :EndTrap
    ∇

    ∇ obj Respond req;status;z;res;close;conx
      res←req.Response
      status←(⊂req.HTTPVersion),res.((⍕Status)StatusText)
      res.Headers⍪←'Server'(deb⍕2↑Version)
      res.Headers⍪←'Date'(2⊃LDRC.GetProp'.' 'HttpDate')
      conx←lc req.GetHeader'connection'
      close←(('HTTP/1.0'≡req.HTTPVersion)>'keep-alive'≡conx)∨'close'≡conx
      close∨←2≠⌊0.01×res.Status ⍝ close the connection on non-2XX status
      :Select 1⊃z←LDRC.Send obj(status,res.Headers res.Payload)close
      :Case 0 ⍝ everything okay, nothing to do
      :Case 1008 ⍝ Wrong object class likely caused by socket being closed during the request
        ⍝ do nothing for now
      :Else
          Log'Respond: Conga error when sending response',GetIP obj
          Log⍕z
      :EndSelect
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
          →0 If r←404×fn∊AppInitFn AppCloseFn ValidateRequestFn AuthenticateFn SessionInitFn
          :If ~0∊⍴_includeRegex
              →0 If r←404×0∊⍴(_includeRegex ⎕S'%')fn
          :EndIf
          :If ~0∊⍴_excludeRegex
              r←404×~0∊⍴(_excludeRegex ⎕S'%')fn
          :EndIf
      :EndIf
    ∇

    :class Request
        :Field Public Instance Boundary←''       ⍝ boundary for content-type 'multipart/form-data'
        :Field Public Instance Charset←''        ⍝ content charset (defaults to 'utf-8' if content-type is application/json)
        :Field Public Instance Complete←0        ⍝ do we have a complete request?
        :Field Public Instance ContentType←''    ⍝ content-type header value
        :Field Public Instance Cookies←0 2⍴⊂''   ⍝ cookie name/value pairs
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
          makeResponse
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
         
          Cookies←ParseCookies Headers
         
          makeResponse
         
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
         
          length←GetHeader'content-length'
          Complete←('get'≡Method)∧0=⊃⊃(//)⎕VFI length ⍝ we're a GET and there's no content-length or content-length=0
          Complete∨←(0∊⍴length)>∨/'chunked'⍷GetHeader'transfer-encoding' ⍝ or no length supplied and we're not chunked
        ∇

        ∇ makeResponse
        ⍝ create the response namespace
          Response←⎕NS''
          Response.(Status StatusText Payload)←200 'OK' ''
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

        ∇ name SetHeader value
          :Access Public Instance
          Response.Headers⍪←name value
        ∇

        ∇ name SetCookie cookie
          :Access public instance
        ⍝ create a response "set-cookie" header
        ⍝ cookie is the cookie value followed by any ;-delimited attributes
          'set-cookie'SetHeader name,'=',cookie
        ∇

        ∇ value←GetCookie name
          :Access public instance
        ⍝ retrieve a request cookie
          value←(Cookies[;1]⍳⊆,name)⊃Cookies[;2],⊂''
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
    ⍝???  req.SetStatus 204
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

    If←((0∘≠⊃)⊢)⍴⊣ ⍝ test for 0 return
    isChar←{0 2∊⍨10|⎕DR ⍵}
    stripQuotes←{'""'≡2↑¯1⌽⍵:¯1↓1↓⍵ ⋄ ⍵} ⍝ strip leading and ending "
    deb←{{1↓¯1↓⍵/⍨~'  '⍷⍵}' ',⍵,' '} ⍝ delete extraneous blanks
    dlb←{⍵↓⍨+/∧\' '=⍵} ⍝ delete leading blanks
    lc←0∘(819⌶) ⍝ lower case
    uc←1∘(819⌶) ⍝ upper case
    nameClass←{⎕NC⊂,'⍵'} ⍝ name class of argument
    nocase←{(lc ⍺)⍺⍺ lc ⍵} ⍝ case insensitive operator
    begins←{⍺≡(⍴⍺)↑⍵} ⍝ does ⍺ begin with ⍵?
    ends←{⍺≡(-≢⍺)↑⍵} ⍝ does ⍺ end with ⍵?
    match←{⍺ (≡nocase) ⍵} ⍝ case insensitive ≡
    sins←{0∊⍴⍺:⍵ ⋄ ⍺} ⍝ set if not set
    stopIf←{1∊⍵:-⎕TRAP←0 'C' '⎕←''Stopped for debugging... (Press Ctrl-Enter)''' ⋄ shy←0} ⍝ faster alternative to setting ⎕STOP

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

    ∇ r←InTerm;system
      :Access Public Shared
    ⍝ determine if interactive terminal is available
      →0⍴⍨r←~0∊⍴2 ⎕NQ'.' 'GetEnvironment' 'RIDE_INIT'
      →0⍴⍨r←'Win' 'Dev'≡system←3↑¨(⊂1 4)⌷'.'⎕WG'APLVersion'
      r←('Lin' 'Dev'≡system)∧{0::0 ⋄ 1⊣⎕SH'test -t 0'}''
    ∇

    ∇ r←fmtTS ts
      r←,'G⊂9999/99/99 @ 99:99:99⊃'⎕FMT 100⊥6↑ts
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
      r←{22::0 ⋄ 1=1 ⎕NINFO ⍵}path
    ∇

    ∇ r←SourceFile;class
      :If 0∊⍴r←4⊃5179⌶class←⊃∊⎕CLASS ⎕THIS
          r←{6::'' ⋄ ∊1 ⎕NPARTS ⍵⍎'SALT_Data.SourceFile'}class
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
      r←path∘,¨ref.⎕NL ¯3
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
⍝      ⍠
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
⍝        var resp = "<span style='color:red;'>" + this.statusText + "</span> <pre><code>" + this.responseText + "</code></pre>";
⍝      }
⍝      document.getElementById("result").innerHTML = resp;
⍝    }
⍝  }
⍝  xhttp.send(document.getElementById("payload").value);
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
      r←endpoints{i←⍵⍳'⍠' ⋄ ((i-1)↑⍵),⍺,i↓⍵}r
    ∇
    :EndSection

:EndClass
