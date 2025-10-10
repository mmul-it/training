#!/bin/bash

kubectl delete namespace backend frontend external 
                                      
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

kubectl label namespace frontend name=frontend
kubectl label namespace backend name=backend
kubectl label namespace external name=external

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

echo -n "After NetworkPolicy (frontend): "
kubectl -n frontend exec -it $FRONTENDPOD -- curl -s --connect-timeout 5 $BACKENDIP > /dev/null 2>&1 && echo REACHABLE || echo UNREACHABLE
echo -n "After NetworkPolicy (external): "
kubectl -n external exec -it $EXTERNALPOD -- curl -s --connect-timeout 5 $BACKENDIP > /dev/null 2>&1 && echo REACHABLE || echo UNREACHABLE
