#!/bin/bash
# ============================================
# Step 4c: Verify kind cluster
# bgp-anycast: 1 control-plane + 2 workers
# ============================================

PASS="✅ PASS"
FAIL="❌ FAIL"

echo "============================================"
echo "  BGP Anycast Lab — Step 4c Verification"
echo "  kind cluster: bgp-anycast"
echo "============================================"
echo ""

# Check kind cluster exists
echo -n "Checking kind cluster bgp-anycast exists... "
if kind get clusters | grep -q "bgp-anycast"; then
  echo "$PASS"
else
  echo "$FAIL — run: kind create cluster --config step-04-kind-cluster/kind-config.yaml"
  exit 1
fi

# Check kubectl context
echo -n "Checking kubectl context is kind-bgp-anycast... "
CTX=$(kubectl config current-context 2>/dev/null)
if [[ "$CTX" == "kind-bgp-anycast" ]]; then
  echo "$PASS"
else
  echo "$FAIL (got $CTX)"
  echo "  Fix: kubectl config use-context kind-bgp-anycast"
  exit 1
fi

echo ""

# Check all 3 nodes are Ready
for NODE in bgp-anycast-control-plane bgp-anycast-worker bgp-anycast-worker2; do
  echo -n "Checking $NODE is Ready... "
  STATUS=$(kubectl get node "$NODE" -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null)
  if [[ "$STATUS" == "True" ]]; then
    echo "$PASS"
  else
    echo "$FAIL (status=$STATUS)"
  fi
done

echo ""

# Check k8s version
echo -n "Checking k8s version is v1.32.0... "
VERSION=$(kubectl get nodes -o jsonpath='{.items[0].status.nodeInfo.kubeletVersion}' 2>/dev/null)
if [[ "$VERSION" == "v1.32.0" ]]; then
  echo "$PASS"
else
  echo "$FAIL (got $VERSION)"
fi

# Check system pods are running
echo ""
echo -n "Checking kube-system pods are Running... "
NOT_RUNNING=$(kubectl get pods -n kube-system --no-headers 2>/dev/null | grep -v "Running\|Completed" | wc -l | tr -d ' ')
if [[ "$NOT_RUNNING" == "0" ]]; then
  echo "$PASS"
else
  echo "$FAIL ($NOT_RUNNING pods not Running)"
  kubectl get pods -n kube-system --no-headers | grep -v "Running\|Completed"
fi

echo ""
echo "============================================"
echo "  kind cluster verified!"
echo ""
echo "  Explore:"
echo "  kubectl get nodes -o wide"
echo "  kubectl get pods -n kube-system"
echo "  kind get clusters"
echo "============================================"
