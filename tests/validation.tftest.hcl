mock_provider "google" {}

variables {
  name       = "serviceops-demo-bucket"
  project_id = "demo-project"
}

run "rejects_uppercase_name" {
  command = plan
  variables {
    name = "Serviceops-Demo-Bucket"
  }
  expect_failures = [var.name]
}

run "rejects_short_name" {
  command = plan
  variables {
    name = "ab"
  }
  expect_failures = [var.name]
}

run "rejects_unknown_storage_class" {
  command = plan
  variables {
    storage_class = "GLACIER"
  }
  expect_failures = [var.storage_class]
}

run "rejects_non_positive_retention_period" {
  command = plan
  variables {
    retention_policy = {
      retention_period_days = 0
    }
  }
  expect_failures = [var.retention_policy]
}

