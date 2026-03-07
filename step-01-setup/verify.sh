#!/bin/bash
# ==============================================
# BGP Anycast Lab — Step 1 Verification Script
# Run this after completing step-01-setup/README.md
# ==============================================

PASS="✅ PASS"
FAIL="❌ FAIL"

echo "============================================"
echo "  BGP Anycast Lab — Step 1 Verification"
echo "============================================"
echo ""

# Check Docker daemon is running
echo -n "Checking Docker is running... "
if docker info &>/dev/null; then
  echo "$PASS"
else
  echo "$FAIL — Is OrbStack running? Open it from Applications."
  exit 1
fi

# Check ARM64 architecture
echo -n "Checking ARM64 (aarch64) architecture... "
ARCH=$(docker info 2>/dev/null | grep Architecture | awk '{print $2}')
if [[ "$ARCH" == "aarch64" ]]; then
  echo "$PASS ($ARCH)"
else
  echo "$FAIL — Got: '$ARCH' (expected: aarch64)"
fi

# Check ARM64 container actually runs
echo -n "Checking ARM64 container runs (alpine)... "
CONTAINER_ARCH=$(docker run --rm --platform linux/arm64 alpine uname -m 2>/dev/null)
if [[ "$CONTAINER_ARCH" == "aarch64" ]]; then
  echo "$PASS"
else
  echo "$FAIL — Could not run ARM64 alpine container"
fi

# Check kubectl
echo -n "Checking kubectl installed... "
if command -v kubectl &>/dev/null; then
  VERSION=$(kubectl version --client --short 2>/dev/null | head -1)
  echo "$PASS ($VERSION)"
else
  echo "$FAIL — Run: brew install kubectl"
fi

# Check kind
echo -n "Checking kind installed... "
if command -v kind &>/dev/null; then
  echo "$PASS ($(kind version))"
else
  echo "$FAIL — Run: brew install kind"
fi

# Check helm
echo -n "Checking helm installed... "
if command -v helm &>/dev/null; then
  echo "$PASS ($(helm version --short 2>/dev/null))"
else
  echo "$FAIL — Run: brew install helm"
fi

echo ""
echo "============================================"
echo "  Done! Fix any FAILs above, then move on"
echo "  to Step 2: step-02-mac-speaker/"
echo "============================================"
