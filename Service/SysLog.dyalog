:Class SysLog
⍝ Implements simple interface to write events to system log files
⍝ Windows capability is implemented
⍝ *NIX will be added in the future

    ⎕IO←⎕ML←1

    :field Source←''    ⍝ Source is the name of the application
    :field Log←''       ⍝ Log is the name of the log (under Windows, it defaults to "Application")
    :field Machine←,'.' ⍝ means this local machine, could be another machine on the network
    :field eventlog


    isWin←'W'=1↑3⊃'.'⎕WG 'APLVersion'

    ∇ r←isAdmin
    ⍝ check is user if running as an administrator
      :Access public shared
      r←{0::0 ⋄ isWin:⍎⎕NA'I shell32|IsUserAnAdmin' ⋄ 0}''
    ∇

    ∇ SetUsing
      ⎕USING←'System' 'System.Diagnostics,system.dll'
    ∇

    ∇ Make source
      :Implements constructor
      :Access public
      'This utility runs only under Windows at this time'⎕SIGNAL 11/⍨~isWin
      ('Event source "',source,'" does not exist')⎕SIGNAL 6/⍨~EventSourceExists source
      Source←source
      eventlog←⎕NEW EventLog
      eventlog.Source←⊂,source
    ∇

    ∇ {level}Write message;type
      :Access public
      ⍝ message is message to write
      ⍝ level is one of: 1 'E' 'e' for error message
      ⍝                  2 'W' 'w' for warning message
      ⍝                  3 'I' 'i' for informational message (the default)
      level←{6::⍵ ⋄ level}3
      :If isWin
          type←(EventLogEntryType.(Error Warning Information))[1+3|¯1+(1 2 3, 'EWIewi')⍳⊃level]
          eventlog.WriteEntry(message type)
      :Else
          ∘∘∘
      :EndIf
    ∇
    ∇ {level}WriteLog(source message);type
      :Access public shared
      ⍝ message is message to write
      ⍝ level is one of: 1 'E' 'e' for error message
      ⍝                  2 'W' 'w' for warning message
      ⍝                  3 'I' 'i' for informational message (the default)
      level←{6::⍵ ⋄ level}3
      :If isWin
          SetUsing
          type←(EventLogEntryType.(Error Warning Information))[1+3|¯1+(1 2 3, 'EWIewi')⍳⊃level]
          EventLog.WriteEntry(source message type)
      :Else
          ∘∘∘
      :EndIf
    ∇


    ∇ r←EventSourceExists source
      :Access public shared
      :If isWin
          :Trap 90
              SetUsing
              r←EventLog.SourceExists⊂,source
          :Else
              r←0
          :EndTrap
      :Else
          ∘∘∘
      :EndIf
    ∇

    ∇ CreateEventSource args;log;source
      :Access public shared
      :If isWin
          'You must be running as an administrator to use this'⎕SIGNAL 11/⍨~isAdmin
          :If 1<|≡args
              source log←args
          :Else
              source←,args ⋄ log←''
          :EndIf
          ('Event source "',source,'" already exists')⎕SIGNAL 11/⍨EventSourceExists source
          EventLog.CreateEventSource(source log)
      :Else
          ∘∘∘
      :EndIf
    ∇

    ∇ DeleteLog log
      :Access public shared
      :If isWin
          'You must be running as an administrator to use this'⎕SIGNAL 11/⍨~isAdmin
          SetUsing
          EventLog.Delete⊂,log
      :Else
          ∘∘∘
      :EndIf
    ∇

    ∇ DeleteEventSource source
      :Access public shared
      :If isWin
          'You must be running as an administrator to use this'⎕SIGNAL 11/⍨~isAdmin
          ('Event source "',source,'" does not exist')⎕SIGNAL 6/⍨~EventSourceExists source
          EventLog.DeleteEventSource⊂source
      :Else
          ∘∘∘
      :EndIf
    ∇

    ∇ r←LogExists log
      :Access public shared
      :If isWin
          :Trap 0
              SetUsing
              EventLog.Exists⊂,log
          :Else
              r←0
          :EndTrap
      :Else
          ∘∘∘
      :EndIf
    ∇

    ∇ r←LogNameFromSourceName source
      :Access public shared
      :If isWin
          ('Event source "',source,'" does not exist')⎕SIGNAL 6/⍨~EventSourceExists source
          r←EventLog.LogNameFromSourceName(source(,'.'))
      :Else
          ∘∘∘
      :EndIf
    ∇
:EndClass
