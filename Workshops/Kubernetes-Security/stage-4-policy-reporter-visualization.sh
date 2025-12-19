#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_header() {
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  $1${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Function to wait for resources
wait_for_resource() {
    local resource=$1
    local name=$2
    local namespace=$3
    local timeout=${4:-30}
    
    print_info "Waiting for $resource $name in namespace $namespace..."
    local counter=0
    while [ $counter -lt $timeout ]; do
        if kubectl get $resource $name -n $namespace &> /dev/null; then
            print_success "$resource $name is ready"
            return 0
        fi
        sleep 2
        counter=$((counter + 2))
    done
    print_warning "Timeout waiting for $resource $name"
    return 1
}

print_header "Stage 4: Policy Reporter Visualization - Testing"

# Check prerequisites
print_info "Checking prerequisites..."

if ! kubectl get namespace kyverno &> /dev/null; then
    print_error "Kyverno is not installed. Please install it first."
    echo "Run: helm install kyverno kyverno/kyverno -n kyverno --create-namespace --version 3.1.4"
    exit 1
fi

if ! kubectl get namespace policy-reporter &> /dev/null; then
    print_error "Policy Reporter is not installed. Please install it first."
    echo "See Stage-4-Policy-Reporter-Visualization.md for installation instructions."
    exit 1
fi

print_success "Prerequisites check passed"

# Create test namespace
print_header "Creating Test Environment"

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

print_info "Kyverno is evaluating policies against deployed resources..."
sleep 15

# Check policy reports
print_header "Policy Reports Generated"

if kubectl get policyreport -n policy-test &> /dev/null; then
    echo ""
    kubectl get policyreport -n policy-test
    echo ""
    print_info "Detailed policy report:"
    echo ""
    kubectl describe policyreport -n policy-test | grep -A 50 "Results:" || kubectl describe policyreport -n policy-test
else
    print_warning "No policy reports found yet"
    print_info "Policy reports might take a moment to appear"
fi

# Show how to access UI
print_header "Accessing Policy Reporter UI"

echo ""
print_info "To view the reports in the Policy Reporter UI:"
echo ""
echo "  1. Start port forwarding:"
echo "     ${GREEN}kubectl port-forward -n policy-reporter svc/policy-reporter-ui 8082:8080${NC}"
echo ""
echo "  2. Open your browser:"
echo "     ${GREEN}http://localhost:8082${NC}"
echo ""
echo "  3. Navigate to the 'policy-test' namespace to see violations"
echo ""

# Cleanup function
cleanup() {
    print_header "Cleanup"
    
    print_info "Deleting test pods..."
    kubectl delete pod -n policy-test --all --ignore-not-found=true
    print_success "Test pods deleted"
    
    print_info "Deleting cluster policies..."
    kubectl delete clusterpolicy require-labels disallow-latest-tag --ignore-not-found=true
    print_success "Cluster policies deleted"
    
    print_info "Deleting test namespace..."
    kubectl delete namespace policy-test --ignore-not-found=true
    print_success "Test namespace deleted"
    
    echo ""
    print_success "Cleanup completed!"
}

# Ask for cleanup
echo ""
read -p "$(echo -e ${YELLOW}Do you want to cleanup test resources? [y/N]:${NC} )" -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    cleanup
else
    print_info "Cleanup skipped"
    echo ""
    print_warning "To cleanup later, run the following commands:"
    echo "  kubectl delete namespace policy-test"
    echo "  kubectl delete clusterpolicy require-labels disallow-latest-tag"
fi

print_header "Stage 4 Testing Complete"
echo ""
print_success "All tests completed successfully!"
echo ""
