pipeline {
  agent any

  tools {
    maven 'mymaven'   // <-- match the actual tool name configured in Jenkins
  }

  stages {
    stage('Checkout code') {
      steps {
        git branch: 'main', url: 'https://github.com/NadhemBenhadjali/Pipeline-CI'
      }
    }

    stage('Build maven') {
      steps {
        sh 'mvn clean install -DskipTests'
      }
    }

    stage('Deploy using Ansible playbook (Conda)') {
      steps {
        withCredentials([file(credentialsId: 'kubeconfig-file', variable: 'KUBECONFIG_FILE')]) {
          sh '''
            set -e

            export KUBECONFIG="$KUBECONFIG_FILE"
            export ANSIBLE_PY=/home/nadhem/miniconda3/bin/python3
            export DOCKER_HOST=unix:///var/run/docker.sock
            export PATH="$HOME/.local/bin:$PATH"

            # Make sure required libs are installed into your Conda python
            $ANSIBLE_PY -m pip install --user --upgrade pip
            $ANSIBLE_PY -m pip install --user ansible kubernetes docker requests requests-unixsocket

            # Collections (idempotent)
            ansible-galaxy collection install -q kubernetes.core community.docker

            # Sanity print (shows the interpreter + versions we will use)
            $ANSIBLE_PY - <<'PY'
import sys, kubernetes, docker
print("Interpreter:", sys.executable)
print("k8s:", kubernetes.__version__, "docker:", docker.__version__)
PY

            # Run the playbook forcing Ansible to use your Conda interpreter
            ansible-playbook -i localhost, -c local \
              -e ANSIBLE_PY="$ANSIBLE_PY" \
              -e kubeconfig_path="$KUBECONFIG" \
              playbookCICD.yml
          '''
        }
      }
    }
  }

  post {
    always { cleanWs() }
    success { echo '✅ Deployment OK' }
    failure { echo '❌ Ansible playbook execution failed!' }
  }
}
