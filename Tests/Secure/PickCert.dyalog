 r←PickCert store;certs
 r←⍬
 :If 0∊⍴store ⋄ store←'My' ⋄ :EndIf
 :If 'W'=⊃3⊃#.⎕WG'APLVersion'
     :If ~0∊⍴certs←#.DRC.X509Cert.ReadCertFromStore'My'
         ⎕←'Select a certificate:'
         ⎕←(⍳≢certs),⍪certs.Formatted.Subject
         :Trap 0
             r←⎕⊃certs
         :Else
             ⎕←'No certificate selected'
         :EndTrap
     :Else
         ⎕←'No certificates in your Windows certificate store'
     :EndIf
 :Else
     ⎕←'This can run on Windows only.'
 :EndIf
