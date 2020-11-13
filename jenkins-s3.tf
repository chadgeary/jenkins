# s3 bucket
resource "aws_s3_bucket" "jenkins-bucket" {
  bucket                  = "${var.project_prefix}-bucket-${random_string.project_suffix.result}"
  acl                     = "private"
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.jenkins-kmscmk-s3.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
  force_destroy           = true
  policy                  = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "KMS Manager",
      "Effect": "Allow",
      "Principal": {
        "AWS": ["${data.aws_iam_user.jenkins-kmsmanager.arn}"]
      },
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "arn:aws:s3:::${var.project_prefix}-bucket-${random_string.project_suffix.result}",
        "arn:aws:s3:::${var.project_prefix}-bucket-${random_string.project_suffix.result}/*"
      ]
    },
    {
      "Sid": "Instance List",
      "Effect": "Allow",
      "Principal": {
        "AWS": ["${aws_iam_role.jenkins-instance-iam-role.arn}"]
      },
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": ["arn:aws:s3:::${var.project_prefix}-bucket-${random_string.project_suffix.result}"]
    },
    {
      "Sid": "Instance Get",
      "Effect": "Allow",
      "Principal": {
        "AWS": ["${aws_iam_role.jenkins-instance-iam-role.arn}"]
      },
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion"
      ],
      "Resource": ["arn:aws:s3:::${var.project_prefix}-bucket-${random_string.project_suffix.result}/*"]
    },
    {
      "Sid": "Instance Put",
      "Effect": "Allow",
      "Principal": {
        "AWS": ["${aws_iam_role.jenkins-instance-iam-role.arn}"]
      },
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Resource": [
        "arn:aws:s3:::${var.project_prefix}-bucket-${random_string.project_suffix.result}/ssm/*"
      ]
    }
  ]
}
POLICY
}

# s3 block all public access to bucket
resource "aws_s3_bucket_public_access_block" "jenkins-bucket-pubaccessblock" {
  bucket                  = aws_s3_bucket.jenkins-bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# s3 objects (playbook)
resource "aws_s3_bucket_object" "jenkins-files" {
  for_each                = fileset("jenkins/", "*")
  bucket                  = aws_s3_bucket.jenkins-bucket.id
  key                     = "jenkins/${each.value}"
  content_base64          = base64encode(file("${path.module}/jenkins/${each.value}"))
  kms_key_id              = aws_kms_key.jenkins-kmscmk-s3.arn
}
