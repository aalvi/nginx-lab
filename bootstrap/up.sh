#!/usr/bin/env bash
# Builds the lab: VM, k3s, Argo CD, then the root app. Argo CD deploys the rest from GitHub. Safe to re-run.
set -euo pipefail
cd "$(dirname "$0")/.."

ARGOCD_VERSION=v3.5.6

limactl list -q | grep -qx lab || limactl create --name=lab --tty=false bootstrap/lab.yaml
limactl start --tty=false lab 2>/dev/null || true

vm() { limactl shell --workdir / lab "$@"; }

vm bash -s < bootstrap/install-k3s.sh

vm kubectl create namespace argocd --dry-run=client -o yaml | vm kubectl apply -f -
vm kubectl apply -n argocd --server-side --force-conflicts \
  -f "https://raw.githubusercontent.com/argoproj/argo-cd/$ARGOCD_VERSION/manifests/install.yaml"
vm kubectl -n argocd rollout status deploy/argocd-server --timeout=5m
vm kubectl -n argocd rollout status statefulset/argocd-application-controller --timeout=5m

vm kubectl apply -f - < argocd/root-app.yaml
