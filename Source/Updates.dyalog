 Updates;t;n;commits
 ⍝ check up to last 5 updates to repository
 :If 0=⎕NC'HttpCommand'
     ⎕SE.SALT.Load'HttpCommand'
 :EndIf
 :Trap 0
     t←HttpCommand.Get'http://api.github.com/repos/Dyalog/Jarvis/commits'
     n←5⌊≢commits←⎕JSON t.Data ⍝ last commit should be for this workspace
     ⎕←'The last ',(⍕n),' commits to repository http://github.com/Dyalog/DServer are:'
     ⎕←'Date' 'Description'⍪↑(n↑commits).commit.(author.date(↑message((~∊)⊆⊣)⎕UCS 13 10))
 :Else
     ⎕←'!! unable to check updates - ',⍕2↑⎕DM
 :EndTrap
