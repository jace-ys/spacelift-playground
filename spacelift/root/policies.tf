resource "spacelift_policy" "enforce-password-length" {
  name   = "Enforce Password Length"
  body   = file("${path.module}/policies/enforce-password-length.rego")
  type   = "PLAN"
  labels = ["autoattach:security"]
}
