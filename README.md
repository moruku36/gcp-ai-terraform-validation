# GCP AI Terraform Validation

[English](README.md) | [日本語](README.ja.md)

A Google Cloud-native AI-assisted Terraform experiment covering regional managed instance groups, global external load balancing, IAM, workload federation, GCS state, monitoring, and cleanup.

## Validation scope

The experiment follows bootstrap, core web infrastructure, state migration, federated GitHub CI/CD, monitoring, failure testing, and cleanup. Google Cloud-specific decisions include regional managed instance groups, a global external Application Load Balancer, IAM, workload federation, and GCS backend locking.

Start with the [multi-cloud final comparison](docs/10-multi-cloud-final-report.md), then the provider-specific records in `docs/`. It is not a direct service-name translation of the AWS or Azure architecture.


## Contents

- [bootstrap/](bootstrap)
- [docs/](docs)

## Detailed documentation

The [Japanese guide](README.ja.md) retains the complete original setup instructions, configuration, examples, project status, and limitations. Supporting documents keep their existing language.
