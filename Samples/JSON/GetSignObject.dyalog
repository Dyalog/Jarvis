 ns←GetSignObject ns
 ⍝ Return a sign object contain month, day (provided as input) and sign

 ns.sign←GetSign ns.(month day)
