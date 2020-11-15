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
        container('terraform') {
          sh('terraform init')
          sh('terraform plan -out jenkins')
        }
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
        container('terraform') {
          sh('terraform apply -input=false jenkins')
        }
      }
    }
  }
}
