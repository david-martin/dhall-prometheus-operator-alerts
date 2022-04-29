let Prelude =
      https://prelude.dhall-lang.org/v21.1.0/package.dhall
        sha256:0fed19a88330e9a8a3fbe1e8442aa11d12e38da51eb12ba8bcb56f3c25d0854a

let K8s =
      https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/v6.0.0/package.dhall
        sha256:532e110f424ea8a9f960a13b2ca54779ddcac5d5aa531f86d82f41f8f18d7ef1

let PrometheusOperator =
      ( https://raw.githubusercontent.com/coralogix/dhall-prometheus-operator/v8.0.0/package.dhall
          sha256:ebc5f0c5f57d410412c2b7cbb64d0883be648eafc094f0c3e10dba4e6bd46ed4
      ).v1

let TimeUnit = ./dhall/TimeUnit/package.dhall

let Duration = ./dhall/Duration/package.dhall

let AlertSeverity = ./dhall/AlertSeverity/package.dhall

let AlertProperties = ./dhall/AlertProperties/package.dhall

let metric = "http_requests_total"
let metricLabels = "job=\"prometheus\""
let metricLabelsErrors = "code=~\"5..\""
let sloTarget = 0.999
let runbookUrl = "http://example.com/error_budget_burn.md"

let alertProperties =
      [ AlertProperties::{
        , burnRate = 13.44
        , shortDuration = { amount = 5, unit = TimeUnit.Type.Minutes }
        , longDuration = { amount = 1, unit = TimeUnit.Type.Hours }
        , percentBurn = 2.0
        , for = { amount = 2, unit = TimeUnit.Type.Minutes }
        , severity = AlertSeverity.Type.Critical
        }
      , {
        , burnRate = 5.6
        , shortDuration = { amount = 30, unit = TimeUnit.Type.Minutes }
        , longDuration = { amount = 6, unit = TimeUnit.Type.Hours }
        , percentBurn = 5.0
        , for = { amount = 15, unit = TimeUnit.Type.Minutes }
        , severity = AlertSeverity.Type.Critical
        }
      , {
        , burnRate = 2.8
        , shortDuration = { amount = 2, unit = TimeUnit.Type.Hours }
        , longDuration = { amount = 1, unit = TimeUnit.Type.Days }
        , percentBurn = 10.0
        , for = { amount = 1, unit = TimeUnit.Type.Hours }
        , severity = AlertSeverity.Type.Warning
        }
      , {
        , burnRate = 0.93
        , shortDuration = { amount = 6, unit = TimeUnit.Type.Hours }
        , longDuration = { amount = 3, unit = TimeUnit.Type.Days }
        , percentBurn = 10.0
        , for = { amount = 3, unit = TimeUnit.Type.Hours }
        , severity = AlertSeverity.Type.Warning
        }
      ]
let labelsFrom =
      λ(ap : AlertProperties.Type) →
        Some (toMap { severity = AlertSeverity.show ap.severity })

let alertRuleExprFrom =
      λ(ap : AlertProperties.Type) →
        ''
        sum(${metric}:burnrate${Duration.show
                                  ap.shortDuration}{${metricLabels}}) > (${Double/show
                                                                               ap.burnRate} * (1-${Double/show
                                                                                                     sloTarget}))
        and
        sum(${metric}:burnrate${Duration.show
                                  ap.longDuration}{${metricLabels}}) > (${Double/show
                                                                              ap.burnRate} * (1-${Double/show
                                                                                                    sloTarget}))
        ''

let makeAlertRules =
      λ(aps : List AlertProperties.Type) →
        Prelude.List.map
          AlertProperties.Type
          PrometheusOperator.Rule.Type
          ( λ(ap : AlertProperties.Type) →
              PrometheusOperator.Rule::{
              , alert = Some
                  (     "SLO-${metric}-ErrorBudgetBurn-"
                    ++  Duration.show ap.shortDuration
                    ++  Duration.show ap.longDuration
                  )
              , expr = K8s.IntOrString.String (alertRuleExprFrom ap)
              , labels = labelsFrom ap
              , for = Some (Duration.show ap.for)
              , annotations = Some (toMap {
                    runbook_url = runbookUrl
                  , summary = "At least ${Double/show ap.percentBurn}% of the SLO error budget has been consumed over the past ${Duration.show ap.shortDuration} and ${Duration.show ap.longDuration} windows"
                  , description = "High error budget burn in namespace {{ $labels.namespace }} (current value: {{ $value }}). Check the runbook for how to resolve this."
                })
              }
          )
          aps

let recordingRuleExprFrom =
      λ(duration : Duration.Type) →
        ''
        sum(rate(${metric}{${metricLabels},${metricLabelsErrors}}[${Duration.show duration}]))
        /
        sum(rate(${metric}{${metricLabels}}[${Duration.show duration}]))
        ''

let makeRecordingRule =
      λ(duration : Duration.Type) →
        PrometheusOperator.Rule::{
          , expr = K8s.IntOrString.String (recordingRuleExprFrom duration)
          , record = Some "${metric}:burnrate${Duration.show duration}"
          }

let makeShortDurationRecordingRules =
      λ(aps : List AlertProperties.Type) →
        Prelude.List.map
          AlertProperties.Type
          PrometheusOperator.Rule.Type
          ( λ(ap : AlertProperties.Type) →
              makeRecordingRule ap.shortDuration
          )
          aps

let makeLongDurationRecordingRules =
      λ(aps : List AlertProperties.Type) →
        Prelude.List.map
          AlertProperties.Type
          PrometheusOperator.Rule.Type
          ( λ(ap : AlertProperties.Type) →
              makeRecordingRule ap.longDuration
          )
          aps

in  PrometheusOperator.PrometheusRuleSpec::{
      , groups =
        [ PrometheusOperator.RuleGroup::{
          , name = "SLO-${metric}"
          , rules = Some (
              (makeAlertRules alertProperties)
            # (makeShortDurationRecordingRules alertProperties)
            # (makeLongDurationRecordingRules alertProperties)
            )
          }
        ]
      }
    
