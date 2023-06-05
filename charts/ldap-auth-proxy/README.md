# LDAP Auth Proxy

This chart installs [LDAP Auth Proxy](http://github.com/pinepain/ldap-auth-proxy). It enables Ingress resources to provide authentication using the [Nginx Auth Request Module](https://nginx.org/en/docs/http/ngx_http_auth_request_module.html). Therefore, it only works with [Ingress Nginx Controller](https://kubernetes.github.io/ingress-nginx/).

## Installation

```bash
helm install ldap-auth-proxy oci://ghcr.io/valensas/charts/ldap-auth-proxy \
  --set ldapServer=ldap.example.com \
  --set ldapBase=dc=example,dc=com \
  --set ldapGroupFilter=(&(objectClass=groupOfNames)(member=uid=%s,cn=users,dc=example,dc=com)) \
  --set ldapBindDn=uid=bind-user,cn=users,dc=example,dc=com \
  --set ldapBindPassword=superstrongpassword
```

Take a look at all configurations available in `values.yaml`.

## Protecting your Ingress

To authenticate your Ingress using LDAP, make sure to add proper annotations, here is an example:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
  annotations:
    # Set this to the ldap-auth-proxy url.
    nginx.ingress.kubernetes.io/auth-url: https://ldap-auth.example.com
    # By setting this, the `X-LDAP-UID` header will be exposed to your application.
    # Make sure it matches the values provided in `headersMap`. This is only required
    # if you would to access user/group attributes from your application.
    nginx.ingress.kubernetes.io/auth-response-headers: X-LDAP-UID
spec:
  rules:
    - host: example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: example
                port:
                  number: 8080

```