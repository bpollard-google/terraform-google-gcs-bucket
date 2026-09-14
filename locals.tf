# Replaces the module's locals.tf on the fallback branch.
#
# The merge order is the correction: var.labels goes last, so caller-supplied
# labels win over the module defaults, which is what the README and
# variables.tf both promise. The iam_members flattening is carried over
# unchanged — this file replaces the whole of the module's locals.tf, so
# dropping it would delete the IAM bindings.

locals {
  default_labels = {
    managed-by = "terraform"
    module     = "gcs-bucket"
  }

  labels = merge(local.default_labels, var.labels)

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
