#!/bin/bash
set -e

NAMESPACE=argocd-system
CONTEXT=admin@oci
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

kubectl config use-context $CONTEXT

helm repo add argo-cd https://argoproj.github.io/argo-helm
helm install argo-cd argo-cd/argo-cd --namespace $NAMESPACE --create-namespace --values $SCRIPT_DIR/system/argo-cd/values.yaml --version 7.7.22

kubectl apply -f $SCRIPT_DIR/cluster.yaml
