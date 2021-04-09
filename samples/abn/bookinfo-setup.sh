#!/bin/sh

set -x

# Create namespace
kubectl apply -f https://raw.githubusercontent.com/iter8-tools/iter8-istio/master/docs/yamls/namespace.yaml

# Install bookinfo-app (reviewsc-v2)
kubectl -n bookinfo-iter8 apply \
  -f https://raw.githubusercontent.com/iter8-tools/iter8-istio/master/docs/yamls/bookinfo-tutorial.yaml \
  -f https://raw.githubusercontent.com/iter8-tools/iter8-istio/master/docs/yamls/bookinfo-gateway.yaml

# Create productpage-v2, productpage-v3
kubectl -n bookinfo-iter8 apply -f https://raw.githubusercontent.com/iter8-tools/iter8-istio/master/docs/yamls/productpage-v2.yaml
kubectl -n bookinfo-iter8 apply -f https://raw.githubusercontent.com/iter8-tools/iter8-istio/master/docs/yamls/productpage-v3.yaml

echo "Verifying installation"
kubectl wait --for condition=ready --timeout=300s pods --all -n bookinfo-iter8

kubectl -n bookinfo-iter8 get sa,svc,deploy,po,vs,dr
