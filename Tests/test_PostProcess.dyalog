 r←test_PostProcess dummy;resp;ns;j
 r←''
 ns←⎕NS''
 j←ns.##.Jarvis.New 8080
 j.CodeLocation←ns
 j.PostProcessFn←'PostJSON'
 j.Paradigm←'JSON'
 ns.(Endpoint←{⎕NS''})
 ns.(PostJSON←{⍵.Response.Payload.Message←'hello stranger'})
 ns.(Get←{'hello'})
 ns.(PostREST←{⍵.Response.Payload,←' stranger'})
 :If 0≠⊃resp←j.Start
     →end⊣r←'test_PostProcess failed to start Jarvis for JSON test: ',⍕resp
 :EndIf
 resp←HttpCommand.GetJSON'post' 'localhost:8080/Endpoint'
 →stop↓0∊⍴r←{⍵.IsOK:'' ⋄ 'test_PostProcess (JSON) failed: ',⍕⍵}resp
 →stop↓0∊⍴r←{0::'test_PostProcess (JSON) response not correct' ⋄ _←÷⍵.Message≡'hello stranger'}resp.Data
 j.Stop
 j.Paradigm←'REST'
 j.PostProcessFn←'PostREST'
 j.DefaultContentType←'text/plain'
 :If 0≠⊃resp←j.Start
     →end⊣r←'test_PostProcess failed to start Jarvis for REST test: ',⍕resp
 :EndIf
 resp←HttpCommand.Get'localhost:8080'
 →stop↓0∊⍴r←{⍵.IsOK:'' ⋄ 'test_PostProcess (JSON) failed: ',⍕⍵}resp
 →stop↓0∊⍴r←{0::'test_PostProcess (REST) response not correct' ⋄ ''⊣÷⍵≡'hello stranger'}resp.Data
stop:j.Stop
end:⎕EX'ns'
