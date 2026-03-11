# Step 5: MetalLB BGP Load Balancer

## Overview

MetalLB v0.14.9 installed in BGP mode.
Anycast VIP 10.100.100.0 advertised from multiple nodes via iBGP - true ECMP anycast.

## Architecture

    kind cluster (AS 65001)
      worker        192.168.97.2  MetalLB speaker
      control-plane 192.168.97.3  MetalLB speaker
      worker2       192.168.97.4  MetalLB speaker
           |               |               |
           +-------iBGP----+-------iBGP----+
                           |
                  k8s-bgp-speaker
                   172.20.0.3 (bgp-lab)
                   192.168.97.5 (kind)
                           |
                      mac-speaker
                      172.20.0.2

## Components

| Resource | Name | Value |
|----------|------|-------|
| IPAddressPool | anycast-vip-pool | 10.100.100.0/24 |
| BGPPeer | k8s-bgp-speaker | 192.168.97.5, AS 65001 |
| BGPAdvertisement | anycast-vip-advert | aggregation /32, localPref 100 |

## BGP Sessions

| Neighbor | Description | State |
|----------|-------------|-------|
| 172.20.0.2 | mac-speaker | Established |
| 192.168.97.2 | metallb-speaker-worker | Established |
| 192.168.97.3 | metallb-speaker-control-plane | Established |
| 192.168.97.4 | metallb-speaker-worker2 | Established |

## Anycast VIP Result

    NAME               TYPE           EXTERNAL-IP    PORT(S)
    test-anycast-vip   LoadBalancer   10.100.100.0   80:32534/TCP

    BGP Table:
    *>i 10.100.100.0/32  192.168.97.2  localpref=100  (worker)
    *=i 10.100.100.0/32  192.168.97.4  localpref=100  (worker2)

Same VIP from 2 nodes = ECMP anycast!

## Key Fix: Network Isolation

kind nodes (192.168.97.x) and bgp-lab (172.20.0.x) are isolated Docker networks.

Fix: connect k8s-bgp-speaker to both networks:

    docker network connect kind k8s-bgp-speaker
    # Result: bgp-lab=172.20.0.3  kind=192.168.97.5

See network-setup.sh to reproduce.

## Files

| File | Purpose |
|------|---------|
| metallb-version.txt | Version record |
| ipaddresspool.yaml | VIP pool 10.100.100.0/24 |
| bgp-config.yaml | BGPPeer + BGPAdvertisement |
| network-setup.sh | Connect k8s-bgp-speaker to kind network |
| test-service.yaml | Test LoadBalancer + nginx deployment |
| verify-metallb.sh | 7-check verification script |

## Verify

    bash step-05-metallb/verify-metallb.sh
    kubectl get svc test-anycast-vip
    docker exec k8s-bgp-speaker vtysh -c 'show bgp ipv4 unicast'

## PRs

| PR | Description |
|----|-------------|
| #12 | 5a: Install MetalLB v0.14.9 |
| #13 | 5b: IPAddressPool (10.100.100.0/24) |
| #14 | 5c: BGPPeer + BGPAdvertisement, 4/4 sessions Established |
| #15 | 5d: Verify 7/7 PASS, VIP=10.100.100.0, 2-path ECMP |
