# SSM Managed Policy
data "aws_iam_policy" "jenkins-instance-policy-ssm" {
  arn                     = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Instance Policy S3
resource "aws_iam_policy" "jenkins-instance-policy-s3" {
  name                    = "jenkins-instance-policy-s3"
  path                    = "/"
  description             = "Provides jenkins instances access to endpoint, s3 objects/bucket"
  policy                  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ListObjectsinBucket",
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": ["${aws_s3_bucket.jenkins-bucket.arn}"]
    },
    {
      "Sid": "GetObjectsinBucketPrefix",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion"
      ],
      "Resource": ["${aws_s3_bucket.jenkins-bucket.arn}/*"]
    },
    {
      "Sid": "PutObjectsinBucketPrefix",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Resource": ["${aws_s3_bucket.jenkins-bucket.arn}/ssm/*"]
    },
    {
      "Sid": "S3CMK",
      "Effect": "Allow",
      "Action": [
        "kms:Encrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": ["${aws_kms_key.jenkins-kmscmk-s3.arn}"]
    }
  ]
}
EOF
}

# Instance Role
resource "aws_iam_role" "jenkins-instance-iam-role" {
  name                    = "jenkins-instance-profile"
  path                    = "/"
  assume_role_policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Action": "sts:AssumeRole",
          "Principal": {
             "Service": "ec2.amazonaws.com"
          },
          "Effect": "Allow",
          "Sid": ""
      }
  ]
}
EOF
}

# Instance Role Attachments
resource "aws_iam_role_policy_attachment" "jenkins-iam-attach-ssm" {
  role                    = aws_iam_role.jenkins-instance-iam-role.name
  policy_arn              = data.aws_iam_policy.jenkins-instance-policy-ssm.arn
}

resource "aws_iam_role_policy_attachment" "jenkins-iam-attach-s3" {
  role                    = aws_iam_role.jenkins-instance-iam-role.name
  policy_arn              = aws_iam_policy.jenkins-instance-policy-s3.arn
}

# Instance Profile
resource "aws_iam_instance_profile" "jenkins-instance-profile" {
  name                    = "jenkins-instance-profile"
  role                    = aws_iam_role.jenkins-instance-iam-role.name
}
