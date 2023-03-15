 r←Authenticate req
 :If ∨/'nologinneeded'⍷req.Endpoint
     →r←0
 :EndIf
 :If ∨/'payloadcreds'⍷req.Endpoint
     →0⊣r←~('uid'≡req.Payload.UserID)∧'pwd'≡req.Payload.Password
 :EndIf
 r←~('uid'≡req.UserID)∧'pwd'≡req.Password
