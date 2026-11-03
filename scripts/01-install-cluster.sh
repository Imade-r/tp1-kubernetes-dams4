#!/usr/bin/env bash
set -euo pipefail

if ! command -v k3s >/dev/null 2>&1; then
  echo "[+] installation de k3s..."
  curl -sfL https://get.k3s.io | sh -
else
  echo "[ok] k3s présent"
fi

mkdir -p "$HOME/.kube"
sudo cp /etc/rancher/k3s/k3s.yaml "$HOME/.kube/config"
sudo chown "$USER:$USER" "$HOME/.kube/config" 2>/dev/null || sudo chown "$USER" "$HOME/.kube/config"
chmod 600 "$HOME/.kube/config"

for i in $(seq 1 30); do
  if kubectl get nodes 2>/dev/null | grep -q ' Ready '; then
    echo "[ok] cluster prêt"
    kubectl get nodes
    exit 0
  fi
  sleep 2
done
echo "[KO] cluster pas Ready après 60s" >&2
kubectl get nodes || true
exit 1
