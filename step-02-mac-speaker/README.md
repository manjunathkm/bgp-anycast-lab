# Step 2: Run First FRR BGP Container (mac-speaker)

## Overview
Launch the first FRR container — `mac-speaker` — with BGP AS 65001 running
natively on ARM64 (aarch64) via OrbStack on Mac M4 Max.
No peers yet. Goal: get a BGP router running and verify with vtysh.

## Lab Details
| Property | Value |
|----------|-------|
| Container name | `mac-speaker` |
| ASN | 65001 |
| Router-ID | 172.20.0.2 |
| Docker network | `bgp-lab` (172.20.0.0/24) |
| FRR image | `quay.io/frrouting/frr:10.2.1` (ARM64 native) |

## Why quay.io?
`frrouting/frr` on Docker Hub only publishes `amd64` images.
The official multi-arch images (amd64 + arm64) are on Quay.io:
`quay.io/frrouting/frr`

## Files
| File | Purpose |
|------|---------|
| `frr.conf` | BGP router config (AS 65001, router-id 172.20.0.2) |
| `daemons` | FRR daemons config (enables bgpd, zebra, staticd) |
| `vtysh.conf` | Empty file to suppress vtysh warning |

## Steps

### 1. Create Docker Network
```bash
docker network create \
  --driver bridge \
  --subnet 172.20.0.0/24 \
  --gateway 172.20.0.1 \
  bgp-lab
