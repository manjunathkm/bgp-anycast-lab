# Step 1: Environment Setup — OrbStack, Docker, and CLI Tools

## Overview

This step gets your Mac M4 Max ready to run the BGP + Anycast lab.

**Goal:** Install OrbStack, verify Docker is running natively on ARM64, and install the CLI tools needed for later steps.

No BGP or Kubernetes yet — just the foundation.

---

## Why OrbStack?

[OrbStack](https://orbstack.dev/) is the best Docker and Linux VM runtime for Apple Silicon.
Compared with Docker Desktop, OrbStack is:

- **Faster** — near-native performance with minimal overhead
- **Lighter** — uses far less RAM and CPU at idle
- **More compatible** — first-class ARM64 (aarch64) support, no emulation needed

OrbStack automatically configures the Docker socket so all standard `docker` commands work without any extra setup.

---

## Installation

### 1. Install Homebrew (if not already installed)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Install OrbStack

```bash
brew install orbstack
```

### 3. Launch OrbStack

```bash
open -a OrbStack
```

> OrbStack sets up the Docker socket automatically on first launch. Wait for the menu-bar icon to show it is running before continuing.

---

## Verify Docker is Working

```bash
docker version
docker info | grep -E "Architecture|OS"
```

**Expected output (relevant lines):**

```
Architecture: aarch64
Operating System: ...
```

> `aarch64` confirms Docker is running natively on Apple Silicon — no x86 emulation.

---

## Verify an ARM64 Container Runs Correctly

```bash
docker run --rm --platform linux/arm64 alpine uname -m
```

**Expected output:**

```
aarch64
```

---

## Install CLI Tools Needed for Later Steps

```bash
brew install kubectl kind helm
```

---

## Verify All Tools

```bash
docker version
kubectl version --client
kind version
helm version --short
```

All commands should print version output without errors.

---

## Step 1 Complete Checklist

- [ ] OrbStack installed and running
- [ ] `docker version` runs without errors
- [ ] Architecture shows `aarch64`
- [ ] ARM64 alpine container runs successfully
- [ ] `kubectl` installed and shows version
- [ ] `kind` installed and shows version
- [ ] `helm` installed and shows version

Run the verification script to check everything automatically:

```bash
bash step-01-setup/verify.sh
```

---

## Next Step

Once all checks pass, move on to **[../step-02-mac-speaker/](../step-02-mac-speaker/)** *(coming in Step 2)*.
