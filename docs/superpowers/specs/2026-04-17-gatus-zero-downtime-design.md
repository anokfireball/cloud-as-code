# Gatus Zero-Downtime Design

## Goal

Eliminate user-visible `503` windows during Gatus application rollouts and planned control-plane node upgrades in the OCI cluster.

## Decisions

- Keep Gatus single-active in steady state because upstream Gatus has no leader election or active/passive mode.
- Make Envoy Gateway highly available at both the control plane and data plane layers.
- Keep CNPG as the database HA layer and tune planned primary updates for faster handoff.
- Use a transient runtime maintenance overlay for Gatus so duplicate alerts are suppressed during the temporary two-pod handoff window.

## Target State

### Envoy Gateway

- Envoy Gateway control plane runs `2` replicas.
- Managed Envoy proxy runs `3` replicas, spread across the three control-plane nodes.
- Both layers use disruption budgets and scheduling spread so a single node drain does not remove all ingress capacity.

### Gatus

- Steady state remains `1` replica.
- Gatus continues to use Kubernetes rolling replacement, which yields a temporary surge pod during rollout because `replicas: 1` with default rolling update semantics results in one surge pod and zero unavailable pods.
- Gatus reads configuration from `/config` as a directory instead of a single file path.
- A second ConfigMap is mounted under `/config/runtime` and carries only the transient maintenance overlay.
- `storage.caching` is disabled so the temporary overlap does not serve stale cached database state from two processes.
- A PDB keeps voluntary disruption from evicting the only Gatus pod unless the handoff automation has already moved it.

### CNPG

- Keep `instances: 3`, PDB enabled, and required anti-affinity.
- Change `primaryUpdateMethod` to `switchover`.
- Bound `switchoverDelay` to a lower value than the default so planned primary updates do not linger for an hour.

## Automation Design

### App Rollouts

Argo hook jobs manage the Gatus maintenance overlay during application syncs.

1. A `PreSync` hook writes a short maintenance window into the runtime ConfigMap.
2. The hook waits one Gatus reload interval so the running pod observes maintenance before rollout starts.
3. The Helm-rendered Deployment rolls normally, creating a temporary second pod.
4. A `PostSync` hook resets the runtime ConfigMap back to `enabled: false` after rollout succeeds.
5. A `SyncFail` hook also resets the runtime ConfigMap so a failed sync does not leave maintenance enabled.

### Planned Node Upgrades

The system-upgrade-controller `prepare` step migrates Gatus away from the node before drain begins.

1. Detect whether the target node currently hosts the active Gatus pod.
2. If not, do nothing.
3. If yes, add a temporary `NoSchedule` taint to the target node.
4. Write the runtime maintenance overlay and wait for Gatus reload.
5. Trigger `kubectl rollout restart deployment/gatus`.
6. Wait for rollout completion and verify the remaining Gatus pod is now on a different node.
7. Reset the maintenance overlay to `enabled: false`.
8. Wait one reload interval so maintenance clears before drain continues.
9. Remove the temporary taint and allow the normal SUC drain to proceed.

This keeps the duplicate-check window inside maintenance and ensures drain never starts while the only Gatus pod still lives on the drained node.

## GitOps Rules

- The baseline runtime ConfigMap is Git-managed.
- Argo ignores the `maintenance.yaml` field of that ConfigMap so runtime automation can patch it without immediate self-heal rollback.
- Argo also ignores the runtime restart annotations added by `kubectl rollout restart` and Stakater Reloader.

## Verification

- Validate all edited YAML with `kubectl apply --dry-run=server` where possible.
- Validate the Envoy resources and Gatus path manifests independently.
- Validate the SUC Plan schema after adding `prepare`.
- Decrypt and verify the Gatus SOPS file after toggling `storage.caching`.
