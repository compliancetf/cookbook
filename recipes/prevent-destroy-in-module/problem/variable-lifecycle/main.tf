# Attempt 2: fork the module and make prevent_destroy an input.
# Terraform rejects variables inside lifecycle, so every consumer that wants
# a different value needs a different copy of the resource.
variable "prevent_destroy" {
  type    = bool
  default = true
}

resource "terraform_data" "bucket" {
  lifecycle {
    prevent_destroy = var.prevent_destroy
  }
}
