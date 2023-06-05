# Bitcoin helm chart

This charts allows you to easily deploy a [Bitcoin](https://bitcoin.org/) node on Kubernetes.


## Installation

```bash
helm install oci://registry-1.docker.io/valensas/bitcoin
```

Take a look at `values.yaml` for all available configuration options. This chart can also be
used to deploy [Litecoin](https://litecoin.com) and [BitcoinCash](https://bitcoincash.org).
Take a look at `litecoin.yaml` and `bitcoincash.yaml` for examples.
