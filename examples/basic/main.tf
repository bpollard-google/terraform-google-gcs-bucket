# Minimal usage: a private, versioned bucket with the module's defaults.

# The project is a variable rather than a literal so the nightly real-GCP
# tiers can plan and apply this example against the sandbox project. The
# mock-provider tests ignore the value entirely.
variable "project_id" {
  description = "Project the example resources are created in."
  type        = string
  default     = "serviceops-demo"
}

variable "name_suffix" {
  description = "Suffix appended to resource names so concurrent CI runs do not collide."
  type        = string
  default     = ""
}

module "bucket" {
  source = "../../"

  name       = "serviceops-example-basic${var.name_suffix == "" ? "" : "-${var.name_suffix}"}"
  project_id = var.project_id
}

output "bucket_name" {
  description = "Name of the created bucket."
  value       = module.bucket.name
}
