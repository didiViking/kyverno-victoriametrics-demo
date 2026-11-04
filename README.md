# Observing Kubernetes Policies with Kyverno and VictoriaMetrics

The repository includes the Kubernetes policy examples, deployment scripts, and a Grafana dashboard.

## 🎯 Overview

This demo explores how to make Kubernetes policy enforcement observable using Kyverno and VictoriaMetrics.

It demonstrates how to:

- Enforce Kubernetes policies using Kyverno's CEL-based policy APIs.
- Collect Kyverno metrics using vmagent.
- Store and query metrics with VictoriaMetrics Single.
- Explore admission requests and policy behavior using VictoriaMetrics VMUI and Grafana.
- Observe the difference between allowed and denied admission requests.

The examples target **Kyverno v1.19.2**.

## 🏗 Architecture

```text
Kubernetes API Server
        |
        v
      Kyverno
        |
        | Prometheus metrics (:8000)
        v
      vmagent
        |
        | Prometheus remote write
        v
 VictoriaMetrics Single
        |
        +----> VictoriaMetrics VMUI
        |
        +----> Grafana
```

Kyverno exposes metrics that vmagent scrapes and forwards to VictoriaMetrics. Grafana queries VictoriaMetrics through a Prometheus-compatible datasource.

## 🚀 Quick Start

### Prerequisites

- A running Kubernetes cluster
- kubectl
- Helm
- curl and jq
- A local VictoriaMetrics endpoint accessible at `http://localhost:8428` for the demo script
- Grafana, if you want to import the dashboard

### 1. Install the environment

```bash
./scripts/setup-all.sh
```

The setup script:

- Installs VictoriaMetrics Single.
- Installs vmagent using the repository configuration.
- Installs Kyverno v1.19.2.
- Waits for Kyverno controllers and policy APIs.
- Creates the `demo-ns` namespace.

The script does not automatically apply the policies.

### 2. Run the demo

```bash
./scripts/demo-flow.sh
```

The demo script applies the policies, creates the signed-image Pod, attempts to create the unsigned-image Pod, and queries admission metrics.

**Note:** The script expects VictoriaMetrics to be reachable at `http://localhost:8428`. If the service is not exposed locally, use port-forwarding:

```bash
kubectl port-forward svc/vm-victoria-metrics-single-server 8428:8428
```

Run this in a separate terminal before starting the demo.

### 3. Clean up

```bash
./scripts/cleanup.sh
```

This removes the named demo policies, the `demo-ns` namespace, and the VictoriaMetrics Helm releases.

Kyverno remains installed.

## 🧩 Kyverno Policies Included

The repository includes five CEL-based Kyverno policy types.

| Policy type | Demo behavior |
|---|---|
| `ValidatingPolicy` | Requires `app`, `environment`, and `team` labels on Pods |
| `MutatingPolicy` | Adds observability-related labels to Pods |
| `GeneratingPolicy` | Generates a ConfigMap when a matching namespace is created |
| `ImageValidatingPolicy` | Verifies container image signatures using Cosign |
| `DeletingPolicy` | Deletes a matching temporary ConfigMap on a schedule |

### Validation and mutation

The validation policy requires three labels on Pods:

- `app`
- `environment`
- `team`

The mutation policy demonstrates how labels can be added automatically before validation.

### Image signature verification

Two example Pod manifests demonstrate image signature verification.

**Signed image — expected to be admitted:**

```bash
kubectl apply -f 05-demo-app/good-pod.yaml
```

Image:

`ghcr.io/kyverno/test-verify-image:signed`

**Unsigned image — expected to be denied:**

```bash
kubectl apply -f 05-demo-app/bad-pod.yaml
```

Image:

`docker.io/library/busybox:latest`

Both examples include the required labels, so the image verification test focuses on signature validation rather than missing labels.

Successful verification depends on the configured Cosign public key matching the signed test image.

### ConfigMap generation

The `GeneratingPolicy` example generates a ConfigMap when a matching namespace is created.

To reproduce the namespace-creation event, the policy must be installed before creating the target namespace.

### Scheduled cleanup

The `DeletingPolicy` example identifies a temporary ConfigMap for scheduled deletion.

This is **scheduled resource cleanup**, not a policy that blocks Kubernetes DELETE operations.

The Kyverno cleanup controller must have the necessary Kubernetes RBAC permissions to delete the resource.

## 📊 Key Metrics

### Admission requests

`kyverno_admission_requests_total`

Tracks admission requests handled by Kyverno.

Example — admission request rate grouped by allowed/denied outcome:

```promql
sum by (request_allowed) (
  rate(kyverno_admission_requests_total[5m])
)
```

### Requests by operation

```promql
sum by (resource_request_operation) (
  rate(kyverno_admission_requests_total[5m])
)
```

### Requests by resource kind

```promql
sum by (resource_kind) (
  rate(kyverno_admission_requests_total[5m])
)
```

### Policy results

Kyverno also exposes metrics for individual CEL-based policy types, including validating, mutating, and image-validating policies.

These provide additional visibility beyond admission request counts.

Admission metrics should not be interpreted as direct measurements of background generation or scheduled deletion.

## 📊 Grafana Dashboard

Dashboard file:

`06-grafana/kyverno-policy-observability.json`

The updated dashboard contains seven panels:

1. Total Admission Requests
2. Allowed Requests
3. Denied Requests
4. Requests Over Time
5. Requests by Operation
6. Requests by Resource Kind
7. Image Validation Results

### Importing the dashboard

1. Open Grafana.
2. Navigate to **Dashboards → New → Import**.
3. Upload the JSON file.
4. Select your VictoriaMetrics Prometheus-compatible datasource.
5. Import the dashboard.

The dashboard requires collected Kyverno metrics to display results. Without historical or live data, the panels may show *No data*.

### Conference recording

The accompanying conference recording shows the original live demonstration.

The repository's policy examples, scripts, and Grafana dashboard have since been updated for the Kyverno 1.19.2 CEL-based APIs.

## 🧪 Demo Flow

The current automated demo follows these steps:

1. Display the available Kyverno CEL-based policy types.
2. Apply the repository's policy manifests.
3. Verify VictoriaMetrics connectivity.
4. Query admission metrics before testing.
5. Create a Pod using a signed container image.
6. Attempt to create a Pod using an unsigned image.
7. Query admission metrics after testing.
8. Inspect Pods in the demo namespace.
9. Explore the metrics in VictoriaMetrics VMUI or Grafana.

The repository also contains examples of validation, mutation, ConfigMap generation, and scheduled deletion.

The automated flow currently focuses on **image signature verification and admission observability**. It does not independently exercise every policy behavior.

## 📦 Repository Structure

```text
.
├── 02-vmagent/
│   └── vmagent-values.yaml
├── 03-kyverno/
│   └── [Kyverno installation helper]
├── 04-policies/
│   └── [Five CEL-based policy manifests]
├── 05-demo-app/
│   ├── good-pod.yaml
│   ├── bad-pod.yaml
│   └── deployment.yaml
├── 06-grafana/
│   └── kyverno-policy-observability.json
├── scripts/
│   ├── setup-all.sh
│   ├── demo-flow.sh
│   └── cleanup.sh
└── README.md
```

## ⚠️ Reproducibility Notes

- The examples target Kyverno v1.19.2.
- VictoriaMetrics Helm chart versions are not currently pinned.
- The image verification example requires a matching Cosign public key.
- Scheduled deletion requires cleanup-controller RBAC permissions.
- Policy scope and application order can affect admission results.
- The automated demo does not currently reproduce all five policy behaviors.
- The scripts and manifests should be tested together before using the repository as a fully reproducible deployment.

## 📚 Resources

- [Kyverno Documentation](https://kyverno.io/docs/)
- [VictoriaMetrics Documentation](https://docs.victoriametrics.com/)
- [vmagent Documentation](https://docs.victoriametrics.com/victoriametrics/vmagent/)
