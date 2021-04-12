#!/bin/bash

echo "Setting up bookinfo application"

# Create bookinfo-iter8 namespace
kubectl apply -f https://raw.githubusercontent.com/iter8-tools/iter8-istio/master/docs/yamls/namespace.yaml

# Deploy application
kubectl -n bookinfo-iter8 apply -f $ITER8_ISTIO/samples/bookinfo-tutorial.yaml

# Deploy additional versions of productpage including Deployment and Service
# kubectl -n bookinfo-iter8 apply -f $ITER8_ISTIO/samples/productpage-v2.yaml
kubectl -n bookinfo-iter8 apply -f $ITER8_ISTIO/samples/productpage-v3.yaml

# Expose application configured to send traffic using services to distinguish between versions
kubectl -n bookinfo-iter8 apply -f $ITER8_ISTIO/samples/service-canary/bookinfo-gateway.yaml
