pipeline {
  agent any

  tools {
    maven 'mymaven'
  }

  stages {

    stage('Checkout code') {
      steps {
        git branch: 'main', url: 'https://github.com/NadhemBenhadjali/Pipeline-CI'
      }
    }

    stage('Build maven') {
      steps {
        // Use -DskipTests if you want faster builds
        sh 'mvn clean install -DskipTests'
      }
    }

    stage('Deploy using Ansible playbook') {
      steps {
        withCredentials([
          file(credentialsId: 'kubeconfig-file', variable: 'KUBECONFIG_FILE')
        ]) {
          sh '''
            set -e

            # 1) Kubeconfig for k8s modules
            export KUBECONFIG="$KUBECONFIG_FILE"

            # 2) Use a clean virtualenv so the right Python has kubernetes+docker
            python3 -m venv .venv
            . .venv/bin/activate
            pip install --upgrade pip

            # 3) Ansible + Python libs needed by modules
            pip install ansible kubernetes docker requests requests-unixsocket

            # 4) Collections (idempotent)
            ansible-galaxy collection install -q kubernetes.core community.docker

            # 5) Make Ansible use THIS Python
            export ANSIBLE_PY="$PWD/.venv/bin/python"

            # 6) Ensure Docker socket path is correct for Linux/WSL runs
            export DOCKER_HOST="unix:///var/run/docker.sock"

            # 7) (Optional) sanity checks
            python - <<'PY'
import sys, kubernetes, docker
print("Interpreter:", sys.executable)
print("k8s:", kubernetes.__version__, "docker:", docker.__version__)
PY

            # 8) Run the playbook against localhost
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

