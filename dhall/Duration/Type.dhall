let TimeUnit = ./../TimeUnit/package.dhall

let Duration
    : Type
    = { amount : Natural, unit : TimeUnit.Type }

in  Duration
