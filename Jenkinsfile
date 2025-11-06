pipeline {
  agent any

  tools {
    maven 'myMaven'
  }

  stages {
    stage('Checkout code') {
      steps {
        git branch: 'main', url: 'https://github.com/NadhemBenhadjali/Pipeline-CI'
      }
    }

    stage('Build maven') {
      steps {
        sh 'mvn clean install'
      }
    }

    stage('Deploy using Ansible playbook') {
      steps {
        withCredentials([
          file(credentialsId: 'kubeconfig-file', variable: 'KUBECONFIG_FILE')
        ]) {
          sh '''
            ansible-playbook -i localhost, -c local \
              -e kubeconfig_path="$KUBECONFIG_FILE" \
              playbookCICD.yml
          '''
        }
      }
    }
  }

  post {
    always {
      cleanWs()
    }
    success {
      echo '✅ Ansible playbook executed successfully!'
    }
    failure {
      echo '❌ Ansible playbook execution failed!'
    }
  }
}

