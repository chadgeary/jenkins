resource "random_string" "project_suffix" {
  length                  = 5
  upper                   = false
  special                 = false
}

variable "aws_region" {
  type                     = string
}

variable "aws_profile" {
  type                     = string
}

variable "vpc_cidr" {
  type                     = string
}

variable "pubnet1_cidr" {
  type                     = string
}

variable "pubnet1_instance_ip" {
  type                     = string
}

variable "docker_network" {
  type                     = string
  description              = "Jenkins network IP for the Docker configuration"
}

variable "docker_gw" {
  type                     = string
  description              = "IP within docker_network/24 for the network gateway"
}

variable "docker_jenkinsmaster" {
  type                     = string
  description              = "IP within docker_network/24 for the Jenkins Master container instance"
}

variable "docker_webproxy" {
  type                     = string
  description              = "IP within docker_network/24 for the httpd TLS proxy"
}

variable "mgmt_cidr" {
  type                     = string
  description              = "Subnet CIDR allowed to access WebUI and SSH, e.g. my_public_ip/32"
}

variable "instance_type" {
  type                     = string
  description              = "The type of EC2 instance to deploy"
}

variable "instance_key" {
  type                     = string
  description              = "A public key for SSH access to instance(s)"
}

variable "instance_vol_size" {
  type                     = number
  description              = "The volume size of the instances' root block device"
}

variable "kms_manager" {
  type                     = string
  description              = "An IAM user for management of KMS key"
}

variable "project_prefix" {
  type                     = string
  description              = "A unique bucket name to store playbooks and output of SSM"
}

variable "vendor_ami_account_number" {
  type                     = string
  description              = "The account number of the vendor supplying the base AMI"
}

variable "vendor_ami_name_string" {
  type                     = string
  description              = "The search string for the name of the AMI from the AMI Vendor"
}

provider "aws" {
  region                   = var.aws_region
  profile                  = var.aws_profile
}

# region azs
data "aws_availability_zones" "jenkins-azs" {
  state                    = "available"
}

# account id
data "aws_caller_identity" "jenkins-aws-account" {
}

# kms cmk manager - granted read access to KMS CMKs
data "aws_iam_user" "jenkins-kmsmanager" {
  user_name               = var.kms_manager
}
