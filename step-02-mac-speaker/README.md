# Step 2: Run First FRR BGP Container (`mac-speaker`)

## Overview

In this step you will launch the first FRR container — `mac-speaker` — with a real BGP process running inside it. By the end of this step you will be able to `exec` into the container and run `show bgp summary` in `vtysh`, seeing a real BGP router with AS 65001 running on your Mac.

No BGP peers yet — that comes in Step 3. This is a baby-step: just get **one** BGP router alive and verified.

---

## What is FRR?

**FRRouting (FRR)** is an open-source routing protocol suite for Linux.

- Implements BGP, OSPF, ISIS, BFD, and more
- Used in production by major cloud providers (Microsoft Azure, DigitalOcean, and others)
- We use it to simulate BGP routers inside Docker containers — no physical hardware needed
- `vtysh` is FRR's unified CLI, similar in style to Cisco IOS or Juniper JunOS

---

## What is `mac-speaker`?

`mac-speaker` is the BGP speaker that represents the "Mac side" of the lab.

| Property | Value |
|----------|-------|
| Container name | `mac-speaker` |
| ASN | 65001 |
| IP address | 172.20.0.2 |
| Docker network | `bgp-lab` (172.20.0.0/24) |
| FRR image | `frrouting/frr:latest` (ARM64 compatible) |

**Future peering:**
- Will peer with `k8s-bgp-speaker` via **iBGP** (Step 3)
- Will peer with `juniper-sim` via **eBGP** (Step 4)

---

## Step 1: Create the Docker Network

Create a dedicated bridge network that all BGP lab containers will share:

```bash
# Create a dedicated bridge network for the BGP lab
docker network create \
  --driver bridge \
  --subnet 172.20.0.0/24 \
  --gateway 172.20.0.1 \
  bgp-lab

# Verify
docker network inspect bgp-lab | grep -E "Subnet|Gateway"
```

Expected output:
```
"Subnet": "172.20.0.0/24",
"Gateway": "172.20.0.1"
```

> **Note:** The `start.sh` script handles this automatically — it creates the network if it doesn't exist yet.

---

## Step 2: Review the Config Files

### `frr.conf` — BGP router configuration

Tells FRR who this router is:

- `hostname mac-speaker` — container hostname shown in vtysh prompt
- `router bgp 65001` — start BGP process with AS 65001
- `bgp router-id 172.20.0.2` — this router's unique BGP ID
- `no bgp default ipv4-unicast` — clean slate; we add address families explicitly
- Neighbors are intentionally absent — they will be added in Step 3 and Step 4

### `daemons` — FRR daemon enable/disable switches

Controls which FRR routing daemons start at container boot:

| Daemon | Enabled | Purpose |
|--------|---------|---------|
| `zebra` | yes | Core routing table manager — required by all other daemons |
| `bgpd` | yes | BGP daemon — the main event |
| `staticd` | yes | Static route manager |
| All others | no | Not needed for this lab |

---

## Step 3: Start the mac-speaker Container

Run from the **repo root**:

```bash
bash step-02-mac-speaker/start.sh
```

The script will:
1. Create the `bgp-lab` Docker network (if it doesn't exist)
2. Remove any old `mac-speaker` container (clean start)
3. Pull the latest `frrouting/frr` image
4. Start the container with the correct IP, capabilities, and config mounts
5. Wait 5 seconds for FRR daemons to initialize
6. Confirm the container is running

---

## Step 4: Verify BGP is Running

Run from the **repo root**:

```bash
bash step-02-mac-speaker/verify.sh
```

This script checks:

| Check | Expected |
|-------|----------|
| Container is running | `mac-speaker` shows in `docker ps` |
| Container IP | 172.20.0.2 |
| `bgpd` process running | `pgrep bgpd` returns a PID |
| `zebra` process running | `pgrep zebra` returns a PID |
| BGP AS number | 65001 (from `show running-config`) |
| BGP router-id | 172.20.0.2 (from `show running-config`) |
| `bgp-lab` network exists | `docker network inspect bgp-lab` succeeds |

---

## What to Expect in vtysh

Jump inside the container and explore the BGP router:

```bash
docker exec -it mac-speaker vtysh
```

### `show bgp summary`
```
mac-speaker# show bgp summary
% No BGP neighbors found
```
This is **normal** — no peers have been configured yet. That's Step 3.

### `show running-config`
```
mac-speaker# show running-config
...
router bgp 65001
 bgp router-id 172.20.0.2
 bgp log-neighbor-changes
 no bgp default ipv4-unicast
 !
 address-family ipv4 unicast
 exit-address-family
...
```

### `show ip route`
```
mac-speaker# show ip route
K>* 0.0.0.0/0 [0/0] via 172.20.0.1, eth0, 00:00:10
C>* 172.20.0.0/24 is directly connected, eth0, 00:00:10
```

### Exit vtysh
```
mac-speaker# exit
```

---

## Step 2 Complete Checklist

- [ ] `bgp-lab` Docker network created (172.20.0.0/24)
- [ ] `mac-speaker` container is running
- [ ] FRR BGP process is running inside container
- [ ] `show bgp summary` works in vtysh (no peers yet — that's OK!)
- [ ] `show running-config` shows `router bgp 65001`

---

## Next Step

👉 **[../step-03-ibgp-peering/](../step-03-ibgp-peering/)** *(coming in Step 3)*

Add `k8s-bgp-speaker` and establish an **iBGP session** between it and `mac-speaker`.
