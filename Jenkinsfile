pipeline {
  agent { label 'docker_root' }
  environment {
        DEPLOY_TO = 'master'
  }
  options {
    buildDiscarder(logRotator(numToKeepStr: '5'))
  }
  triggers {
    cron('@daily')
  }
  stages {
    stage('Checkout') {
      steps {
        git branch: 'master',
        credentialsId: '747596f4-8a62-4f10-889a-09db1e9cc9ae',
        url: 'git@github.com:paulcosma/docker-jmeter.git'

      }
    }
    stage('Build') {
      steps {
        sh 'docker image build -f jmeter.Dockerfile --target jmeter-master -t paulcosma/docker-jmeter .'
        sh 'docker image build -f jmeter.Dockerfile --target jmeter-master -t paulcosma/docker-jmeter-master .'
//        sh 'docker image build -f jmeter.Dockerfile --target jmeter-slave -t paulcosma/docker-jmeter-slave .'
      }
    }
    stage('Login') {
      steps {
        sh 'docker login'
      }
    }
    stage('Publish') {
      when {
        // branch 'master'
        environment name: 'DEPLOY_TO', value: 'master'
      }
      steps {
        withDockerRegistry([ credentialsId: "e80fc77a-7fce-4fbd-98ee-c7aa4d5a6952", url: "" ]) {
          sh 'docker push paulcosma/docker-jmeter:latest'
          sh 'docker push paulcosma/docker-jmeter-master:latest'
//          sh 'docker push paulcosma/docker-jmeter-slave:latest'
        }
      }
    }
  }
}
