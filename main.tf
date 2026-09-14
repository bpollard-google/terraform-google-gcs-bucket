resource "google_storage_bucket" "this" {
  name                        = var.name
  project                     = var.project_id
  location                    = var.location
  storage_class               = var.storage_class
  force_destroy               = var.force_destroy
  uniform_bucket_level_access = var.uniform_bucket_level_access
  labels                      = local.labels

  versioning {
    enabled = var.versioning_enabled
  }

  dynamic "encryption" {
    for_each = var.kms_key_name == null ? [] : [var.kms_key_name]

    content {
      default_kms_key_name = encryption.value
    }
  }

  dynamic "logging" {
    for_each = var.log_bucket == null ? [] : [var.log_bucket]

    content {
      log_bucket = logging.value
    }
  }

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules

    content {
      action {
        type          = lifecycle_rule.value.action_type
        storage_class = lifecycle_rule.value.storage_class
      }

      condition {
        age                = lifecycle_rule.value.age
        num_newer_versions = lifecycle_rule.value.num_newer_versions
      }
    }
  }

  dynamic "retention_policy" {
    for_each = var.retention_policy == null ? [] : [var.retention_policy]

    content {
      retention_period = retention_policy.value.retention_period_days * 86400
      is_locked        = retention_policy.value.is_locked
    }
  }
}

resource "google_storage_bucket_iam_member" "this" {
  for_each = local.iam_members

  bucket = google_storage_bucket.this.name
  role   = each.value.role
  member = each.value.member
}
