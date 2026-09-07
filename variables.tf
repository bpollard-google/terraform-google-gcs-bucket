variable "name" {
  description = "Name of the bucket. Must be globally unique across all of Google Cloud Storage."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9._-]{1,61}[a-z0-9]$", var.name))
    error_message = "Bucket name must be 3-63 characters of lowercase letters, numbers, dots, hyphens or underscores, and must start and end with a letter or number."
  }
}

variable "project_id" {
  description = "ID of the project the bucket is created in."
  type        = string
}

variable "location" {
  description = "Location of the bucket. A region, dual-region or multi-region."
  type        = string
  default     = "EU"
}

variable "storage_class" {
  description = "Default storage class for objects in the bucket."
  type        = string
  default     = "STANDARD"

  validation {
    condition     = contains(["STANDARD", "NEARLINE", "COLDLINE", "ARCHIVE"], var.storage_class)
    error_message = "storage_class must be one of STANDARD, NEARLINE, COLDLINE or ARCHIVE."
  }
}

variable "versioning_enabled" {
  description = "Whether object versioning is enabled. Defaults to true so that accidental deletions are recoverable."
  type        = bool
  default     = true
}

variable "uniform_bucket_level_access" {
  description = "Whether uniform bucket-level access is enabled, disabling per-object ACLs. Defaults to true."
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Whether Terraform may delete a bucket that still contains objects. Defaults to false."
  type        = bool
  default     = false
}

variable "labels" {
  description = "Labels applied to the bucket. Merged with the module's default labels; values supplied here take precedence."
  type        = map(string)
  default     = {}
}

variable "lifecycle_rules" {
  description = "Lifecycle rules applied to objects in the bucket, evaluated in order."
  type = list(object({
    action_type        = string
    storage_class      = optional(string)
    age                = optional(number)
    num_newer_versions = optional(number)
  }))
  default = []

  validation {
    condition = alltrue([
      for rule in var.lifecycle_rules :
      contains(["Delete", "SetStorageClass", "AbortIncompleteMultipartUpload"], rule.action_type)
    ])
    error_message = "Each lifecycle rule action_type must be Delete, SetStorageClass or AbortIncompleteMultipartUpload."
  }
}

variable "kms_key_name" {
  description = "Fully qualified Cloud KMS key used to encrypt objects. Google-managed encryption is used when null."
  type        = string
  default     = null
}

variable "log_bucket" {
  description = "Bucket that receives access logs for this bucket. Access logging is disabled when null."
  type        = string
  default     = null
}

variable "iam_bindings" {
  description = "Map of IAM role to the list of members granted that role on this bucket."
  type        = map(list(string))
  default     = {}
}
