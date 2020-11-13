resource "aws_kms_key" "jenkins-kmscmk-ec2" {
  description             = "Key for jenkins ec2/ebs"
  key_usage               = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation     = "true"
  tags                    = {
    Name                  = "jenkins-kmscmk-ec2"
  }
  policy                  = <<EOF
{
  "Id": "jenkins-kmskeypolicy-ec2",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${data.aws_iam_user.jenkins-kmsmanager.arn}"
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "Allow attachment of persistent resources",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.jenkins-instance-iam-role.arn}"
      },
      "Action": [
        "kms:CreateGrant",
        "kms:ListGrants",
        "kms:RevokeGrant"
      ],
      "Resource": "*",
      "Condition": {
        "Bool": {
          "kms:GrantIsForAWSResource": "true"
        }
      }
    },
    {
      "Sid": "Allow access through EC2",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.jenkins-instance-iam-role.arn}"
      },
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "kms:CallerAccount": "${data.aws_caller_identity.jenkins-aws-account.account_id}",
          "kms:ViaService": "ec2.${var.aws_region}.amazonaws.com"
        }
      }
    }
  ]
}
EOF
}

resource "aws_kms_alias" "jenkins-kmscmk-ec2-alias" {
  name                    = "alias/${var.project_prefix}-ksmcmk-ec2"
  target_key_id           = aws_kms_key.jenkins-kmscmk-ec2.key_id
}
