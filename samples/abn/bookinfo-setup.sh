#!/bin/sh

set -x

# Create namespace
kubectl apply -f https://raw.githubusercontent.com/iter8-tools/iter8-istio/master/docs/yamls/namespace.yaml

# Install bookinfo-app
kubectl -n bookinfo-iter8 apply \
  -f $ITER8_ISTIO/samples/bookinfo-tutorial.yaml \
  -f $ITER8_ISTIO/samples/abn/bookinfo-gateway.yaml

# Create productpage-v2, productpage-v3
kubectl -n bookinfo-iter8 apply -f https://raw.githubusercontent.com/iter8-tools/iter8-istio/master/docs/yamls/productpage-v2.yaml
kubectl -n bookinfo-iter8 apply -f https://raw.githubusercontent.com/iter8-tools/iter8-istio/master/docs/yamls/productpage-v3.yaml

echo "Verifying installation"
kubectl wait --for condition=ready --timeout=300s pods --all -n bookinfo-iter8

kubectl -n bookinfo-iter8 get sa,svc,deploy,po,vs,dr
