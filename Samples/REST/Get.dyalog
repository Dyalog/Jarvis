 r←Get req;parts
 parts←'/'(≠⊆⊢)req.Endpoint ⍝ split the endpoint
 :Select ⊃parts
 :Case 'Customers'
     r←req GetCustomer 1↓parts
 :Case 'Orders'
     r←req GetOrders 1↓parts
 :Case 'Products'
     r←req GetProducts 1↓parts
 :Else
     req.Fail 404
 :EndSelect
