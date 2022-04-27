# dhall-prometheus-operator-alerts

## Prerequisites

* [Dhall](https://docs.dhall-lang.org/tutorials/Getting-started_Generate-JSON-or-YAML.html#installation)

## Generating files

Generate the prometheus rules file with:

```bash
make alert-rules.yaml
```

Generate the PrometheusRules CustomResource with:

```bash
make alert-rules-cr.yaml
```
