:Class testClass

    :Field public field1
    :Field _prop1←'prop1 value'

    :Property prop1
    :Access public
        ∇ r←Get
          r←_prop1
        ∇

        ∇ Set arg
          _prop1←arg.NewValue
        ∇
    :EndProperty

    ∇ make
      :Access public
      :Implements constructor
      field1←'default'
    ∇

    ∇ make1 arg
      :Access public
      :Implements constructor
      field1←arg
    ∇

    ∇ niladic
      :Access public
    ∇

    ∇ r←niladic_result
      :Access public
      (r←⎕NS'').result←'Result from niladic_result'
    ∇

    ∇ monadic rarg
      :Access public
    ∇

    ∇ r←monadic_result rarg
      :Access public
      (r←⎕NS'').(result rarg)←'Result from monadic_result'rarg
    ∇

    ∇ larg dyadic rarg
      :Access public
    ∇

    ∇ r←larg dyadic_result rarg
      :Access public
      (r←⎕NS'').(result larg rarg)←'Result from dyadic_result'larg rarg
    ∇

:EndClass
