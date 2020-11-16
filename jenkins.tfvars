# aws profile (e.g. from aws configure, usually "default")
aws_profile = "default"
aws_region = "us-east-1"

# existing aws iam user granted access to the kms key (for browsing KMS encrypted services like S3 or SNS).
kms_manager = "some_iam_user"

# the ip subnet permitted to connect via SSH and HTTPS
mgmt_cidr = "127.0.0.1/32"

# public ssh key
instance_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCNsxnMWfrG3SoLr4uJMavf43YkM5wCbdO7X5uBvRU8oh1W+A/Nd/jie2tc3UpwDZwS3w6MAfnu8B1gE9lzcgTu1FFf0us5zIWYR/mSoOFKlTiaI7Uaqkc+YzmVw/fy1iFxDDeaZfoc0vuQvPr+LsxUL5UY4ko4tynCSp7zgVpot/OppqdHl5J+DYhNubm8ess6cugTustUZoDmJdo2ANQENeBUNkBPXUnMO1iulfNb6GnwWJ0Z5TRRLGSu1gya2wMLeo1rBJFcb6ZgVLMVHiKgwBy/svUQreR8R+fpVW+Q4rx6RSAltLROUONn0SF2BvvJUueqxpAIaA2rU4MSI69P"

# size according to workloads
instance_type = "t3a.medium"

# the root block size of the instance(s) (in GiB)
instance_vol_size = 30

# the name prefix for various resources
project_prefix = "jenkins"

# the vendor supplying the AMI and the AMI name - default is official Ubuntu 1804 amd64 
vendor_ami_account_number = "099720109477"
vendor_ami_name_string = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-20201112"

# vpc specific vars, modify these values if there would be overlap with existing resources in the aws account.
vpc_cidr = "10.11.12.0/24"
pubnet1_cidr = "10.11.12.0/26"
pubnet1_instance_ip = "10.11.12.5"

# docker specific vars, modify these values if there would be overlap with existing resources on the ec2 instance.
docker_network = "192.168.11.0"
docker_gw = "192.168.11.1"
docker_jenkinsmaster = "192.168.11.2"
docker_webproxy = "192.168.11.3"
