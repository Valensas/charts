# OCR Viewer

A Helm chart for the session viewer of [Open Code Review](https://github.com/alibaba/open-code-review) (OCR).
`ocr viewer` serves the review sessions the `ocr` CLI wrote, so a review that ran on a laptop or in a CI job
can be read back by anyone.

Scanning is not part of this chart: `ocr review` and `ocr scan` run wherever the repo checkout is, so they
belong in a CI job.

## Installation

```bash
helm install ocr-viewer oci://ghcr.io/valensas/charts/ocr-viewer \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=ocr.example.com
```

Take a look at `values.yaml` for all available configuration options.

## Sessions

The viewer reads sessions from `$HOME/.opencodereview/sessions`, and `HOME` is `/data` in the image. Give the
chart a claim holding them and it is mounted read-only at that path:

```yaml
sessions:
  existingClaim: ocr-sessions
```

How the claim gets filled is outside this chart — a sync job, a shared filesystem, a CSI driver mounting the
bucket the uploads land in. The layout has to be one directory per repository, as the CLI writes it:

```
<claim root>/<repo>/<session files>
```

FUSE-backed claims want `sessions.mountPropagation: HostToContainer`, so the driver can replace a stale mount
without a pod restart. Without a claim the pod gets an emptyDir and the index stays empty.

## Notes

- **No authentication.** A session holds the reviewed source plus the LLM's analysis of it. Keep the ingress
  internal, or put something like [oauth2-proxy](https://github.com/oauth2-proxy/oauth2-proxy) in front.
- **The `Host` allowlist is default-deny**, to block DNS rebinding against the local CLI viewer. The chart
  fills `OCR_VIEWER_ALLOWED_HOSTS` from `ingress.hosts`; a host reaching the pod some other way needs
  `extraAllowedHosts` or it gets a `403 forbidden host` that reads like a broken backend.
- **Read-only is enough.** The viewer's HTTP surface is GET-only; marking a finding fixed or ignored is
  browser-side state.
- **The container runs as uid `65532`** and has to be able to read the session files. The CLI writes them
  `0600` locally and object storage does not carry those modes, so what the mount reports depends on whatever
  fills the claim.
- **Keep the image tag in step with the OCR version that wrote the sessions**; the CLI defines the format.
