:Namespace loans

    ∇ r←payment npr
    ⍝ npr - [1] principal, [2] rate %, [3] term in years
      r←{0::'Error' ⋄ p r n←⍵÷1 1200(÷12) ⋄ 0.01×⌈100×p×r÷1-(1+r)*-n}npr
    ∇

    ∇ r←afford_ns ns
    ⍝ returns array of what you can afford based on rates using a namespace 
    ⍝ ns.rates - vector of rates (%)
    ⍝ ns.terms - vector of terms in years
    ⍝ ns.payments - desired payment
      r←{0::'Error' ⋄ r n m←⍵÷1200(÷12)1 ⋄ 0.01×⌈100×m∘.÷r(÷⍤¯1)1-(1+r)∘.*-n}ns.(rates terms payments)
    ∇

    ∇ r←afford(rates terms payments)
    ⍝ returns array of what you can afford based on rates
    ⍝ rates - vector of rates (%)
    ⍝ terms - vector of terms in years
    ⍝ payments - desired payment
      r←{0::'Error' ⋄ r n m←⍵÷1200(÷12)1 ⋄ 0.01×⌈100×m∘.÷r(÷⍤¯1)1-(1+r)∘.*-n}rates terms payments
    ∇

  ⍝ the functions below exist solely as test cases for different function syntaxes to be called by _Run
  
    ∇ niladic
      ⎕←(⊃⎕XSI),' called'
    ∇

    ∇ r←niladic_result
      ⎕←(⊃⎕XSI),' called'
      r←'niladic_result result'
    ∇

    ∇ monadic rarg
      ⎕←(⊃⎕XSI),' called'
    ∇

    ∇ r←monadic_result rarg
      ⎕←(⊃⎕XSI),' called'
      r←'monadic_result result'
    ∇

    ∇ larg dyadic rarg
      ⎕←(⊃⎕XSI),' called'
    ∇

    ∇ r←larg dyadic_result rarg
      ⎕←(⊃⎕XSI),' called'
      r←'dyadic_result result'
    ∇

:EndNamespace
