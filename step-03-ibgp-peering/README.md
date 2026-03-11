# Step 3: iBGP Peering (mac-speaker <-> k8s-bgp-speaker)

## Overview
Establish an iBGP session between two FRR containers on the same Docker bridge
network (bgp-lab). Both routers are in AS 65001 making this an internal BGP (iBGP) session.

## Lab Topology

    +-----------------------------------------------------+
    |                  bgp-lab (172.20.0.0/24)            |
    |                                                     |
    |  +-----------------+  iBGP   +-----------------+   |
    |  |  mac-speaker    |<------->| k8s-bgp-speaker |   |
    |  |  172.20.0.2     | AS65001 | 172.20.0.3      |   |
    |  |  AS 65001       |         | AS 65001        |   |
    |  +-----------------+         +-----------------+   |
    +-----------------------------------------------------+

## Lab Details

| Property | mac-speaker | k8s-bgp-speaker |
|----------|-------------|-----------------|
| IP | 172.20.0.2 | 172.20.0.3 |
| ASN | 65001 | 65001 |
| BGP type | iBGP | iBGP |
| iBGP neighbor | 172.20.0.3 | 172.20.0.2 |
| FRR image | quay.io/frrouting/frr:10.2.1 | quay.io/frrouting/frr:10.2.1 |

## Why iBGP?
Both containers are in AS 65001. When remote-as == local AS it is iBGP.
iBGP is used inside an AS to distribute routes learned from eBGP peers.
In Step 5 we will add an eBGP peer (Juniper) and this iBGP session will
carry those routes internally.

## Files

| File | Purpose |
|------|---------|
| k8s-speaker.frr.conf | BGP config for k8s-bgp-speaker |
| k8s-speaker.daemons | FRR daemons (bgpd, zebra, staticd) |
| k8s-speaker.vtysh.conf | Empty - suppresses vtysh warning |
| verify-ibgp.sh | Automated 7-check verification script |

## Steps

### 1. Launch k8s-bgp-speaker

    docker run -d \
      --name k8s-bgp-speaker \
      --network bgp-lab \
      --ip 172.20.0.3 \
      --platform linux/arm64 \
      --cap-add NET_ADMIN \
      --cap-add SYS_ADMIN \
      --cap-add NET_RAW \
      -v \$(pwd)/step-03-ibgp-peering/k8s-speaker.frr.conf:/etc/frr/frr.conf \
      -v \$(pwd)/step-03-ibgp-peering/k8s-speaker.daemons:/etc/frr/daemons \
      -v \$(pwd)/step-03-ibgp-peering/k8s-speaker.vtysh.conf:/etc/frr/vtysh.conf \
      quay.io/frrouting/frr:10.2.1

### 2. Verify iBGP Session

    bash step-03-ibgp-peering/verify-ibgp.sh

### 3. Explore with vtysh

    docker exec -it mac-speaker vtysh
    mac-speaker# show bgp summary
    mac-speaker# show bgp neighbors 172.20.0.3
    mac-speaker# show ip route
    mac-speaker# exit

## Verified Output (Mac M4 Max)

    Neighbor        V    AS      Up/Down   State/PfxRcd   Desc
    172.20.0.3      4    65001   00:00:41  0              k8s-bgp-speaker  PASS
    172.20.0.2      4    65001   00:00:41  0              mac-speaker      PASS

## Key Concept: State/PfxRcd = 0 means Established
In FRR show bgp summary, when State/PfxRcd is a number (even 0) the session
is Established. 0 means no prefixes exchanged yet - that happens in Step 6
when we advertise the anycast VIP.

## Checklist
- [x] k8s-bgp-speaker container running natively on ARM64
- [x] iBGP neighbor configured on both containers
- [x] BGP session Established (State/PfxRcd = 0)
- [x] Ping connectivity confirmed both directions
- [x] 7/7 automated checks passing

## Next Step
Step 4: kind k8s cluster - spin up a local Kubernetes cluster inside the bgp-lab network
