# zookeepers
resource "aws_ssm_association" "jenkins-master-ssm-assoc" {
  association_name        = "jenkins-master"
  name                    = "AWS-ApplyAnsiblePlaybooks"
  targets {
    key                   = "tag:Jenkins"
    values                = ["master"]
  }
  output_location {
    s3_bucket_name          = aws_s3_bucket.jenkins-bucket.id
    s3_key_prefix           = "ssm"
  }
  parameters              = {
    Check                   = "False"
    ExtraVariables          = "SSM=True s3_bucket=${aws_s3_bucket.jenkins-bucket.id} ec2_name_prefix=${var.ec2_name_prefix} jenkinsnet_cidr=${var.jenkinsnet_cidr} jenkinsnet_master=${var.jenkinsnet_master} jenkinsmaster_webport=${var.jenkinsmaster_webport}"
    InstallDependencies     = "True"
    PlaybookFile            = "jenkins-master.yml"
    SourceInfo              = "{\"path\":\"https://s3.${var.aws_region}.amazonaws.com/${aws_s3_bucket.jenkins-bucket.id}/jenkins/\"}"
    SourceType              = "S3"
    Verbose                 = "-v"
  }
  depends_on              = [aws_iam_role_policy_attachment.jenkins-iam-attach-ssm, aws_iam_role_policy_attachment.jenkins-iam-attach-s3,aws_s3_bucket_object.jenkins-files]
}
