# Kyverno + VictoriaMetrics Demo

## 🎯 Overview

This demo shows how to:

- Enforce Kubernetes policies using Kyverno
- Collect policy metrics with vmagent
- Store them in VictoriaMetrics
- Visualize everything in Grafana

---

## 🏗 Architecture

Kyverno → vmagent → VictoriaMetrics → Grafana

---

## 🚀 Quick Start

```bash
./scripts/setup-all.sh

```

---

## 🚀 Demo

```bash
./scripts/demo-flow.sh

```
---

## 📊 Key Metrics

- kyverno_admission_requests_total
- allowed vs denied requests
- per resource type (Pod, Deployment, etc.)
- per operation (create/update/delete)
- kyverno_policy_results_total
- policy execution results (pass/fail)
- rule-level visibility
- enforcement tracking
- kyverno_policy_execution_duration_seconds
- policy evaluation latency
- rule execution performance

---

## 🧩 Policies Included

This demo includes 5 Kyverno policy types:

- Validation Policy
- Enforces required labels on workloads
- Mutation Policy
- Automatically injects observability labels
- Generation Policy
- Creates ConfigMaps automatically per namespace
- Image Validation Policy
- Restricts allowed container images
- Delete Protection Policy
- Prevents unsafe deletion of Deployments

---

## 📊 Grafana Dashboard

Import: 06-grafana/dashboard.json

Dashboard shows:

- Admission request volume over time
- Allowed vs denied operations
- Policy execution results
- Resource-level enforcement (Pod, Deployment, ReplicaSet)
- Policy behavior trends

---

## 🧪 Demo Flow

- Show Kyverno policies installed
- Observe live admission metrics
- Deploy valid Kubernetes workload
- Deploy invalid workload (blocked by policy)
- Observe mutation of workloads
- Inspect metrics in VictoriaMetrics
- Visualize everything in Grafana

---

## 📦 Repo Structure

- 02-vmagent/ vmagent configuration
- 03-kyverno/ Kyverno installation scripts
- 04-policies/ Kyverno policies
- 05-demo-app/ Kubernetes workloads for demo
- 06-grafana/ Grafana dashboard
- scripts/ setup + demo automation
