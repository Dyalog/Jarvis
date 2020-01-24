 r←setup dummy;home
⍝ Setup test
 ⎕IO←⎕ML←1
 r←''
 :Trap 0
     home←##.TESTSOURCE  ⍝ hopefully good enough...
     {}#.⎕FIX 'file://',home,'../Source/JSONServer.dyalog'
     {}⎕SE.SALT.Load 'HttpCommand'
 :Else
     r←,⍕⎕DM
 :EndTrap
