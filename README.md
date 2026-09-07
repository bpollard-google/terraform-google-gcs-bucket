# terraform-google-gcs-bucket

A Cloud Storage bucket with the defaults serviceops expects: versioning on,
uniform bucket-level access on, and no IAM bindings unless you ask for them.

## Usage

```hcl
module "bucket" {
  source = "github.com/YOUR_ORG/terraform-google-gcs-bucket?ref=v1.0.0"

  name       = "my-bucket"
  project_id = "my-project"

  labels = {
    team = "serviceops"
  }
}
```

See [`examples/basic`](examples/basic) for the minimum, and
[`examples/complete`](examples/complete) for every option.

## Labels

The module applies its own default labels to every bucket:

| Label | Value |
|---|---|
| `managed-by` | `terraform` |
| `module` | `gcs-bucket` |

Labels passed via the `labels` variable are merged with these defaults.
**Where a label is set in both, the value you pass wins** — the defaults are
a floor, not an override, so a team can retag a bucket without editing the
module.

## Lifecycle rules

`lifecycle_rules` are applied in the order given. Each rule needs an
`action_type` of `Delete`, `SetStorageClass` or
`AbortIncompleteMultipartUpload`, plus at least one condition.

## Security scanning

`make security` runs Checkov against the committed `.checkov.baseline`. One
finding is baselined:

| Check | Why it is accepted |
|---|---|
| `CKV_GCP_114` | The module does not set `public_access_prevention`; serviceops enforces it centrally through organisation policy instead. |

A finding on a *(resource, check)* pair that is not in the baseline fails the
scan. A finding on one that is does not, however it came about.

### What suppression actually means

A Checkov baseline keys on the pair *(resource address, check ID)*. Once a pair
is suppressed it stays suppressed **whatever later causes it to fire** — the
baseline records that the pair was failing, not why. The entry above switches
`CKV_GCP_114` off for `module.bucket.google_storage_bucket.this`, so if a later
change to that resource makes the same check fail for a completely different
reason, the scan still exits 0. A baselined check is not "this specific known
issue is accepted", it is "this check is off for this resource". Treat adding
one as switching a check off.

## Testing

```bash
terraform init -backend=false
terraform test
```

Tests use `mock_provider`, so they need no Google Cloud credentials and run
in seconds.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.0, < 7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 6.50.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_storage_bucket.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_iam_member.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Whether Terraform may delete a bucket that still contains objects. Defaults to false. | `bool` | `false` | no |
| <a name="input_iam_bindings"></a> [iam\_bindings](#input\_iam\_bindings) | Map of IAM role to the list of members granted that role on this bucket. | `map(list(string))` | `{}` | no |
| <a name="input_kms_key_name"></a> [kms\_key\_name](#input\_kms\_key\_name) | Fully qualified Cloud KMS key used to encrypt objects. Google-managed encryption is used when null. | `string` | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels applied to the bucket. Merged with the module's default labels; values supplied here take precedence. | `map(string)` | `{}` | no |
| <a name="input_lifecycle_rules"></a> [lifecycle\_rules](#input\_lifecycle\_rules) | Lifecycle rules applied to objects in the bucket, evaluated in order. | <pre>list(object({<br/>    action_type        = string<br/>    storage_class      = optional(string)<br/>    age                = optional(number)<br/>    num_newer_versions = optional(number)<br/>  }))</pre> | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | Location of the bucket. A region, dual-region or multi-region. | `string` | `"EU"` | no |
| <a name="input_log_bucket"></a> [log\_bucket](#input\_log\_bucket) | Bucket that receives access logs for this bucket. Access logging is disabled when null. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the bucket. Must be globally unique across all of Google Cloud Storage. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | ID of the project the bucket is created in. | `string` | n/a | yes |
| <a name="input_storage_class"></a> [storage\_class](#input\_storage\_class) | Default storage class for objects in the bucket. | `string` | `"STANDARD"` | no |
| <a name="input_uniform_bucket_level_access"></a> [uniform\_bucket\_level\_access](#input\_uniform\_bucket\_level\_access) | Whether uniform bucket-level access is enabled, disabling per-object ACLs. Defaults to true. | `bool` | `true` | no |
| <a name="input_versioning_enabled"></a> [versioning\_enabled](#input\_versioning\_enabled) | Whether object versioning is enabled. Defaults to true so that accidental deletions are recoverable. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_iam_members"></a> [iam\_members](#output\_iam\_members) | Keys of the IAM member bindings created on this bucket. |
| <a name="output_id"></a> [id](#output\_id) | Terraform identifier for the bucket. |
| <a name="output_name"></a> [name](#output\_name) | Name of the bucket. |
| <a name="output_self_link"></a> [self\_link](#output\_self\_link) | URI of the bucket. |
| <a name="output_url"></a> [url](#output\_url) | Base gs:// URL of the bucket. |
<!-- END_TF_DOCS -->

## Contributing

Raise a change request through the module registry, or open an issue on this
repository using the change request template.
