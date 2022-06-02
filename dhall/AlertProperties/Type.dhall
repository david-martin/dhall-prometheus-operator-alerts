let Duration = ./../Duration/package.dhall

let AlertSeverity = ./../AlertSeverity/package.dhall

let AlertProperties
    : Type
    = { 
      , {- burnRate = (num hours in SLO time window) / (num hours in alert long window) * (% error budget consumed threshold) -}
        burnRate : Double
      , longDuration : Duration.Type
      , shortDuration : Duration.Type
      , for : Duration.Type
      , severity : AlertSeverity.Type
      , percentBurn : Double
      }

in  AlertProperties