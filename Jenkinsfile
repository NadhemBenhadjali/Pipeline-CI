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
            export KUBECONFIG="$KUBECONFIG_FILE"

            # Install required Ansible collections (if not yet installed)
            ansible-galaxy collection install -q community.docker kubernetes.core

            # Run the playbook
            ansible-playbook -i localhost, -c local \
              -e kubeconfig_path="$KUBECONFIG" \
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
