#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

if ! command -v helm >/dev/null 2>&1; then
  echo "[KO] helm non installé. https://helm.sh/docs/intro/install/" >&2
  exit 1
fi

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts >/dev/null
helm repo update >/dev/null

helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false

echo "[+] attente de la CRD ServiceMonitor (max 180s)"
for i in $(seq 1 60); do
  if kubectl get crd servicemonitors.monitoring.coreos.com >/dev/null 2>&1; then
    break
  fi
  sleep 3
done
kubectl wait --for=condition=Established crd/servicemonitors.monitoring.coreos.com --timeout=120s

echo "[+] application du ServiceMonitor"
kubectl apply -f k8s/07-servicemonitor.yaml

kubectl -n monitoring get pods
