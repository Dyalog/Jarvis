  ∇ r←req Subtract arg
  ⍝ arg is an integer array
    req.Session.Sum-←+/arg
    r←req.Session.Sum
  ∇
