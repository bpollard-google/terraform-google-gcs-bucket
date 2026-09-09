# Full usage: every optional feature the module exposes.

# The project is a variable rather than a literal so the nightly real-GCP
# tiers can plan and apply this example against the sandbox project. The
# mock-provider tests ignore the value entirely.
variable "project_id" {
  description = "Project the example resources are created in."
  type        = string
  default     = "serviceops-demo"
}

module "bucket" {
  source = "../../"

  name          = "serviceops-example-complete"
  project_id    = var.project_id
  location      = "europe-west2"
  storage_class = "STANDARD"

  versioning_enabled          = true
  uniform_bucket_level_access = true
  force_destroy               = false

  labels = {
    team        = "serviceops"
    environment = "demo"
    cost-centre = "platform"
  }

  lifecycle_rules = [
    {
      action_type = "SetStorageClass"
      # Move objects to cheaper storage after 30 days.
      storage_class = "NEARLINE"
      age           = 30
    },
    {
      action_type = "Delete"
      # Delete objects entirely after a year.
      age = 365
    },
  ]

  retention_policy = {
    retention_period_days = 365
    is_locked             = false
  }

  log_bucket = "serviceops-example-access-logs"

  iam_bindings = {
    "roles/storage.objectViewer" = [
      "group:data-readers@example.com",
    ]
    "roles/storage.objectAdmin" = [
      "group:platform-engineering@example.com",
    ]
  }
}

output "bucket_name" {
  description = "Name of the created bucket."
  value       = module.bucket.name
}

output "bucket_url" {
  description = "Base gs:// URL of the created bucket."
  value       = module.bucket.url
}

output "iam_members" {
  description = "IAM bindings applied to the bucket."
  value       = module.bucket.iam_members
}
