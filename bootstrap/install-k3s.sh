#!/usr/bin/env bash
# Runs inside the VM. Traefik is off because NGINX is the ingress controller.
set -euo pipefail

K3S_VERSION=v1.37.1+k3s1

curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION="$K3S_VERSION" sh -s - \
  --disable traefik \
  --write-kubeconfig-mode 644
until kubectl wait --for=condition=Ready node --all --timeout=120s; do sleep 3; done
