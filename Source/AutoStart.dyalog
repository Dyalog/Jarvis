 {ref}←AutoStart;empty;validParams;mask;values;params;param;value;rc;msg;getEnv;NoSession;ts;t;commits;n;debug;tonum
⍝ Jarvis automatic startup
⍝ General logic:
⍝   Command line parameters take priority over configuration file which takes priority over default

 empty←0∊⍴
 tonum←{0∊⍴⍵:⍵ ⋄ ∧/⊃t←⎕VFI ⍵:⊃(⎕IO+1)⊃t ⋄ ⍵}
 getEnv←{tonum 2 ⎕NQ'.' 'GetEnvironment'⍵}

 ⍝↓↓↓ ConfigFile MUST be first in validParams
 validParams←∪(⊂'ConfigFile'),((⎕NEW #.Jarvis).Config)[;1]
 mask←~empty¨values←getEnv¨validParams
 params←mask⌿validParams,⍪values
 NoSession←~empty getEnv'NoSession'
 ref←'No server running'

 :If ~empty params
     ref←⎕NEW #.Jarvis
     :For (param value) :In ↓params  ⍝ need to load one at a time because params can override what's in the configuration file
         param(ref{⍺⍺⍎⍺,'←⍵'})value
         :If 'ConfigFile'≡param
             :If 0≠⊃(rc msg)←ref.LoadConfiguration value
                 →0⊣ref←'Error loading configuration file "',value,'": ',msg
             :EndIf
         :EndIf
     :EndFor

     :If 0≠⊃(rc msg)←ref.Start
         (∊⍕'Unable to start server - ',msg)⎕SIGNAL 16
     :EndIf

     :If NoSession∨'R'=3⊃#.⎕WG'APLVersion' ⍝ no session or runtime?
         :Trap 0
             :While ref.Running
                 {}⎕DL 10
             :EndWhile
         :EndTrap
         ⎕OFF
     :EndIf
 :EndIf
