# Step 4: kind Kubernetes Cluster

## Overview
Spin up a local 3-node Kubernetes cluster using kind (Kubernetes IN Docker)
on the Mac M4 Max with OrbStack. The cluster runs natively on ARM64.

## Cluster Topology

    +--------------------------------------------------+
    |              bgp-anycast (kind cluster)          |
    |                                                  |
    |  +---------------------+  192.168.97.3           |
    |  | control-plane       |  k8s v1.32.0            |
    |  +---------------------+                         |
    |                                                  |
    |  +---------------------+  192.168.97.2           |
    |  | worker              |  k8s v1.32.0            |
    |  +---------------------+                         |
    |                                                  |
    |  +---------------------+  192.168.97.4           |
    |  | worker2             |  k8s v1.32.0            |
    |  +---------------------+                         |
    +--------------------------------------------------+

## Cluster Details

| Property | Value |
|----------|-------|
| Cluster name | bgp-anycast |
| k8s version | v1.32.0 |
| Nodes | 1 control-plane + 2 workers |
| Pod subnet | 10.244.0.0/16 |
| Service subnet | 10.96.0.0/12 |
| Runtime | containerd 1.7.24 |
| OS | Debian GNU/Linux 12 (bookworm) |
| Kernel | 6.17.8-orbstack (ARM64) |

## Node IPs

| Node | IP | Role |
|------|----|------|
| bgp-anycast-control-plane | 192.168.97.3 | control-plane |
| bgp-anycast-worker | 192.168.97.2 | worker |
| bgp-anycast-worker2 | 192.168.97.4 | worker |

## Files

| File | Purpose |
|------|---------|
| kind-config.yaml | kind cluster definition (1 control-plane + 2 workers) |
| tool-versions.txt | Required tool versions verified on Mac M4 Max |
| verify-kind.sh | Automated 7-check verification script |

## Steps

### 1. Create the cluster

    kind create cluster --config step-04-kind-cluster/kind-config.yaml

Takes ~2 minutes to pull images and start.

### 2. Wait for nodes to be Ready

    kubectl wait --for=condition=Ready nodes --all --timeout=120s

### 3. Verify

    bash step-04-kind-cluster/verify-kind.sh

### 4. Explore

    kubectl get nodes -o wide
    kubectl get pods -n kube-system
    kind get clusters

### Teardown (when needed)

    kind delete cluster --name bgp-anycast

## Verified Output (Mac M4 Max)

    NAME                        STATUS   ROLES           AGE   VERSION
    bgp-anycast-control-plane   Ready    control-plane   95s   v1.32.0
    bgp-anycast-worker          Ready    worker          85s   v1.32.0
    bgp-anycast-worker2         Ready    worker          85s   v1.32.0

## Checklist
- [x] kind v0.31.0 installed (darwin/arm64)
- [x] kubectl v1.32.0 installed
- [x] Cluster created with kind-config.yaml
- [x] All 3 nodes Ready
- [x] kube-system pods all Running
- [x] 7/7 automated checks passing

## Next Step
Step 5: MetalLB — install MetalLB on the kind cluster to enable
BGP-based LoadBalancer services for anycast VIP advertisement
