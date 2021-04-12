#!/bin/bash

minikube start --cpus 6 --memory 12288

$ITER8_ISTIO/samples/install-istio.sh

curl -s https://raw.githubusercontent.com/iter8-tools/iter8-install/main/install.sh | bash

curl -s https://raw.githubusercontent.com/iter8-tools/iter8-install/main/install-prom-add-on.sh | bash

kustomize build $ITER8_ISTIO/install/metrics | kubectl apply -f -
kustomize build $ITER8_ISTIO/install/rbac | kubectl apply -f -

kustomize build $ITER8_ISTIO/install/prometheus-add-on | kubectl apply -f -

kustomize build $ITER8_ISTIO/install/core | kubectl apply -f -
kubectl -n iter8-system delete po $(kubectl -n iter8-system get po --selector=control-plane=controller-manager -o jsonpath='{.items[0].metadata.name}')
kubectl wait --for condition=ready --timeout=300s pods --all -n iter8-system
