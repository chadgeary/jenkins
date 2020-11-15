pipeline {
  agent any
  environment {
    SVC_ACCOUNT_KEY = credentials('aws-key')
    SVC_ACCOUNT_SECRET = credentials('aws-secret')
    MGMT_CIDR = credentials('mgmt-cidr')
    PUB_KEY = credentials('pub-key')
    KMS_MANAGER = credentials('kms-manager')
  }
  stages {
    stage('Checkout') {
      steps {
        checkout scm
        sh('echo "[default]" > ./.credentials')
        sh('echo "aws_access_key_id = $(echo $SVC_ACCOUNT_KEY | base64 -d)" >> ./.credentials')
        sh('echo "aws_secret_access_key = $(echo $SVC_ACCOUNT_SECRET | base64 -d)" >> ./.credentials')
      }
    }
    stage('Plan') {
      steps {
        sh('mkdir -p terraform')
        sh('wget --quiet https://releases.hashicorp.com/terraform/0.13.5/terraform_0.13.5_linux_amd64.zip -O terraform/terraform.zip')
        sh('unzip -f -d terraform/ terraform/terraform.zip')
        sh('sed -i \'/  profile                  = var.aws_profile/a  shared_credentials_file  = ".credentials"\' jenkins-generic.tf')
        sh('cp jenkins.tfvars pvars.tfvars')
        sh('sed -i -e "s#^mgmt_cidr.*#mgmt_cidr = \\"$MGMT_CIDR\\"#" pvars.tfvars')
        sh('sed -i -e "s#^pub_key.*#pub_key = \\"$PUB_KEY\\"#" pvars.tfvars')
        sh('sed -i -e "s#^kms_manager.*#kms_manager = \\"$KMS_MANAGER\\"#" pvars.tfvars')
        sh('terraform/terraform init -no-color')
        sh('terraform/terraform plan -no-color -out jenkinsplan -var-file="pvars.tfvars"')
      }
    }
    stage('Approve') {
      steps {
        script {
          def userInput = input(id: 'confirm', message: 'Apply?', parameters: [ [$class: 'BooleanParameterDefinition', defaultValue: false, description: 'Apply terraform', name: 'confirm'] ])
        }
      }
    }
    stage('Apply') {
      steps {
        sh('terraform/terraform apply -no-color -input=false jenkinsplan -var-file="pvars.tfvars"')
      }
    }
  }
}
