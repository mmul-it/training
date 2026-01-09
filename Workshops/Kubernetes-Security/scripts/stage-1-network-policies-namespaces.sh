#!/bin/bash

set -e

source functions.source

print_header "Stage 1: Network Policies Namespaces - Test"

print_info "This script will test Pod isolation using a Network Policy."

FRONTENDPOD=frontend
EXTERNALPOD=external

if [ "$1" == "clean" ]; then
  print_step "Cleaning up things..."
  kubectl delete --wait namespace backend frontend external
  print_header "Cleanup complete."
  exit 0
fi

print_step "Preparation"

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
kubectl -n frontend run $FRONTENDPOD --image=curlimages/curl:latest --restart=Never -- /bin/sh -c "while true; do sleep 3600; done"
kubectl wait --namespace frontend --for=condition=ready pod --selector=run=$FRONTENDPOD --timeout=90s
print_success "Pod frontend on frontend namespace created."

print_info "Running external Pod on external namespace..."
kubectl -n external run $EXTERNALPOD --image=curlimages/curl:latest --restart=Never -- /bin/sh -c "while true; do sleep 3600; done"
kubectl wait --namespace external --for=condition=ready pod --selector=run=$EXTERNALPOD --timeout=90s
print_success "Pod external on external namespace created."

print_step "First check: connectivity should work for both frontend and external"

print_info "Checking connectivity BEFORE NetworkPolicy (frontend)..."
kubectl -n frontend exec -it $FRONTENDPOD \
  -- curl -s --connect-timeout 5 $BACKENDIP > /dev/null 2>&1 \
  && print_success REACHABLE || print_error UNREACHABLE

print_info "Checking connectivity BEFORE NetworkPolicy (external)..."
kubectl -n external exec -it $EXTERNALPOD \
  -- curl -s --connect-timeout 5 $BACKENDIP > /dev/null 2>&1 \
  && print_success REACHABLE || print_error UNREACHABLE

print_step "Create Network Policy"

print_info "Adding labels to namespaces..."
kubectl label namespace frontend name=frontend
kubectl label namespace backend name=backend
kubectl label namespace external name=external
print_success "Labels added"

print_info "Creating Network Policy deny-all-except-frontend..."
kubectl create -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-except-frontend
  namespace: backend
spec:
  podSelector: {}  # applies to all pods in the backend namespace
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: frontend
EOF
print_success "Network Policy deny-all-except-frontend created"

print_step "Second check: connectivity should work just for frontend"

print_info "Checking connectivity AFTER NetworkPolicy (frontend)"
kubectl -n frontend exec -it $FRONTENDPOD \
  -- curl -s --connect-timeout 5 $BACKENDIP > /dev/null 2>&1 \
  && print_success REACHABLE || print_error UNREACHABLE

print_info "Checking connectivity AFTER NetworkPolicy (external)"
kubectl -n external exec -it $EXTERNALPOD \
  -- curl -s --connect-timeout 5 $BACKENDIP > /dev/null 2>&1 \
  && print_success REACHABLE || print_error UNREACHABLE

print_header "Test Complete"
