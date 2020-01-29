 rc←Initialize;tn
 ⍝ Initialize the application by reading the "database" into the workspace
 tn←0 ⎕FSTIE⍨'Database',⍨⊃⎕NPARTS 4⊃5179⌶⊃⎕XSI
 Database←⎕NS ''
 Database.(Users Customers Orders Details Products)←⎕FREAD¨tn,¨2 3 4 5 6
 ⎕FUNTIE tn
 rc←0
