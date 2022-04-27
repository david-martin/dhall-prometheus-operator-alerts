let lowerASCII =
      https://prelude.dhall-lang.org/v21.1.0/Text/lowerASCII.dhall
        sha256:26b076651120b907e869396bd3dc16271f2e12433062b2f26f296968a69515e7

let AlertSeverity = ./Type.dhall

let show
    : AlertSeverity → Text
    = λ(s : AlertSeverity) → lowerASCII (showConstructor s)

in  show
