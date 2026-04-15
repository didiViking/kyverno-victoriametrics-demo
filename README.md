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

---

## 🚀 Demo

```bash
./scripts/demo-flow.sh

---

## 📊 Key Metrics
kyverno_admission_requests_total
allowed vs denied requests
operations (create/update/delete)

---

## 🧩 Policies Included
Validate
Mutate (safe)
Generate
Image validation
Delete protection
