variable "s3_bucket" {
  description = "s3 bucket"
  type        = string
  default     = "terraform-state-dragon-hadou"
}

variable "dynamodb_table" {
  type    = string
  default = "state-locking"
}


variable "iam_roles" {
  description = "Techs who have Authorization roles"
  type        = string
  default     = "YahshuaTheBlackSwordsman"
}

variable "iam_roles_db" {
  description = "Techs who have Authorization roles"
  type        = string
  default     = "Theomalgus"
}


# OR

# variable "webapp_s3_bucket_name" {
#   description = "S3 bucket for web application static assets"
#   type        = string
#   default     = "webapp-assets301"
# }

# variable "webapp_dynamodb_table_name" {
#   description = "DynamoDB table for web application data"
#   type        = string
#   default     = "webapp-table302"
# }

# variable "webapp_iam_role_name" {
#   description = "IAM role for web application access"
#   type        = string
#   default     = "web-iamrole303"
# }
