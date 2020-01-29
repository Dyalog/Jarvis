 r←Authenticate req;ind
 ⍝ simple authentication
 →0↓⍨r←(≢Database.Users)≥ind←Database.Users[;1]⍳⊆req.UserID ⍝ look up user ID
 r←Database.Users[ind;2]≡⊆req.Password
 req.Role←⊃Database.Users[ind;3]
