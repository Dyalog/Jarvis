 (rc msg)←test_sessions;l;path
 :If '⍝∇⍣§'≡4↑l←⊃⊢/⎕NR'test_sessions'
     path←⊃1 ⎕NPARTS 2⊃'§'(≠⊆⊢)l
     ⎕SE.SALT.Load path,'../Source/DServer.dyalog'
     ⎕SE.SALT.Load'HttpCommand'
     HttpCommand.Upgrade
     ds←⎕NEW DServer
     ds.CodeLocation←path,'sessions/'
     ds.SessionInitFn←'InitializeSession'
     ds.AuthenticateFn←'Login'
     ds.Paradigm←'REST'
     ds.Debug←2
     ds.(SessionTimeout SessionPollingTime SessionCleanupTime)←30 0.5 5
     :If 0=⊃(rc msg)←ds.Start
         c←⎕NEW HttpCommand
         c.URL←'localhost:8080/Login'
         'content-type'c.SetHeader'application/json'
         c.Params←{t←⎕NS'' ⋄ t⊣t.(UserID Password)←⍵}'user' 'password'
         c.WaitTime←600
         c.Command←'post'
         r←c.Run
         ∘∘∘
     :EndIf

 :Else
     (rc msg)←¯1 'No SALT source file information found!'
 :EndIf
