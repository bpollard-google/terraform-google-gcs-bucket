output "name" {
  description = "Name of the bucket."
  value       = google_storage_bucket.this.name
}

output "url" {
  description = "Base gs:// URL of the bucket."
  value       = google_storage_bucket.this.url
}

output "self_link" {
  description = "URI of the bucket."
  value       = google_storage_bucket.this.self_link
}

output "id" {
  description = "Terraform identifier for the bucket."
  value       = google_storage_bucket.this.id
}

output "iam_members" {
  description = "Keys of the IAM member bindings created on this bucket."
  value       = sort(keys(google_storage_bucket_iam_member.this))
}
