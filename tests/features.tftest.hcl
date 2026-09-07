mock_provider "google" {}

variables {
  name       = "serviceops-demo-bucket"
  project_id = "demo-project"
}

run "lifecycle_rules_are_rendered" {
  command = plan

  variables {
    lifecycle_rules = [
      {
        action_type        = "Delete"
        storage_class      = null
        age                = 365
        num_newer_versions = 3
      },
      {
        action_type        = "SetStorageClass"
        storage_class      = "NEARLINE"
        age                = 30
        num_newer_versions = null
      }
    ]
  }

  assert {
    condition     = length(google_storage_bucket.this.lifecycle_rule) == 2
    error_message = "Both lifecycle rules should be rendered."
  }

  assert {
    condition     = one(google_storage_bucket.this.lifecycle_rule[0].action).type == "Delete"
    error_message = "First rule should be a Delete action."
  }

  assert {
    condition     = one(google_storage_bucket.this.lifecycle_rule[0].condition).age == 365
    error_message = "First rule should apply at 365 days."
  }

  assert {
    condition     = one(google_storage_bucket.this.lifecycle_rule[0].condition).num_newer_versions == 3
    error_message = "First rule should keep three newer versions."
  }

  assert {
    condition     = one(google_storage_bucket.this.lifecycle_rule[1].action).storage_class == "NEARLINE"
    error_message = "Second rule should transition to NEARLINE."
  }
}

run "no_lifecycle_rules_by_default" {
  command = plan

  assert {
    condition     = length(google_storage_bucket.this.lifecycle_rule) == 0
    error_message = "No lifecycle rules should be configured by default."
  }
}

run "cmek_is_configured_when_key_supplied" {
  command = plan

  variables {
    kms_key_name = "projects/demo-project/locations/europe-west1/keyRings/r/cryptoKeys/k"
  }

  assert {
    condition     = google_storage_bucket.this.encryption[0].default_kms_key_name == "projects/demo-project/locations/europe-west1/keyRings/r/cryptoKeys/k"
    error_message = "CMEK key should be applied to the bucket."
  }
}

run "no_encryption_block_without_a_key" {
  command = plan

  assert {
    condition     = length(google_storage_bucket.this.encryption) == 0
    error_message = "No encryption block should be emitted when kms_key_name is null."
  }
}

run "logging_is_configured_when_bucket_supplied" {
  command = plan

  variables {
    log_bucket = "serviceops-access-logs"
  }

  assert {
    condition     = google_storage_bucket.this.logging[0].log_bucket == "serviceops-access-logs"
    error_message = "Logging should target the supplied bucket."
  }
}

run "iam_bindings_expand_to_one_member_each" {
  command = plan

  variables {
    iam_bindings = {
      "roles/storage.objectViewer" = [
        "group:data-readers@example.com",
        "serviceAccount:etl@demo-project.iam.gserviceaccount.com",
      ]
      "roles/storage.objectAdmin" = [
        "group:platform@example.com",
      ]
    }
  }

  assert {
    condition     = length(google_storage_bucket_iam_member.this) == 3
    error_message = "Three individual IAM member resources should be created."
  }

  assert {
    condition     = google_storage_bucket_iam_member.this["roles/storage.objectAdmin group:platform@example.com"].role == "roles/storage.objectAdmin"
    error_message = "IAM member should be keyed by role and member, and carry the right role."
  }
}

run "no_iam_members_by_default" {
  command = plan

  assert {
    condition     = length(google_storage_bucket_iam_member.this) == 0
    error_message = "No IAM members should be created by default."
  }
}
