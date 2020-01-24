 TestSecure pathToJSONServer
 :If 0=⎕NC'JSONServer'
     ⎕SE.SALT.Load pathToJSONServer,'/Source/JSONServer.dyalog'
 :EndIf
 ⎕SE.SALT.Load pathToJSONServer,'/Sample/GetSign*.dyalog'
 js←⎕NEW JSONServer
 dyalog←2 ⎕NQ'.' 'GetEnvironment' 'Dyalog'
 js.Secure←1
 js.SSLValidation←64 ⍝ request, but do not require a certificate
 js.RootCertDir←dyalog,'\TestCertificates\Ca\'
 js.ServerCertFile←dyalog,'\TestCertificates\Server\localhost-cert.pem'
 js.ServerKeyFile←dyalog,'\TestCertificates\Server\localhost-key.pem'
 ⎕FX↑'r←ValidateRequest req' 'r←0' ':if ~0∊⍴req.PeerCert ⋄ ''Subject'' ''Valid From'' ''Valid To'',⍪⊃req.PeerCert.Formatted.(Subject ValidFrom ValidTo) ⋄ :EndIf '
 js.Start
 ⎕←(⎕UCS 13),'⍝ To test using HttpCommand:'
 ⎕←'⍝ Make sure you have HttpCommand.Version 2.1.17 or later.'
 ⎕←'      d←2 ⎕NQ ''.'' ''GetEnvironment'' ''dyalog'''
 ⎕←'      key←d,''/TestCertificates/client/John Doe-key.pem'''
 ⎕←'      cert←d,''/TestCertificates/client/John Doe-cert.pem'''
 ⎕←'      r←HttpCommand.GetJSON''post'' ''localhost:8080/GetSign''(2,23)''''(cert key)'
