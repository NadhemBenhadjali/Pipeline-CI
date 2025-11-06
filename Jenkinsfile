
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
        sh 'mvn clean install -DskipTests'
      }
    }

    stage('Deploy using Ansible playbook (venv)') {
      steps {
        withCredentials([file(credentialsId: 'kubeconfig-file', variable: 'KUBECONFIG_FILE')]) {
          sh '''
            set -e
            export KUBECONFIG="$KUBECONFIG_FILE"
            export DOCKER_HOST=unix:///var/run/docker.sock
            export PATH="$HOME/.local/bin:$PATH"

            # Fresh, writable venv in the workspace (owned by jenkins)
            python3 -m venv .venv
            . .venv/bin/activate
            pip install --upgrade pip
            pip install ansible kubernetes docker requests requests-unixsocket
            ansible-galaxy collection install -q kubernetes.core community.docker

            # Sanity
            python - <<'PY'
import sys, kubernetes, docker
print("Interpreter:", sys.executable)
print("k8s:", kubernetes.__version__, "docker:", docker.__version__)
PY

            # Use this venv's python as the interpreter
            ansible-playbook -i localhost, -c local \
              -e ANSIBLE_PY="$PWD/.venv/bin/python" \
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
