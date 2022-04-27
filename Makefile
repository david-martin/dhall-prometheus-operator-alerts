alert-rules.yaml: alert-rules.dhall dhall/**/*.dhall
	dhall-to-yaml --generated-comment --file alert-rules.dhall --output alert-rules.yaml

alert-rules-cr.yaml: alert-rules.yaml alert-rules-cr.dhall
	dhall-to-yaml --generated-comment --file alert-rules-cr.dhall --output alert-rules-cr.yaml