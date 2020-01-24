:Class loansclass

    :field public rates←5 6
    :field public terms←10 15 20 30
    :field public principals←100000 150000 200000

    ∇ make
      :Access public
      :Implements constructor
    ∇

    ∇ make1 ns;name
      :Access public
      :Implements constructor
      :For name :In ns.⎕NL ¯2
          :Select name
          :Case 'rates'
              rates←ns.rates
          :Case 'terms'
              terms←ns.rates
          :Case 'principals'
              principals←ns.rates
          :EndSelect
      :EndFor
    ∇

    ∇ r←payments
      :Access public
    ⍝ return array of payments for principals ∘. rates ∘. terms
      r←{0::'Error' ⋄ p r n←⍵÷1 1200(÷12) ⋄ 0.01×⌈100×p∘.×r(÷⍤¯1)1-(1+r)∘.*-n}principals rates terms
    ∇

⍝ the methods below exist to be able to test the ability to execute methods of any syntax using _Run

    ∇ niladic
      :Access public
      ⎕←(⊃⎕XSI),' called'
    ∇

    ∇ r←niladic_result
      :Access public
      ⎕←(⊃⎕XSI),' called'
      r←'niladic_result result'
    ∇

    ∇ monadic rarg
      :Access public
      ⎕←(⊃⎕XSI),' called'
    ∇

    ∇ r←monadic_result rarg
      :Access public
      ⎕←(⊃⎕XSI),' called'
      r←'monadic_result result'
    ∇

    ∇ larg dyadic rarg
      :Access public
      ⎕←(⊃⎕XSI),' called'
    ∇

    ∇ r←larg dyadic_result rarg
      :Access public
      ⎕←(⊃⎕XSI),' called'
      r←'dyadic_result result'
    ∇

:EndClass
