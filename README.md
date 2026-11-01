# nginx-lab

A local Kubernetes lab deployed by GitOps. The NGINX Ingress Controller routes traffic to two sample apps, NGINX Gateway Fabric routes traffic to two more, and Argo CD deploys everything from this repo.

```text
Mac:        VS Code + git  --push-->  GitHub (PR checks run in GitHub Actions)
                                        |
Ubuntu VM:  k3s + Argo CD  <--pull------+
                 |
                 +--> NGINX Ingress Controller --> app1, app2
                 +--> NGINX Gateway Fabric ------> app3, app4

Mac browser: http://app1.localhost:8080, http://app2.localhost:8080
             http://app3.localhost:8082, http://app4.localhost:8082
```

## Requirements

- An Intel Mac on macOS 13 or later, with 8 GB of RAM to spare for the VM. Other setups may need the download names in `bootstrap/install-tools.sh` and `vmType` in `bootstrap/lab.yaml` changed.
- `~/.local/bin` on your `PATH`.

## Usage

```bash
bootstrap/install-tools.sh   # Lima and gh, no sudo needed
bootstrap/up.sh              # VM, k3s, Argo CD and the root app
tests/routing-test.sh        # checks routing from the Mac
limactl stop lab             # frees the VM's CPU and RAM
limactl start lab            # brings it back
bootstrap/down.sh            # deletes the VM
```

## Making a change

1. Create a branch and edit a manifest in `apps/`, `gateway-apps/` or `argocd/apps/`.
2. Open a pull request. The `validate` check must pass.
3. Merge. Argo CD syncs within about 3 minutes.
4. To roll back, revert the commit.

Argo CD reverts manual cluster changes. Pause auto-sync on an app before experimenting with `kubectl`.

This repo is public, so never commit credentials.

## Argo CD UI

```bash
limactl shell lab kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo
limactl shell lab kubectl -n argocd port-forward svc/argocd-server 8081:443
```

Then open https://localhost:8081 and sign in as `admin`. The certificate is self-signed.

## Layout

| Path | Purpose |
|---|---|
| `bootstrap/` | The only parts run by hand |
| `argocd/root-app.yaml` | App of apps, points Argo CD at `argocd/apps` |
| `argocd/apps/` | Controller charts, Gateway API CRDs and sample apps as Argo CD applications |
| `apps/` | app1 and app2 with their Ingress, routed by the NGINX Ingress Controller |
| `gateway-apps/` | app3 and app4 with their Gateway and HTTPRoutes, routed by NGINX Gateway Fabric |
| `tests/` | Routing test, run from the Mac |
| `.github/workflows/` | Pull request checks |

## Keep the VM on Ubuntu 24.04

Lima's `vz` driver on an Intel Mac needs macOS 15.5 or later to run Linux 6.12 or newer. On older macOS, don't upgrade the VM to a newer Ubuntu release or install an HWE kernel, because it may stop booting.

## Controller note

This lab uses `nginx/kubernetes-ingress` because the community `kubernetes/ingress-nginx` project is archived. Annotations use the `nginx.org/` prefix, not `nginx.ingress.kubernetes.io/`.
