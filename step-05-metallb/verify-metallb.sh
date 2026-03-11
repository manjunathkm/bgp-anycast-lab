#!/bin/bash
# ============================================
# Step 5d: Verify MetalLB + BGP Peering
# ============================================

PASS="✅ PASS"
FAIL="❌ FAIL"

echo "============================================"
echo "  BGP Anycast Lab — Step 5d Verification"
echo "  MetalLB + BGP Peering"
echo "============================================"
echo ""

# 1. MetalLB controller running
echo -n "Checking MetalLB controller is Running... "
STATUS=$(kubectl get pods -n metallb-system -l app=metallb,component=controller   --no-headers 2>/dev/null | awk '{print $3}')
[[ "$STATUS" == "Running" ]] && echo "$PASS" || echo "$FAIL (got $STATUS)"

# 2. All 3 MetalLB speakers running
echo -n "Checking all 3 MetalLB speakers are Running... "
COUNT=$(kubectl get pods -n metallb-system -l app=metallb,component=speaker   --no-headers 2>/dev/null | grep -c "Running")
[[ "$COUNT" == "3" ]] && echo "$PASS (3/3)" || echo "$FAIL (got $COUNT/3)"

# 3. IPAddressPool exists
echo -n "Checking IPAddressPool anycast-vip-pool exists... "
kubectl get ipaddresspool anycast-vip-pool -n metallb-system &>/dev/null   && echo "$PASS" || echo "$FAIL"

# 4. BGPPeer exists
echo -n "Checking BGPPeer k8s-bgp-speaker exists... "
kubectl get bgppeer k8s-bgp-speaker -n metallb-system &>/dev/null   && echo "$PASS" || echo "$FAIL"

# 5. BGPAdvertisement exists
echo -n "Checking BGPAdvertisement anycast-vip-advert exists... "
kubectl get bgpadvertisement anycast-vip-advert -n metallb-system &>/dev/null   && echo "$PASS" || echo "$FAIL"

# 6. k8s-bgp-speaker on kind network
echo -n "Checking k8s-bgp-speaker is on kind network... "
IP=$(docker inspect k8s-bgp-speaker   --format '{{(index .NetworkSettings.Networks "kind").IPAddress}}' 2>/dev/null)
[[ -n "$IP" ]] && echo "$PASS (IP=$IP)" || echo "$FAIL (not connected to kind network)"

# 7. All 4 BGP sessions Established
echo -n "Checking all 4 BGP sessions are Established... "
COUNT=$(docker exec k8s-bgp-speaker vtysh -c "show bgp summary" 2>/dev/null   | awk 'NR>7 && /^[0-9]/ {print $10}' | grep -cE '^[0-9]+$')
[[ "$COUNT" == "4" ]] && echo "$PASS (4/4 Established)" || echo "$FAIL (got $COUNT/4 Established)"

echo ""
echo "============================================"
echo "  BGP Summary"
echo "============================================"
docker exec k8s-bgp-speaker vtysh -c "show bgp summary" 2>/dev/null | grep -A 20 "Neighbor"

echo ""
echo "============================================"
echo "  kind cluster verified!"
echo ""
echo "  Explore:"
echo "  kubectl get ipaddresspool -n metallb-system"
echo "  kubectl get bgppeer -n metallb-system"
echo "  docker exec k8s-bgp-speaker vtysh -c 'show bgp summary'"
echo "============================================"
