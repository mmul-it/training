#!/bin/bash

set -e

source functions.source

print_header "Stage 4: Policy Reporter Visualization - Testing"

if [ "$1" == "clean" ]; then
  print_step "Cleaning up things..."
  kubectl delete namespace policy-test --ignore-not-found=true
  kubectl delete clusterpolicy require-labels disallow-latest-tag --ignore-not-found=true
  print_header "Cleanup complete."
  exit 0
fi

print_step "Prerequisites"

check_kyverno

check_kyverno_policy_reporter

print_success "Prerequisites check passed"

print_step "Preparation"

# Create test namespace
print_info "Creating namespace policy-test..."
kubectl create namespace policy-test --dry-run=client -o yaml | kubectl apply -f -
print_success "Namespace created"

# Create Kyverno policies
print_header "Creating Kyverno Policies"

print_info "Creating 'require-labels' policy..."
cat <<EOF | kubectl apply -f -
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-labels
  annotations:
    policies.kyverno.io/title: Require Labels
    policies.kyverno.io/category: Best Practices
    policies.kyverno.io/severity: medium
    policies.kyverno.io/description: >-
      Requires all pods to have 'app' and 'owner' labels.
spec:
  validationFailureAction: Audit
  background: true
  rules:
    - name: check-for-labels
      match:
        any:
        - resources:
            kinds:
              - Pod
      validate:
        message: "Pods must have 'app' and 'owner' labels."
        pattern:
          metadata:
            labels:
              app: "?*"
              owner: "?*"
EOF
print_success "Policy 'require-labels' created"

print_info "Creating 'disallow-latest-tag' policy..."
cat <<EOF | kubectl apply -f -
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-latest-tag
  annotations:
    policies.kyverno.io/title: Disallow Latest Tag
    policies.kyverno.io/category: Best Practices
    policies.kyverno.io/severity: medium
    policies.kyverno.io/description: >-
      Disallow use of the 'latest' tag in container images.
spec:
  validationFailureAction: Audit
  background: true
  rules:
    - name: require-image-tag
      match:
        any:
        - resources:
            kinds:
              - Pod
      validate:
        message: "Using 'latest' tag is not allowed. Specify a version tag."
        pattern:
          spec:
            containers:
            - image: "!*:latest"
    - name: require-image-tag-initcontainers
      match:
        any:
        - resources:
            kinds:
              - Pod
      validate:
        message: "Using 'latest' tag is not allowed in init containers."
        pattern:
          spec:
            =(initContainers):
            - image: "!*:latest"
EOF
print_success "Policy 'disallow-latest-tag' created"

print_step "Test"

# Deploy test pods
print_header "Deploying Test Pods"

print_info "Creating compliant pod (has labels, versioned image)..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: compliant-pod
  namespace: policy-test
  labels:
    app: nginx
    owner: security-team
spec:
  containers:
  - name: nginx
    image: nginx:1.21
EOF
print_success "Compliant pod created"

print_info "Creating non-compliant pod (missing owner label)..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: non-compliant-missing-labels
  namespace: policy-test
  labels:
    app: nginx
spec:
  containers:
  - name: nginx
    image: nginx:1.21
EOF
print_success "Non-compliant pod (missing labels) created"

print_info "Creating non-compliant pod (using latest tag)..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: non-compliant-latest-tag
  namespace: policy-test
  labels:
    app: nginx
    owner: security-team
spec:
  containers:
  - name: nginx
    image: nginx:latest
EOF
print_success "Non-compliant pod (latest tag) created"

# Wait for policy evaluation
print_header "Waiting for Policy Evaluation"

# Check policy reports
i=1
TIMEOUT=30
while true; do
  EXISTING=$(kubectl --namespace policy-test get policyreport -o jsonpath='{.items[*].scope.name}')
  if echo "$EXISTING" | grep -qw "non-compliant-latest-tag" && \
     echo "$EXISTING" | grep -qw "compliant-pod" && \
     echo "$EXISTING" | grep -qw "non-compliant-missing-labels"; then
    print_success "All three PolicyReports exist!"
    break
  else
    if [ $i -ne $TIMEOUT ]
     then
       echo -n "."
       sleep 1
       i=$(( $i + 1 ))
     else
       print_error "Timed out waiting for the three PolicyReports"
       exit 1
    fi
  fi
done

print_info "Check details about Policy Reports by describing them:"
for PR in $(kubectl --namespace policy-test get policyreport -o name); do
  print_info "kubectl --namespace policy-test describe ${PR}"
done

# Show how to access UI
print_step "Accessing Policy Reporter UI"

echo -e "To view the reports in the Policy Reporter UI:
 1. Start port forwarding:
    ${GREEN}kubectl port-forward -n policy-reporter svc/policy-reporter-ui 8082:8080${NC}

 2. Open your browser:
    ${GREEN}http://localhost:8082${NC}

 3. Navigate to the 'policy-test' namespace to see violations
"

print_header "Test Complete"
