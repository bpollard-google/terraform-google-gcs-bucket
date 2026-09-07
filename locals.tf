locals {
  default_labels = {
    managed-by = "terraform"
    module     = "gcs-bucket"
  }

  labels = merge(var.labels, local.default_labels)
}

locals {
  iam_members = merge([
    for role, members in var.iam_bindings : {
      for member in members :
      "${role} ${member}" => {
        role   = role
        member = member
      }
    }
  ]...)
}
