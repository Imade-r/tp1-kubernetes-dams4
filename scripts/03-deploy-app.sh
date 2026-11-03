#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

for f in 00-namespace 01-config 02-storage 03-services 04-deployments 05-ingress 06-hpa; do
  echo "[+] apply k8s/$f.yaml"
  kubectl apply -f "k8s/$f.yaml"
done

echo "[+] attente des pods (max 180s)"
if ! kubectl -n chaine-tp wait --for=condition=ready pod --all --timeout=180s; then
  echo "[KO] pods pas tous Ready :" >&2
  kubectl -n chaine-tp get pods >&2
  kubectl -n chaine-tp describe pods >&2 | tail -n 100
  exit 1
fi

kubectl -n chaine-tp get pods
kubectl -n chaine-tp get svc,ingress,hpa
