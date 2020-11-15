pipeline {
  agent any
  environment {
    SVC_ACCOUNT_KEY = credentials('credentials-aws')
  }
  stages {
    stage('Checkout') {
      steps {
        checkout scm
        sh 'mkdir -p creds'
        sh 'echo $SVC_ACCOUNT_KEY | base64 -d > ./.credentials'
      }
    }
    stage('Plan') {
      steps {
        container('terraform') {
          sh 'terraform init'
          sh 'terraform plan -out jenkins'
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
          sh 'terraform apply -input=false jenkins'
        }
      }
    }
  }
}
