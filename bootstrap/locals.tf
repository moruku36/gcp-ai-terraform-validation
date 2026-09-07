locals {
  resource_name  = "${var.name_prefix}-${var.environment}"
  role_id_prefix = replace(local.resource_name, "-", "_")

  repository    = "${var.github_owner}/${var.github_repository}"
  pr_subject    = "repo:${local.repository}:pull_request"
  apply_subject = "repo:${local.repository}:environment:${var.github_environment}"

  common_labels = merge({
    environment = var.environment
    managed_by  = "terraform"
    purpose     = "ai-infrastructure-validation"
  }, var.labels)
}
