# Atlas

A Helm chart for Atlas, an implementation to lookup self-hosted [ip2location](https://www.ip2location.com) data.

## Installation

```bash
helm install atlas oci://ghcr.io/valensas/charts/atlas --set database.host=<database-ip> --set database.user=<database-user> --set database.password=<database-password> --set ip2location.token=<ip2location-token>
```

Take a look at `values.yaml` for all available configuration options.