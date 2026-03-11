#!/bin/bash
# ============================================
# Step 3c: Verify iBGP Session
# mac-speaker <-> k8s-bgp-speaker
# ============================================

PASS="✅ PASS"
FAIL="❌ FAIL"

echo "============================================"
echo "  BGP Anycast Lab — Step 3c Verification"
echo "  iBGP Session: mac-speaker <-> k8s-bgp-speaker"
echo "============================================"
echo ""

# Check both containers are running
for CONTAINER in mac-speaker k8s-bgp-speaker; do
  echo -n "Checking $CONTAINER is running... "
  if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
    echo "$PASS"
  else
    echo "$FAIL — run: docker start $CONTAINER"
    exit 1
  fi
done

echo ""

# Check mac-speaker BGP session to k8s-bgp-speaker
echo -n "Checking mac-speaker sees k8s-bgp-speaker as Established... "
STATE=$(docker exec mac-speaker vtysh -c "show bgp summary" 2>/dev/null \
  | grep "172.20.0.3" | awk '{print $10}')
if [[ "$STATE" =~ ^[0-9]+$ ]]; then
  echo "$PASS (State/PfxRcd=$STATE)"
else
  echo "$FAIL — State=$STATE (expected a number = Established)"
fi

# Check k8s-bgp-speaker BGP session to mac-speaker
echo -n "Checking k8s-bgp-speaker sees mac-speaker as Established... "
STATE=$(docker exec k8s-bgp-speaker vtysh -c "show bgp summary" 2>/dev/null \
  | grep "172.20.0.2" | awk '{print $10}')
if [[ "$STATE" =~ ^[0-9]+$ ]]; then
  echo "$PASS (State/PfxRcd=$STATE)"
else
  echo "$FAIL — State=$STATE (expected a number = Established)"
fi

echo ""

# Check AS numbers
echo -n "Checking mac-speaker AS is 65001... "
AS=$(docker exec mac-speaker vtysh -c "show bgp summary" 2>/dev/null \
  | grep "local AS number" | awk '{print $8}')
[[ "$AS" == "65001" ]] && echo "$PASS" || echo "$FAIL (got $AS)"

echo -n "Checking k8s-bgp-speaker AS is 65001... "
AS=$(docker exec k8s-bgp-speaker vtysh -c "show bgp summary" 2>/dev/null \
  | grep "local AS number" | awk '{print $8}')
[[ "$AS" == "65001" ]] && echo "$PASS" || echo "$FAIL (got $AS)"

# Ping between containers
echo ""
echo -n "Checking connectivity mac-speaker -> k8s-bgp-speaker (ping)... "
if docker exec mac-speaker ping -c 2 -W 2 172.20.0.3 &>/dev/null; then
  echo "$PASS"
else
  echo "$FAIL"
fi

echo -n "Checking connectivity k8s-bgp-speaker -> mac-speaker (ping)... "
if docker exec k8s-bgp-speaker ping -c 2 -W 2 172.20.0.2 &>/dev/null; then
  echo "$PASS"
else
  echo "$FAIL"
fi

echo ""
echo "============================================"
echo "  iBGP session verified!"
echo ""
echo "  Explore:"
echo "  docker exec -it mac-speaker vtysh"
echo "  mac-speaker# show bgp summary"
echo "  mac-speaker# show bgp neighbors 172.20.0.3"
echo "============================================"
