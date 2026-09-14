mock_provider "google" {}

variables {
  name       = "serviceops-demo-bucket"
  project_id = "demo-project"
}

run "no_retention_policy_by_default" {
  command = plan

  assert {
    condition     = length(google_storage_bucket.this.retention_policy) == 0
    error_message = "No retention policy should be configured by default."
  }
}

run "retention_period_is_converted_to_seconds" {
  command = plan

  variables {
    retention_policy = {
      retention_period_days = 2555
    }
  }

  assert {
    condition     = google_storage_bucket.this.retention_policy[0].retention_period == 220752000
    error_message = "retention_period_days should be converted to seconds (2555 * 86400)."
  }

  assert {
    condition     = google_storage_bucket.this.retention_policy[0].is_locked == false
    error_message = "is_locked must default to false; locking is irreversible."
  }
}

run "lock_is_opt_in" {
  command = plan

  variables {
    retention_policy = {
      retention_period_days = 30
      is_locked             = true
    }
  }

  assert {
    condition     = google_storage_bucket.this.retention_policy[0].is_locked == true
    error_message = "is_locked should be honoured when explicitly set."
  }
}

run "rejects_a_retention_period_over_ten_years" {
  command = plan

  variables {
    retention_policy = {
      retention_period_days = 4000
    }
  }

  expect_failures = [var.retention_policy]
}
