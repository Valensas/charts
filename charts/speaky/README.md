# Speaky

A Helm chart for Speaky, a notification gateway to send emails trough [SMTP](https://en.wikipedia.org/wiki/Simple_Mail_Transfer_Protocol), SMS trough [Posta Güvercini](https://www.postaguvercini.com) and Push notifications trough [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging/).

## Installation

```bash
helm install speaky oci://ghcr.io/valensas/charts/speaky
```

Take a look at `values.yaml` for all available configuration options.

## OpenTelemetry

OpenTelemetry is disabled by default. When enabled, the OTel settings are rendered into a ConfigMap (`<release>-speaky-otel`) and injected into the container as environment variables. `otel.exporterOtlpEndpoint` has no default and must be provided:

```yaml
otel:
  enabled: true
  exporterOtlpEndpoint: "http://<collector-host>:4317"
```

All other settings (`tracesExporter`, `metricsExporter`, `logsExporter`, `exporterOtlpProtocol`, `tracesSampler`, `tracesSamplerArg`, `resourceAttributes`, `propagators`, `sdkDisabled`) have sensible defaults — see `values.yaml`. Values are rendered as Helm templates, so release context such as `{{ .Release.Namespace }}` is available.