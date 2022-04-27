let TimeUnit = ./Type.dhall

let show
    : TimeUnit → Text
    = λ(tu : TimeUnit) → merge { Minutes = "m", Hours = "h", Days = "d" } tu

in  show
