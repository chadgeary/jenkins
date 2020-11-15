pipeline {
  agent any
  environment {
    SVC_ACCOUNT_KEY = credentials('aws-key')
    SVC_ACCOUNT_SECRET = credentials('aws-secret')
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
        sh('wget https://releases.hashicorp.com/terraform/0.13.5/terraform_0.13.5_linux_amd64.zip -O terraform/terraform.zip')
        sh('unzip -d terraform/ terraform/terraform.zip')
        sh('terraform/terraform init -no-color')
        sh('terraform/terraform plan -no-color -out jenkins -var-file="jenkins.tfvars"')
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
        sh('terraform/terraform apply -no-color -input=false jenkins -var-file="jenkins.tfvars"')
      }
    }
  }
}
