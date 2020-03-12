 r←Get req;parts
 parts←'/'(≠⊆⊢)req.Endpoint ⍝ split the endpoint
 r←''
 :Select ⊃parts
 :Case '' ⍝ dump the entire database
⍝ of course this wouldn't normally be in a real system
     (r←⎕NS''){⍺(⍵{⍺⍎⍺⍺,'←⍵'})req.Server.TableToNS Database⍎⍵}¨Database.⎕NL ¯2
 :Case 'Customers'
     r←req GetCustomers 1↓parts
 :Case 'Orders'
     r←req GetOrders 1↓parts
 :Case 'Products'
     r←req GetProducts 1↓parts
 :Else
     req.Fail 404
 :EndSelect
