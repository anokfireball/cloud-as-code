# Gatus Zero-Downtime Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove user-visible Gatus downtime during rollouts and planned node upgrades in OCI.

**Architecture:** Make Envoy Gateway redundant, keep Gatus single-active with an automated maintenance-backed handoff, and tune CNPG planned primary updates for faster switchover. Runtime mutation is isolated to a dedicated ConfigMap and explicitly ignored by Argo CD so GitOps and automation do not fight each other.

**Tech Stack:** Argo CD, Helm multi-source Applications, Envoy Gateway, Gatus, CloudNativePG, system-upgrade-controller, SOPS

---

### Task 1: Envoy Gateway HA

**Files:**
- Modify: `argo/system/envoy-gateway.yaml`
- Modify: `argo/system/envoy-gateway/resources.yaml`

- [ ] Set Envoy Gateway control plane replicas to `2` with anti-affinity, topology spread, and `podDisruptionBudget.minAvailable: 1`.
- [ ] Set the managed Envoy proxy deployment to `3` replicas with a conservative rolling strategy, anti-affinity, topology spread, and `envoyPDB.minAvailable: 2`.
- [ ] Preserve existing OCI LoadBalancer service settings while making the data plane redundant.

### Task 2: Gatus Runtime Overlay And Drift Rules

**Files:**
- Modify: `argo/apps/gatus.yaml`
- Modify: `argo/bootstrap/apps/gatus.yaml`
- Add: `argo/apps/gatus/runtime-config.yaml`
- Add: `argo/apps/gatus/pdb.yaml`

- [ ] Point Gatus at directory-based config loading with `GATUS_CONFIG_PATH: /config`.
- [ ] Mount the runtime ConfigMap under `/config/runtime`.
- [ ] Replace broad Reloader auto-reload with secret-only reload behavior.
- [ ] Add Argo `ignoreDifferences` for the runtime maintenance ConfigMap and rollout annotations.
- [ ] Add a Gatus PDB with `minAvailable: 1`.

### Task 3: Rollout Hooks

**Files:**
- Add: `argo/apps/gatus/rollout-hooks.yaml`

- [ ] Add hook RBAC for a namespace-scoped service account that can create, update, and patch the runtime ConfigMap.
- [ ] Add a `PreSync` job that enables the maintenance overlay and waits one Gatus reload interval.
- [ ] Add `PostSync` and `SyncFail` jobs that reset the overlay to `enabled: false` and wait for reload.

### Task 4: CNPG Planned Update Tuning

**Files:**
- Modify: `argo/apps/gatus/cluster.yaml`
- Modify: `argo/secrets/gatus.sops.yaml`

- [ ] Set `primaryUpdateMethod: switchover`.
- [ ] Set a bounded `switchoverDelay`.
- [ ] Disable `storage.caching` in the encrypted Gatus config.

### Task 5: SUC Gatus Handoff

**Files:**
- Modify: `argo/system/system-upgrade-controller/plan.yaml`

- [ ] Add a `prepare` container using `rancher/kubectl`.
- [ ] Detect whether the target node currently hosts Gatus.
- [ ] If it does, taint the node, enable maintenance, wait for reload, restart the Deployment, wait for rollout to finish elsewhere, clear maintenance, wait for reload, and remove the taint.
- [ ] Leave the current drain settings unchanged after the handoff completes.

### Task 6: Verification

**Files:**
- Verify only

- [ ] Run `sops -d argo/secrets/gatus.sops.yaml | rg -n "storage:|caching:"` and confirm `caching: false`.
- [ ] Run `kubectl --context admin@oci apply --dry-run=server -f argo/apps/gatus.yaml`.
- [ ] Run `kubectl --context admin@oci apply --dry-run=server -f argo/bootstrap/apps/gatus.yaml`.
- [ ] Run `kubectl --context admin@oci apply --dry-run=server -f argo/apps/gatus/runtime-config.yaml -f argo/apps/gatus/pdb.yaml -f argo/apps/gatus/rollout-hooks.yaml -f argo/apps/gatus/cluster.yaml`.
- [ ] Run `kubectl --context admin@oci apply --dry-run=server -f argo/system/envoy-gateway.yaml -f argo/system/envoy-gateway/resources.yaml`.
- [ ] Run `kubectl --context admin@oci apply --dry-run=server -f argo/system/system-upgrade-controller/plan.yaml`.
