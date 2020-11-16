# Instance Key
resource "aws_key_pair" "jenkins-instance-key" {
  key_name                = "jenkins-instance-key-${random_string.project_suffix.result}"
  public_key              = var.instance_key
  tags                    = {
    Name                    = "jenkins-instance-key"
  }
}

# Instance(s)
resource "aws_instance" "jenkins-master-1" {
  ami                     = aws_ami_copy.jenkins-latest-vendor-ami-with-cmk.id
  instance_type           = var.instance_type
  iam_instance_profile    = aws_iam_instance_profile.jenkins-instance-profile.name
  key_name                = aws_key_pair.jenkins-instance-key.key_name
  subnet_id               = aws_subnet.jenkins-pubnet1.id
  private_ip              = var.pubnet1_instance_ip
  vpc_security_group_ids  = [aws_security_group.jenkins-pubsg1.id]
  tags                    = {
    Name                    = "${var.project_prefix}-master-1"
    Jenkins                 = "master"
  }
  user_data               = <<EOF
#!/bin/bash
# set hostname
hostnamectl set-hostname ${var.project_prefix}-master1
EOF
  root_block_device {
    volume_size             = var.instance_vol_size
    volume_type             = "standard"
    encrypted               = "true"
    kms_key_id              = aws_kms_key.jenkins-kmscmk-ec2.arn
  }
  depends_on              = [aws_iam_role_policy_attachment.jenkins-iam-attach-ssm, aws_iam_role_policy_attachment.jenkins-iam-attach-s3]
}

# Elastic IP for Instance(s)
resource "aws_eip" "jenkins-master-eip-1" {
  vpc                     = true
  instance                = aws_instance.jenkins-master-1.id
  associate_with_private_ip = var.pubnet1_instance_ip
  depends_on              = [aws_internet_gateway.jenkins-gw]
}
