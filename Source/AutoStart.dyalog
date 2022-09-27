 {ref}←AutoStart;empty;validParams;mask;values;params;param;value;rc;msg;getEnv;NoSession;ts;t;commits;n;debug;tonum;NoExit
⍝ Jarvis automatic startup
⍝ General logic:
⍝   Command line parameters take priority over configuration file which takes priority over default

 empty←0∊⍴
 tonum←{0∊⍴⍵:⍵ ⋄ ∧/⊃t←⎕VFI ⍵:⊃(⎕IO+1)⊃t ⋄ ⍵}
 getEnv←{tonum 2 ⎕NQ'.' 'GetEnvironment'⍵}

 ⍝↓↓↓ JarvisConfig MUST be first in validParams
 validParams←∪(⊂'JarvisConfig'),((⎕NEW #.Jarvis).Config)[;1]
 mask←~empty¨values←getEnv¨validParams
 params←mask⌿validParams,⍪values
 NoSession←~empty getEnv'NoSession'
 ref←'No server running'
 NoExit←NoSession∨'R'=3⊃#.⎕WG'APLVersion' ⍝ no session or runtime → don't exit

 :If ~empty params
     ref←⎕NEW #.Jarvis
     :For (param value) :In ↓params  ⍝ need to load one at a time because params can override what's in the configuration file
         param(ref{⍺⍺⍎⍺,'←⍵'})value
         :If 'JarvisConfig'≡param
             :If 0≠⊃(rc msg)←ref.LoadConfiguration value
                 →∆END⊣⎕←ref←'Error loading configuration file "',value,'": ',msg
             :EndIf
         :EndIf
     :EndFor

     :If 0≠⊃(rc msg)←ref.Start
         →∆END⊣⎕←ref←∊⍕'Unable to start server - ',msg
     :EndIf

     :If NoExit
         :Trap 0
             :While ref.Running
                 {}⎕DL 10
             :EndWhile
         :EndTrap
     :EndIf
 :EndIf
∆END:
 :If NoExit
     ⎕OFF
 :EndIf
