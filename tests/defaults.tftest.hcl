mock_provider "google" {}

variables {
  name       = "serviceops-demo-bucket"
  project_id = "demo-project"
}

run "defaults_are_safe" {
  command = plan

  assert {
    condition     = google_storage_bucket.this.name == "serviceops-demo-bucket"
    error_message = "Bucket name should be passed through unchanged."
  }

  assert {
    condition     = google_storage_bucket.this.location == "EU"
    error_message = "Default location should be EU."
  }

  assert {
    condition     = google_storage_bucket.this.storage_class == "STANDARD"
    error_message = "Default storage class should be STANDARD."
  }

  assert {
    condition     = google_storage_bucket.this.uniform_bucket_level_access == true
    error_message = "Uniform bucket-level access must default to true."
  }

  assert {
    condition     = google_storage_bucket.this.force_destroy == false
    error_message = "force_destroy must default to false."
  }

  assert {
    condition     = google_storage_bucket.this.versioning[0].enabled == true
    error_message = "Versioning must default to enabled."
  }
}

run "overrides_are_honoured" {
  command = plan

  variables {
    location                    = "US"
    storage_class               = "NEARLINE"
    versioning_enabled          = false
    uniform_bucket_level_access = false
    force_destroy               = true
  }

  assert {
    condition     = google_storage_bucket.this.location == "US"
    error_message = "location override was ignored."
  }

  assert {
    condition     = google_storage_bucket.this.storage_class == "NEARLINE"
    error_message = "storage_class override was ignored."
  }

  assert {
    condition     = google_storage_bucket.this.versioning[0].enabled == false
    error_message = "versioning_enabled override was ignored."
  }
}
