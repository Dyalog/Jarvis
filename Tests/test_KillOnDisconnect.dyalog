 r←test_KillOnDisconnect;threads;j;h
 j←Jarvis.New''
 ⎕FX'∇r←req killMe payload' 'req.KillOnDisconnect←1' 'r←⎕DL 30' '∇'
 ⎕FX'∇r←req doNotKillMe payload' 'r←⎕DL 30' '∇'
 j.Start
 h←HttpCommand.New'post'
 h.Params←''
 h.BaseURL←'localhost:',⍕j.Port
 h.ContentType←'application/json'
 h.Timeout←5
 h.URL←'killMe'
 h.Run
 ⎕DL 5
 threads←≢⎕TNUMS
 h.URL←'doNotKillMe'
 h.Run
 ⎕DL 5
 threads,←≢⎕TNUMS
 j.Stop
 ⎕EX'killMe' 'doNotKillMe'
 r←(>/threads)/
