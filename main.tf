provider "aws" {
  region = "eu-west-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Create an S3 bucket
resource "aws_s3_bucket" "web_bucket" {
  bucket = var.s3_bucket
}

resource "aws_s3_bucket_versioning" "web_versioning" {
  bucket = aws_s3_bucket.web_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Create a Dynamo DB Table
resource "aws_dynamodb_table_item" "subscriptions" {
  table_name = aws_dynamodb_table.hadou_db.name
  hash_key   = aws_dynamodb_table.hadou_db.hash_key
  range_key  = aws_dynamodb_table.hadou_db.range_key

  item = <<ITEM
{
  "subkey": {"S": "platinum"},
  "dragonhashkey": {"S": "gold"},
  "two": {"N": "22222"},
  "three": {"N": "33333"},
  "four": {"N": "44444"}
}
ITEM
}

resource "aws_dynamodb_table" "hadou_db" {
  name           = var.dynamodb_table
  read_capacity  = 10
  write_capacity = 10
  hash_key       = "subkey"
  range_key      = "dragonhashkey"

  attribute {
    name = "dragonhashkey"
    type = "S"
  }
  attribute {
    name = "subkey"
    type = "S"
  }
}



# Create a IAM s3 policy
resource "aws_iam_policy" "s3_policy" {
  name        = "s3-bucket-policy"
  description = "For the S3 bucket"
  policy      = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ListObjectsInBucket",
            "Effect": "Allow",
            "Action": ["s3:ListBucket", 
                       "s3:CreateBucket",
                       "s3:PutBucketPolicy",
                       "s3:PutBucketTagging"],
            "Resource": ["arn:aws:s3:::var.s3_bucket"]
        },
        {
            "Sid": "AllObjectActions",
            "Effect": "Allow",
            "Action": "s3:*Object",
            "Resource": ["arn:aws:s3:::var.s3_bucket/*"]
        }
    ]
  }
  EOF
}

resource "aws_iam_policy" "dynamodb_policy" {
  name        = "dynamodb-table-policy"
  description = "For the dynamodb"
  policy      = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "DynamoDBIndexAndStreamAccess",
            "Effect": "Allow",
            "Action": [
                "dynamodb:GetShardIterator",
                "dynamodb:Scan",
                "dynamodb:Query",
                "dynamodb:DescribeStream",
                "dynamodb:GetRecords",
                "dynamodb:ListStreams"
            ],
            "Resource": [
                "arn:aws:dynamodb:eu-west-1:123456789012:table/Books/index/*",
                "arn:aws:dynamodb:eu-west-1:123456789012:table/Books/stream/*"
            ]
        },
        {
            "Sid": "DynamoDBTableAccess",
            "Effect": "Allow",
            "Action": [
                "dynamodb:BatchGetItem",
                "dynamodb:BatchWriteItem",
                "dynamodb:ConditionCheckItem",
                "dynamodb:PutItem",
                "dynamodb:DescribeTable",
                "dynamodb:DeleteItem",
                "dynamodb:GetItem",
                "dynamodb:Scan",
                "dynamodb:Query",
                "dynamodb:UpdateItem"
            ],
            "Resource": "arn:aws:dynamodb:eu-west-1:123456789012:table/Books"
        },
        {
            "Sid": "DynamoDBDescribeLimitsAccess",
            "Effect": "Allow",
            "Action": "dynamodb:DescribeLimits",
            "Resource": [
                "arn:aws:dynamodb:eu-west-1:123456789012:table/Books",
                "arn:aws:dynamodb:eu-west-1:123456789012:table/Books/index/*"
            ]
        }
    ]
  }
  EOF
}


resource "aws_iam_role" "s3_bucket_role" {
  name               = var.iam_roles
  assume_role_policy = data.aws_iam_policy_document.s3_assume_role.json
}

data "aws_iam_policy_document" "s3_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    effect = "Allow"
  }
}

resource "aws_iam_role_policy_attachment" "s3-attach" {
  role       = aws_iam_role.s3_bucket_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}



resource "aws_iam_role" "dynamodb_role" {
  name               = var.iam_roles_db
  assume_role_policy = data.aws_iam_policy_document.db_assume_role.json
}


data "aws_iam_policy_document" "db_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    effect = "Allow"
  }
}

resource "aws_iam_role_policy_attachment" "db-attach" {
  role       = aws_iam_role.dynamodb_role.name
  policy_arn = aws_iam_policy.dynamodb_policy.arn
}

output "webapp_s3_bucket" {
  value = aws_s3_bucket.web_bucket.bucket
}

output "webapp_dynamodb_table" {
  value = aws_dynamodb_table.hadou_db.name
}

output "webapp_s3_bucket_role" {
  value = aws_iam_role.s3_bucket_role.arn
}

output "webapp_dynamodb_table_role" {
  value = aws_iam_role.dynamodb_role.arn
}


# OR

# Define provider and required_providers block
# provider "aws" {
#   region = "eu-west-1"
# }
# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 5.0"
#     }
#   }
# }

# # S3 Bucket for static assets
# resource "aws_s3_bucket" "webapp_assets" {
#   bucket        = var.webapp_s3_bucket_name
#   force_destroy = true

# }
# resource "aws_s3_bucket_versioning" "webapp_versioning" {
#   bucket = aws_s3_bucket.webapp_assets.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# resource "aws_s3_bucket_ownership_controls" "webapp_storage" {
#   bucket = aws_s3_bucket.webapp_assets.id
#   rule {
#     object_ownership = "BucketOwnerPreferred"
#   }
# }

# resource "aws_s3_bucket_acl" "webapp_storage" {
#   depends_on = [aws_s3_bucket_ownership_controls.webapp_storage]
#   bucket     = aws_s3_bucket.webapp_assets.id
#   acl        = "private"
# }

# # DynamoDB Table for application data
# resource "aws_dynamodb_table" "webapp_data" {
#   name         = var.webapp_dynamodb_table_name
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key     = "id"

#   attribute {
#     name = "id"
#     type = "S"
#   }
# }

# # IAM Role and Policy for web application access
# resource "aws_iam_role" "webapp_access_role" {
#   name = var.webapp_iam_role_name

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "sts:AssumeRole",
#         Principal = {
#           Service = "ec2.amazonaws.com",
#         },
#         Effect = "Allow",
#       },
#     ]
#   })
# }

# resource "aws_iam_policy" "webapp_access_policy" {
#   name = "${var.webapp_iam_role_name}-policy"
#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = [
#           "s3:GetObject",
#           "s3:PutObject",
#           "dynamodb:GetItem",
#           "dynamodb:PutItem"
#         ],
#         Resource = [
#           "${aws_s3_bucket.webapp_assets.arn}/*",
#           "${aws_dynamodb_table.webapp_data.arn}"
#         ],
#         Effect = "Allow",
#       },
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "webapp_policy_attach" {
#   role       = aws_iam_role.webapp_access_role.name
#   policy_arn = aws_iam_policy.webapp_access_policy.arn
# }

# # Outputs
# output "webapp_s3_bucket_name" {
#   value = aws_s3_bucket.webapp_assets.bucket
# }

# output "webapp_dynamodb_table_name" {
#   value = aws_dynamodb_table.webapp_data.name
# }

# output "webapp_iam_role_arn" {
#   value = aws_iam_role.webapp_access_role.arn
# }
