#!/bin/sh

set -x

# Create namespace
kubectl apply -f https://raw.githubusercontent.com/iter8-tools/iter8-istio/master/docs/yamls/namespace.yaml

# Install bookinfo-app (reviewsc-v2)
kubectl -n bookinfo-iter8 apply \
  -f https://raw.githubusercontent.com/iter8-tools/iter8-istio/master/docs/yamls/bookinfo-tutorial.yaml \
  -f https://raw.githubusercontent.com/iter8-tools/iter8-istio/master/docs/yamls/bookinfo-gateway.yaml

# Create destination rule, virtiual service
APPLICATION="reviews"
BASELINE_VERSION="v2"
CANDIDATE_VERSION="v3"
cat << EOF | kubectl apply -n bookinfo-iter8 -f -
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
    name: ${APPLICATION}
spec:
    host: ${APPLICATION}
    subsets:
    - name: ${APPLICATION}-${BASELINE_VERSION}
      labels:
        version: ${BASELINE_VERSION}
    - name: ${APPLICATION}-${CANDIDATE_VERSION}
      labels:
        version: ${CANDIDATE_VERSION}
---
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
    name: ${APPLICATION}
spec:
    hosts:
    - ${APPLICATION}
    http:
    - route:
        - destination:
            host: ${APPLICATION}
            subset: ${APPLICATION}-${BASELINE_VERSION}
          weight: 100
        - destination:
            host: ${APPLICATION}
            subset: ${APPLICATION}-${CANDIDATE_VERSION}
          weight: 0
EOF
kubectl -n bookinfo-iter8 get destinationrule -o yaml
kubectl -n bookinfo-iter8 get virtualservice -o yaml

# Create reviews-v3
kubectl -n bookinfo-iter8 apply -f https://raw.githubusercontent.com/iter8-tools/iter8-istio/master/docs/yamls/reviews-v3.yaml

echo "Verifying installation"
kubectl wait --for condition=ready --timeout=300s pods --all -n bookinfo-iter8

kubectl -n bookinfo-iter8 get sa,svc,deploy,po,vs,dr
# kubectl -n bookinfo-iter8 get destinationrule reviews -o yaml
# kubectl -n bookinfo-iter8 get virtualservice reviews -o yaml
