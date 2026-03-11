#!/bin/bash
# ============================================
# Start mac-speaker FRR container
# Step 2: BGP Anycast Lab
# ============================================

set -e

CONTAINER_NAME="mac-speaker"
NETWORK_NAME="bgp-lab"
CONTAINER_IP="172.20.0.2"
IMAGE="frrouting/frr:latest"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "============================================"
echo "  Starting mac-speaker FRR container"
echo "============================================"
echo ""

# Check if bgp-lab network exists, create if not
if ! docker network inspect "$NETWORK_NAME" &>/dev/null; then
  echo "Creating $NETWORK_NAME Docker network..."
  docker network create \
    --driver bridge \
    --subnet 172.20.0.0/24 \
    --gateway 172.20.0.1 \
    "$NETWORK_NAME"
  echo "✅ Network $NETWORK_NAME created"
else
  echo "✅ Network $NETWORK_NAME already exists"
fi

# Stop and remove existing container if running
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo "Removing existing $CONTAINER_NAME container..."
  docker rm -f "$CONTAINER_NAME"
fi

# Pull latest FRR image
echo "Pulling FRR image ($IMAGE)..."
docker pull "$IMAGE"

# Start the container
echo ""
echo "Starting $CONTAINER_NAME container..."
docker run -d \
  --name "$CONTAINER_NAME" \
  --network "$NETWORK_NAME" \
  --ip "$CONTAINER_IP" \
  --cap-add NET_ADMIN \
  --cap-add SYS_ADMIN \
  --cap-add NET_RAW \
  -v "$SCRIPT_DIR/frr.conf:/etc/frr/frr.conf" \
  -v "$SCRIPT_DIR/daemons:/etc/frr/daemons" \
  "$IMAGE"

# Wait for FRR to initialize
echo "Waiting for FRR to initialize..."
sleep 5

# Verify container is running
if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo ""
  echo "✅ $CONTAINER_NAME is running!"
  echo ""
  echo "Container details:"
  docker inspect "$CONTAINER_NAME" --format '  IP: {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'
  echo "  Name: $CONTAINER_NAME"
  echo ""
  echo "Next: run bash step-02-mac-speaker/verify.sh"
else
  echo "❌ Failed to start $CONTAINER_NAME"
  echo "Check logs: docker logs $CONTAINER_NAME"
  exit 1
fi
