:Class JarvisService :Jarvis
⍝∇:require =Jarvis
⍝∇:require =SysLog 
⍝    :field public Shared ServiceState
⍝    :field public Shared ServiceControl
    :field public log←⍬
    :field public ServiceName←''


    ∇ r←DefaultServiceName servicename
      :If 0∊⍴servicename
          r←2⊃⎕NPARTS ⎕WSID
      :Else
          r←servicename
      :EndIf
     
    ∇

    ∇ CreateSyslog servicename
      :Access shared public
      #.SysLog.CreateEventSource(DefaultServiceName servicename)'Dyalog APL'
    ∇


    ∇ make
      :Access public
      :Implements constructor :base
      Init
    ∇

    ∇ make1 arg
      :Access public
      :Implements constructor :base  arg
      Init
    ∇

    ∇ Init
      :Access public
      ServiceName←DefaultServiceName ServiceName
     
    ∇

    ∇ {r}←{level} Log msg
      :Access public override 
      :if 0=⎕nc 'level'
         level←'I'
      :endif
      :If log≡⍬
          log←⎕NEW #.SysLog ServiceName
      :EndIf
      :If Logging>0∊⍴msg
         level log.Write msg      ⍝ Add severity ??
      :EndIf 
      r← '(',('EWI'[1+3|¯1+(1 2 3 'EWIewi')⍳⊃level]),') ',msg
    ∇


    ∇ HashDefine
      :Access public shared
 ⍝ Service states are as follows:
      SERVICE_STOPPED←1
      SERVICE_START_PENDING←2
      SERVICE_STOP_PENDING←3
      SERVICE_RUNNING←4
      SERVICE_CONTINUE_PENDING←5
      SERVICE_PAUSE_PENDING←6
      SERVICE_PAUSED←7
     
 ⍝ Service Control Codes (actions) are as follows:
      SERVICE_CONTROL_STOP←1
      SERVICE_CONTROL_PAUSE←2
      SERVICE_CONTROL_CONTINUE←3
      SERVICE_CONTROL_INTERROGATE←4
      SERVICE_CONTROL_SHUTDOWN←5
      SERVICE_CONTROL_PARAMCHANGE←6
      SERVICE_CONTROL_NETBINDADD←7
      SERVICE_CONTROL_NETBINDREMOVE←8
      SERVICE_CONTROL_NETBINDENABLE←9
      SERVICE_CONTROL_NETBINDDISABLE←10
      SERVICE_CONTROL_DEVICEEVENT←11
      SERVICE_CONTROL_HARDWAREPROFILECHANGE←12
      SERVICE_CONTROL_POWEREVENT←13
      SERVICE_CONTROL_SESSIONCHANGE←14
      SERVICE_CONTROL_PRESHUTDOWN←15
     
    ∇


    ∇ r←ServiceHandler(obj event action state);sink
      :Access public shared
     
⍝ Callback to handle notifications from the SCM
     
⍝ Note that the interpreter has already responded
⍝ automatically to the SCM with the corresponding
⍝ "_PENDING" message prior to this callback being reached
     
⍝ This callback uses the SetServiceState Method to confirm
⍝ to the SCM that the requested state has been reached
     
      r←0  ⍝  so returns a 0 result (the event has been handled,
      ⍝ no further action required)
     
⍝ It stores the desired state in global ServiceState to
⍝ notify the application code which must take appropriate
⍝ action. In particular, it must respond to a "STOP or
⍝ "SHUTDOWN" by terminating the APL session
      :Select #.ServiceControl←action
      :CaseList SERVICE_CONTROL_STOP SERVICE_CONTROL_SHUTDOWN
          #.ServiceState←SERVICE_STOPPED
          state[4 5 6 7]←0
          ⎕← 'ServiceHandler Stop :',⍕#.ServiceControl
      :Case SERVICE_CONTROL_PAUSE
          #.ServiceState←SERVICE_PAUSED
          ⎕← 'ServiceHandler Pause :',⍕#.ServiceControl     
      :Case SERVICE_CONTROL_CONTINUE
          #.ServiceState←SERVICE_RUNNING 
         ⎕← 'ServiceHandler Continue :',⍕#.ServiceControl

      :Else                            
         ⎕← 'ServiceHandler:',⍕#.ServiceControl
          :If state[2]=SERVICE_START_PENDING
              #.ServiceState←SERVICE_RUNNING
          :EndIf
      :EndSelect 
      state[2]←#.ServiceState
      sink←2 ⎕NQ'.' 'SetServiceState'state
    ∇

    ∇ ServiceMain arg
      :Access public
      'I' Log 'ServiceMain Starting' 
      'I' Log 'ServiceMain: ',,⍕Start ⍝ Start Jarvis serice

      :While #.ServiceState≠SERVICE_STOPPED
          :If #.ServiceControl≠0 ⋄ 'I' Log 'ServiceControl=',⍕#.ServiceControl ⋄ :EndIf
     
          :Select #.ServiceControl
          :Case SERVICE_CONTROL_STOP
             'I' Log 'ServiceMain: ',,⍕Stop
          :Case SERVICE_CONTROL_PAUSE
              'I' Log 'ServiceMain: ',,⍕Pause
          :Case SERVICE_CONTROL_CONTINUE
              'I' Log 'ServiceMain: ',,⍕Start
          :Case SERVICE_CONTROL_INTERROGATE
          :Case SERVICE_CONTROL_SHUTDOWN
              'I' Log 'ServiceMain: ',,⍕Stop
          :Case SERVICE_CONTROL_PARAMCHANGE
          :Case SERVICE_CONTROL_NETBINDADD
          :Case SERVICE_CONTROL_NETBINDREMOVE
          :Case SERVICE_CONTROL_NETBINDENABLE
          :Case SERVICE_CONTROL_NETBINDDISABLE
          :Case SERVICE_CONTROL_DEVICEEVENT
          :Case SERVICE_CONTROL_HARDWAREPROFILECHANGE
          :Case SERVICE_CONTROL_POWEREVENT
          :Case SERVICE_CONTROL_SESSIONCHANGE
          :Case SERVICE_CONTROL_PRESHUTDOWN
              'I' Log 'ServiceMain: ',,⍕Stop
          :Case 0
     
          :EndSelect
     
          :Select #.ServiceState
          :Case SERVICE_STOPPED 
          :Case SERVICE_START_PENDING
          :Case SERVICE_STOP_PENDING
          :Case SERVICE_RUNNING
          :Case SERVICE_CONTINUE_PENDING
          :Case SERVICE_PAUSE_PENDING
          :Case SERVICE_PAUSED
          :EndSelect
          #.ServiceControl←0 ⍝ Reset (we only want to log changes)
          ⎕DL 10 ⍝ Just to prevent busy loop
      :EndWhile

      ⎕OFF 0
     
    ∇
    
   ∇r←ClassName
    :access public shared
    r←⍕⊃⊃⎕class ⎕this
    ∇

    ∇Describe;wsid;cmdlineargs;apl;service;a;s
    :access public shared
    ⎕←'This is intended to run as a service' 
    wsid←⎕wsid
    cmdlineargs←2 ⎕nq '.' 'GetCommandLineArgs'
    apl←⊃cmdlineargs
    service←2⊃⎕nparts wsid
    :for a :in cmdlineargs
      :if 0<≢s←'APL_ServiceEvtInit=' { ⍺≡(≢⍺)↑⍵:(≢⍺)↓⍵⋄''  } a
         #.SysLog.CreateEventSource  s 'Dyalog APL'
         ⎕← 'Event src created'
         ⎕off 0
      :endif
    :endfor

     ⎕←wsid
     ⎕←cmdlineargs
     ⎕←'To install/uninstall/initalize run as Administrator'
     ⎕←'CommandLines:'
     ⎕←apl,' ',wsid,' APL_ServiceInstall=',service,' ',2↓cmdlineargs
     ⎕←apl,' ',wsid,' APL_ServiceUninstall=',service,' ',2↓cmdlineargs 
     ⎕←apl,' ',wsid,' APL_ServiceEvtInit=',service  
    ∇

    ∇ StartService
       ⍝ This is the ⎕lx entry point to run Jarvis as a service 

      :Access public shared
⍝     ∘∘∘ ⍝ Remove comment to make service start wait for Ride Connection
      :If 'W'≠3⊃#.⎕WG'APLVersion'
          ⎕←'This workspace only works using Dyalog APL for Windows version 14.0 or later'
          :Return
      :EndIf
      :If 0∊⍴2 ⎕NQ'.' 'GetEnvironment' 'RunAsService'
          Describe
          :Return
      :EndIf

 ⍝ Define SCM constants
      HashDefine
 ⍝ Set up callback to handle SCM notifications
      '.'⎕WS'Event' 'ServiceNotification' (ClassName,'.ServiceHandler')
 ⍝ Global variable defines current state of the service
      #.ServiceState←SERVICE_RUNNING
 ⍝ Global variable defines last SCM notification to the service
      #.ServiceControl←0
 ⍝ Application code runs in a separate thread  
      js←⎕new JarvisService
      js.ConfigFile←#.Config
      js.CodeLocation←#.Code 
      js.ServiceMain&0
      ⎕DQ'.'
      ⎕OFF
    ∇

:EndClass
