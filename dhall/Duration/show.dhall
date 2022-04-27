let TimeUnit = ./../TimeUnit/package.dhall

let Duration = ./Type.dhall

let show
    : Duration → Text
    = λ(d : Duration) → "${Natural/show d.amount}${TimeUnit.show d.unit}"

let example =
      assert : show { amount = 10, unit = TimeUnit.Type.Minutes } ≡ "10m"

in  show
