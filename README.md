# BGP + Anycast Lab — Mac M4 Max (Fully Virtual)

A baby-steps, fully virtual BGP + Anycast lab that runs entirely on a Mac M4 Max (36 GB RAM).
No physical hardware required — everything runs inside Docker containers and a local Kubernetes cluster.

Built and documented step-by-step as professional work documentation.

---

## Final Architecture

```
Mac M4 Max (36GB RAM) — everything runs here

[mac-speaker FRR]  <--iBGP-->  [k8s-bgp-speaker FRR / MetalLB]
       |                                    |
       +----------eBGP----------+-----------+
                                |
                       [juniper-sim FRR]

K8s cluster (kind) with Anycast app pods → VIP: 10.100.0.1
```

---

## Baby-Steps Roadmap

- [x] **Step 1:** Repo setup + OrbStack/Docker installation & verification
- [x] **Step 2:** Run first FRR BGP container (mac-speaker)
- [ ] **Step 3:** Run second FRR BGP container (k8s-bgp-speaker) + establish iBGP session
- [ ] **Step 4:** Run third FRR container (juniper-sim) + establish eBGP sessions
- [ ] **Step 5:** Create kind Kubernetes cluster
- [ ] **Step 6:** Install and configure MetalLB in BGP mode
- [ ] **Step 7:** Deploy Anycast app pods with LoadBalancer VIP
- [ ] **Step 8:** Connect MetalLB BGP to juniper-sim FRR container
- [ ] **Step 9:** Verify full BGP table and Anycast VIP propagation end-to-end

---

## Prerequisites

| Tool | Purpose |
|------|---------|
| macOS (Apple Silicon M4) | Host OS — all containers run natively as ARM64 |
| [OrbStack](https://orbstack.dev/) | Fast, lightweight Docker + Linux VM runtime for Apple Silicon |
| Docker CLI | Container management (`brew install docker` — included with OrbStack) |
| kubectl | Kubernetes CLI (`brew install kubectl`) |
| kind | Local Kubernetes clusters via Docker (`brew install kind`) |
| brew | macOS package manager — install from [brew.sh](https://brew.sh) |

---

## Lab IP Plan

| Node | IP | ASN |
|------|----|-----|
| mac-speaker | 172.20.0.2 | 65001 |
| k8s-bgp-speaker | 172.20.0.3 | 65001 |
| juniper-sim | 172.20.0.4 | 65100 |
| Anycast VIP | 10.100.0.1 | — |

---

## How to Use This Repo

```bash
git clone https://github.com/manjunathkm/bgp-anycast-lab.git
cd bgp-anycast-lab
```

Follow the steps in order. Each step directory contains its own `README.md` with detailed instructions and a `verify.sh` script to confirm you have completed the step correctly before moving on.

| Directory | Step |
|-----------|------|
| [`step-01-setup/`](./step-01-setup/) | Install & verify OrbStack + Docker + CLI tools |
| [`step-02-mac-speaker/`](./step-02-mac-speaker/) | Run first FRR BGP container |
| `step-03-ibgp/` *(coming soon)* | Add k8s-bgp-speaker and establish iBGP session |
| `step-04-ebgp/` *(coming soon)* | Add juniper-sim and establish eBGP sessions |
| `step-05-kind-cluster/` *(coming soon)* | Create kind Kubernetes cluster |
| `step-06-metallb/` *(coming soon)* | Install MetalLB in BGP mode |
| `step-07-anycast-app/` *(coming soon)* | Deploy Anycast app pods with VIP |
| `step-08-metallb-bgp/` *(coming soon)* | Connect MetalLB BGP to juniper-sim |
| `step-09-verify/` *(coming soon)* | Full end-to-end BGP + Anycast verification |

---

## Start Here

👉 **[step-01-setup/README.md](./step-01-setup/README.md)**
