# PgHero

This charts allows you to easily deploy [PgHerp](https://github.com/ankane/pghero) node on Kubernetes to monitor your Postgresql databases.

## Installation

```bash
helm install oci://ghcr.io/valensas/charts/pghero \
  --set config.databases.mydb.url=postgres://username:password@postgres-host:5432/postgres-db
```

