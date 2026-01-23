#!/bin/bash

set -e

source functions.source

print_header "Stage 2: Default Network Policiy on Namespace - Test"

print_info "This script will test a default Network Policy applied to a Namespace."

FRONTENDPOD=frontend
EXTERNALPOD=external

if [ "$1" == "clean" ]; then
  print_step "Cleaning up things..."
  kubectl delete --wait clusterpolicies add-namespace-name-label add-default-deny
  kubectl delete --wait namespace backend frontend external
  print_header "Cleanup complete."
  exit 0
fi

print_step "Prerequisites"

check_kyverno

print_success "Prerequisites check passed"

print_step "Preparation"

print_info "Creating two Cluster Policies: add-namespace-name-label and add-default-deny..."
kubectl create -f - <<EOF
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: add-namespace-name-label
spec:
  rules:
  - name: add-namespace-name-label
    match:
      resources:
        kinds:
        - Namespace
    mutate:
      patchStrategicMerge:
        metadata:
          labels:
            name: "{{request.object.metadata.name}}"
---
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: add-default-deny
spec:
  rules:
  - name: add-default-deny
    match:
      resources:
        kinds:
        - Namespace
    generate:
      apiVersion: networking.k8s.io/v1
      kind: NetworkPolicy
      name: default-deny-all
      namespace: "{{request.object.metadata.name}}"
      synchronize: true
      data:
        spec:
          podSelector: {}
          policyTypes:
          - Ingress
          - Egress
EOF
print_success "Cluster Policies created."

print_info "Creating namespaces..."
kubectl create namespace backend
kubectl create namespace frontend
kubectl create namespace external
print_success "Namespaces created."

print_info "Creating backend deployment..."
kubectl --namespace backend create deployment backend  --image nginx:latest
kubectl wait --namespace backend --for=condition=ready pod --selector=app=backend --timeout=90s
BACKENDIP=$(kubectl -n backend get pod -l app=backend -o jsonpath="{.items[0].status.podIP}")
print_success "Deployment backend created."

print_info "Running frontend Pod on frontend namespace..."
kubectl -n frontend run frontend --image=curlimages/curl:latest --restart=Never -- /bin/sh -c "while true; do sleep 3600; done"
kubectl wait --namespace frontend --for=condition=ready pod --selector=run=$FRONTENDPOD --timeout=90s
print_success "Pod frontend on frontend namespace created."

print_info "Running external Pod on external namespace..."
kubectl -n external run external --image=curlimages/curl:latest --restart=Never -- /bin/sh -c "while true; do sleep 3600; done"
kubectl wait --namespace external --for=condition=ready pod --selector=run=$EXTERNALPOD --timeout=90s
print_success "Pod external on external namespace created."

print_step "First check: connectivity should NOT work for both frontend and external (because of the Cluster Policy)"

print_info "Checking connectivity BEFORE NetworkPolicy (frontend)..."
kubectl -n frontend exec -it $FRONTENDPOD \
  -- curl -s --connect-timeout 5 $BACKENDIP > /dev/null 2>&1 \
  && print_success REACHABLE || print_error UNREACHABLE

print_info "Checking connectivity BEFORE NetworkPolicy (external)..."
kubectl -n external exec -it $EXTERNALPOD \
  -- curl -s --connect-timeout 5 $BACKENDIP > /dev/null 2>&1 \
  && print_success REACHABLE || print_error UNREACHABLE

print_step "Create Network Policy"

print_info "Creating Network Policy allow-ingress-egress-from-backend..."
kubectl create -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-ingress-egress-from-backend
  namespace: frontend
spec:
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          name: backend
    - podSelector:
        matchLabels:
          app: backend
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: backend
    - podSelector:
        matchLabels:
          app: backend
  podSelector:
    matchLabels:
      run: frontend
  policyTypes:
  - Ingress
  - Egress
EOF
print_success "Network Policy allow-ingress-egress-from-backend created"

print_info "Creating Network Policy allow-ingress-from-frontend-and-egress-to-any..."
kubectl create -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-ingress-from-frontend-and-egress-to-any
  namespace: backend
  resourceVersion: "738963"
spec:
  egress:
  - {}
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: frontend
    - podSelector:
        matchLabels:
          run: frontend
    ports:
    - port: 80
      protocol: TCP
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  - Egress
EOF
print_success "Network Policy allow-ingress-from-frontend-and-egress-to-any created"

print_step "Second check: connectivity should work just for frontend (because of the Network Policy)"

print_info "Checking connectivity AFTER NetworkPolicy (frontend)"
kubectl -n frontend exec -it $FRONTENDPOD \
  -- curl -s --connect-timeout 5 $BACKENDIP > /dev/null 2>&1 \
  && print_success REACHABLE || print_error UNREACHABLE

print_info "Checking connectivity AFTER NetworkPolicy (external)"
kubectl -n external exec -it $EXTERNALPOD \
  -- curl -s --connect-timeout 5 $BACKENDIP > /dev/null 2>&1 \
  && print_success REACHABLE || print_error UNREACHABLE

print_header "Test Complete"
