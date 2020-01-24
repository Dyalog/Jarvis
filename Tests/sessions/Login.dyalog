 r←Login req
⍝ returns 1 if authentication succeeds
 r←0
 :Trap 6
     r←req.Payload.(UserID Password)≡'user' 'password'
 :EndTrap
