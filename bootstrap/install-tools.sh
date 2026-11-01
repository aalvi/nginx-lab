#!/usr/bin/env bash
# Installs Lima and the GitHub CLI into ~/.local on an Intel Mac. Needs no sudo.
set -euo pipefail

LIMA_VERSION=2.2.1
GH_VERSION=2.103.3

tmp=$(mktemp -d)
mkdir -p ~/.local/bin

fetch() { # base url, file, checksum file: download and verify
  curl -fsSL -o "$tmp/$2" "$1/$2"
  grep " \*\?$2\$" "$tmp/$3" | (cd "$tmp" && shasum -a 256 -c -)
}

if ! ~/.local/bin/limactl --version 2>/dev/null | grep -q " $LIMA_VERSION\$"; then
  base=https://github.com/lima-vm/lima/releases/download/v$LIMA_VERSION
  curl -fsSL -o "$tmp/lima.sums" "$base/SHA256SUMS"
  fetch "$base" "lima-$LIMA_VERSION-Darwin-x86_64.tar.gz" lima.sums
  tar xzf "$tmp/lima-$LIMA_VERSION-Darwin-x86_64.tar.gz" -C ~/.local
fi

base=https://github.com/cli/cli/releases/download/v$GH_VERSION
curl -fsSL -o "$tmp/gh.sums" "$base/gh_${GH_VERSION}_checksums.txt"
fetch "$base" "gh_${GH_VERSION}_macOS_amd64.zip" gh.sums
unzip -q "$tmp/gh_${GH_VERSION}_macOS_amd64.zip" -d "$tmp"
cp "$tmp/gh_${GH_VERSION}_macOS_amd64/bin/gh" ~/.local/bin/gh

echo "Installed to ~/.local/bin. Make sure it is on your PATH."
