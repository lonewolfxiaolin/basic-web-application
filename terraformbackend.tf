terraform {
  backend "s3" {
    bucket       = "terraform-state-dragon-hadou"
    key          = "webapp/terraform.tfstate"
    region       = "eu-west-1"
    use_lockfile = true
    encrypt      = true
  }
}


# OR

# terraform {
#   backend "s3" {
#     bucket         = "terraform-state-webapp-301"
#     key            = "state/terraform.tfstate"
#     region         = "eu-west-1"
#     encrypt        = true
#     dynamodb_table = "terraform-state-lock-webapp-302"
#   }
# }
