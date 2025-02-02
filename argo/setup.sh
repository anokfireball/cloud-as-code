#!/bin/bash
set -e

NAMESPACE=argocd-system
CONTEXT=admin@oci
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ARGO_CHART_VERSION=$(grep 'targetRevision' $SCRIPT_DIR/system/argo-cd/argo-cd.yaml | awk '{print $2}' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$')
if [ -z "$ARGO_CHART_VERSION" ]; then
  echo "Error: Failed to retrieve Argo CD chart version."
  exit 1
fi

kubectl config use-context $CONTEXT

helm repo add argo-cd https://argoproj.github.io/argo-helm
helm install argo-cd argo-cd/argo-cd --namespace $NAMESPACE --create-namespace --values $SCRIPT_DIR/system/argo-cd/values.yaml --version $ARGO_CHART_VERSION

sops decrypt $SCRIPT_DIR/secrets/age-key.sops.yaml | kubectl apply -f -
kubectl apply -f $SCRIPT_DIR/secrets.yaml
kubectl apply -f $SCRIPT_DIR/cluster.yaml
