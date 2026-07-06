# Coldaine K8s Platform - IcePanel Model Summary

> Landscape: **Coldaine K8s Platform** | 42 objects | 53 connections | 4 ADRs
> View: https://s.icepanel.io/X2VnPbMptly6uq
> Landscape ID: `JyXDiYoXVfa7Xz3AnEfY` | Version: `zPWrGuRupxcXQnncM73e`
> Source: `D:\_projects\coldaine-k8cluster-redoALL`

## Purpose

The deep-dive C4 model of the homelab Kubernetes platform, organized by the four declarative layers from `docs/architecture.md`.

## Layered structure (4 systems under the domain)

| Layer | Status | Declared in | Applied with | Key objects |
|---|---|---|---|---|
| Host Substrate | live | `tofu/` | `tofu apply` | Proxmox VE 9, EVO-X2 Qwen 3.6 LXC sidecar (192.168.30.31:8080) |
| Node OS | live (worker NotReady - R-101) | `talos/` | `talhelper genconfig` | Talos Linux |
| Platform | live (C partial) | `platform/`, `builds/` | `helmfile apply` | Cilium (CNI + Gateway API), Longhorn, CloudNativePG, KubeBlocks (FalkorDB), ESO + Doppler, Shipwright, Garage S3, cert-manager, observability (ADR 0015) |
| Apps | mixed | `apps/` | kubectl apply | soil-web (live, drifted), home-app / moosegoose-web / frigate (declared, NOT deployed - future) |

## Stores modeled

- Longhorn PVCs, CNPG Postgres, FalkorDB, Garage S3 (backups), Doppler (external secrets source)

## Delivery chain

git -> tofu -> Proxmox | git -> talhelper -> Talos | git -> helmfile -> platform operators | git -> kubectl -> apps

## ADRs mirrored (4, all accepted)

- **ADR 0001** Proxmox + Talos (reproducible host + node)
- **ADR 0002** Git-as-plan (no selfHeal) + CloudNativePG
- **ADR 0006** One Helmfile, maintained charts only (with documented exception process)
- **ADR 0011** Apps as Kustomize manifests, copy `apps/_template/`

## Tags

- **Layer:** host / node / platform / app
- **Status:** live (37) / future (4) / deprecated

## Notable findings

- **Explicitly NOT GitOps.** ADR 0002 chose git-as-plan with deliberate apply and no selfHeal - drift is made visible on purpose, born from a previous cluster that "looked installed while quietly diverging from git."
- **Known-broken, reckoned state as of 2026-06-30.** EVO-X2 worker NotReady (R-101); pg18 NotReady with broken backups because the pinned image predates `barman-cli-cloud` (R-302); only soil-web is live and it has drifted (RollingUpdate vs git Recreate, `:latest` vs digest, 0/1 Available).
- **Postgres on CNPG is a temporary bridge** for PG19 (KubeBlocks tops out at PG18); strategic endgame is one KubeBlocks multi-engine operator.
- **Garage replaced MinIO** (ADR 0012) - MinIO was archived/no-longer-maintained Feb 2026; Garage is the first recorded manifest exception under ADR 0006.
- **LLM sidecar is deliberately outside Kubernetes** (ADR 0014) - Qwen 3.6 as a Proxmox LXC on Mesa RADV/Vulkan to isolate the GPU failure domain.
- **ADR 0017 (same-day) carves an agent exception** into the "no hand kubectl" rule: a full-write Kubernetes MCP server with scoped RBAC + a cluster-status ConfigMap every agent session reads at start - "findings have gravity."
