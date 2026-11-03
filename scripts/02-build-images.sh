#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

for svc in a b c; do
  echo "[+] docker build $svc:1.0"
  docker build -t "$svc:1.0" "./$svc"
done

if command -v k3s >/dev/null 2>&1 && sudo k3s kubectl get nodes >/dev/null 2>&1; then
  TMP=$(mktemp -d)
  trap 'rm -rf "$TMP"' EXIT
  for svc in a b c; do
    echo "[+] import $svc:1.0 dans k3s"
    docker save "$svc:1.0" -o "$TMP/$svc.tar"
    sudo k3s ctr images import "$TMP/$svc.tar"
  done
  sudo k3s ctr images ls | grep -E '^(docker\.io/library/)?[abc]:1\.0' || true
else
  echo "[!] k3s non détecté : images supposées disponibles via un registry local."
fi
