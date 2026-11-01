#!/usr/bin/env bash
# Deletes the VM and everything in it. The desired state stays safe in GitHub.
set -euo pipefail
limactl delete -f lab
