resource "spacelift_policy" "enforce-password-length" {
  space_id = "root"
  name     = "Enforce Password Length"
  body     = file("${path.module}/policies/enforce-password-length.rego")
  type     = "PLAN"
  labels   = ["autoattach:security"]
}
