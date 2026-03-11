#!/bin/bash
# ============================================
# Step 2 Verification Script
# Verifies mac-speaker FRR container is running
# and BGP process is healthy
# ============================================

PASS="✅ PASS"
FAIL="❌ FAIL"
CONTAINER="mac-speaker"

echo "============================================"
echo "  BGP Anycast Lab — Step 2 Verification"
echo "  mac-speaker FRR container"
echo "============================================"
echo ""

# Check container is running
echo -n "Checking mac-speaker container is running... "
if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
  echo "$PASS"
else
  echo "$FAIL — Run: bash step-02-mac-speaker/start.sh"
  exit 1
fi

# Check container IP
echo -n "Checking container IP is 172.20.0.2... "
CONTAINER_IP=$(docker inspect "$CONTAINER" --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' 2>/dev/null)
if [[ "$CONTAINER_IP" == "172.20.0.2" ]]; then
  echo "$PASS ($CONTAINER_IP)"
else
  echo "$FAIL — Got: $CONTAINER_IP (expected: 172.20.0.2)"
fi

# Check bgpd process is running inside container
echo -n "Checking bgpd process is running... "
if docker exec "$CONTAINER" pgrep bgpd &>/dev/null; then
  echo "$PASS"
else
  echo "$FAIL — bgpd not running inside container"
fi

# Check zebra process is running
echo -n "Checking zebra process is running... "
if docker exec "$CONTAINER" pgrep zebra &>/dev/null; then
  echo "$PASS"
else
  echo "$FAIL — zebra not running inside container"
fi

# Check BGP AS number via vtysh
echo -n "Checking BGP AS 65001 is configured... "
BGP_AS=$(docker exec "$CONTAINER" vtysh -c "show running-config" 2>/dev/null | grep "router bgp" | awk '{print $3}')
if [[ "$BGP_AS" == "65001" ]]; then
  echo "$PASS (AS $BGP_AS)"
else
  echo "$FAIL — Got AS: '$BGP_AS' (expected: 65001)"
fi

# Check BGP router-id via running config
echo -n "Checking BGP router-id 172.20.0.2... "
ROUTER_ID=$(docker exec "$CONTAINER" vtysh -c "show running-config" 2>/dev/null | grep "bgp router-id" | awk '{print $3}')
if [[ "$ROUTER_ID" == "172.20.0.2" ]]; then
  echo "$PASS ($ROUTER_ID)"
else
  echo "$FAIL — Got: '$ROUTER_ID' (expected: 172.20.0.2)"
fi

# Check bgp-lab network exists
echo -n "Checking bgp-lab Docker network exists... "
if docker network inspect bgp-lab &>/dev/null; then
  echo "$PASS"
else
  echo "$FAIL — bgp-lab network not found"
fi

echo ""
echo "============================================"
echo "  BGP router mac-speaker is live!"
echo ""
echo "  Try it yourself:"
echo "  docker exec -it mac-speaker vtysh"
echo "  mac-speaker# show bgp summary"
echo "  mac-speaker# show running-config"
echo "  mac-speaker# exit"
echo ""
echo "  Next: step-03-ibgp-peering/"
echo "============================================"
