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



#### set up RBAC rules allowing controller and handler to work with ISTIO resources
# controller role needs permissiom to read/write vs, dr
# handler role needs permission to read/write vs,dr

cat << EOF | kubectl apply -f -
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: iter8-istio
  namespace: bookinfo-iter8
rules:
- apiGroups:
  - networking.istio.io
  resources:
  - virtualservices
  verbs:
  - get
  - list
  - create
  - patch
  - update
  - watch
- apiGroups:
  - networking.istio.io
  resources:
  - destinationrules
  verbs:
  - get
  - list
  - create
  - patch
  - update
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: iter8-istio
  namespace: bookinfo-iter8
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: iter8-istio
subjects:
- kind: ServiceAccount
  name: iter8-controller
  namespace: iter8-system
- kind: ServiceAccount
  name: iter8-handlers
  namespace: iter8-system
EOF
