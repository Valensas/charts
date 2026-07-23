# Atlas

A Helm chart for Atlas, an implementation to lookup self-hosted [ip2location](https://www.ip2location.com) data.

## Installation

```bash
helm install atlas oci://ghcr.io/valensas/charts/atlas --set database.host=<database-ip> --set database.user=<database-user> --set database.password=<database-password> --set ip2location.token=<ip2location-token>
```

Take a look at `values.yaml` for all available configuration options.

## OpenTelemetry

OpenTelemetry is disabled by default. When enabled, the OTel settings are rendered into a ConfigMap (`<release>-atlas-config`) and injected into the application and update-job containers as environment variables. `otel.exporterOtlpEndpoint` has no default and must be provided:

```yaml
otel:
  enabled: true
  exporterOtlpEndpoint: "http://<collector-host>:4317"
```

All other settings (`tracesExporter`, `metricsExporter`, `logsExporter`, `exporterOtlpProtocol`, `tracesSampler`, `tracesSamplerArg`, `resourceAttributes`, `propagators`, `sdkDisabled`) have sensible defaults — see `values.yaml`. Values are rendered as Helm templates, so release context such as `{{ .Release.Namespace }}` is available.