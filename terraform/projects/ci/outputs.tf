output "example" {
  value = "Hello, world!"
}

resource "random_password" "secret" {
  length = 10
}

output "password" {
  value     = random_password.secret.result
  sensitive = true
}
