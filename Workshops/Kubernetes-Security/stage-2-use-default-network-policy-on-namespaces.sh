#!/bin/bash

kubectl delete --wait clusterpolicies add-namespace-name-label add-default-deny
kubectl delete --wait namespace backend frontend external

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

kubectl create namespace backend
kubectl create namespace frontend
kubectl create namespace external

kubectl --namespace backend create deployment backend  --image nginx:latest
kubectl wait --namespace backend --for=condition=ready pod --selector=app=backend --timeout=90s

kubectl -n frontend run frontend --image=curlimages/curl:latest --restart=Never -- /bin/sh -c "while true; do sleep 3600; done"
kubectl -n external run external --image=curlimages/curl:latest --restart=Never -- /bin/sh -c "while true; do sleep 3600; done"

BACKENDIP=$(kubectl -n backend get pod -l app=backend -o jsonpath="{.items[0].status.podIP}")
FRONTENDPOD=$(kubectl -n frontend get pod -l run=frontend -o jsonpath='{.items[0].metadata.name}')
EXTERNALPOD=$(kubectl -n external get pod -l run=external -o jsonpath='{.items[0].metadata.name}')

sleep 3

echo -n "Before NetworkPolicy (frontend): "
kubectl -n frontend exec -it $FRONTENDPOD -- curl -s --connect-timeout 5 $BACKENDIP > /dev/null 2>&1 && echo REACHABLE || echo UNREACHABLE
echo -n "Before NetworkPolicy (external): "
kubectl -n external exec -it $EXTERNALPOD -- curl -s --connect-timeout 5 $BACKENDIP > /dev/null 2>&1 && echo REACHABLE || echo UNREACHABLE

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

echo -n "After NetworkPolicy (frontend): "
kubectl -n frontend exec -it $FRONTENDPOD -- curl -s --connect-timeout 5 $BACKENDIP > /dev/null 2>&1 && echo REACHABLE || echo UNREACHABLE
echo -n "After NetworkPolicy (external): "
kubectl -n external exec -it $EXTERNALPOD -- curl -s --connect-timeout 5 $BACKENDIP > /dev/null 2>&1 && echo REACHABLE || echo UNREACHABLE
