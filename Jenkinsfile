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

   stage('Deploy using Ansible playbook (WSL + Conda)') {
  steps {
    withCredentials([file(credentialsId: 'kubeconfig-file', variable: 'KCFG_WIN')]) {
      sh '''
        set -e
        # Convert the Windows temp path of the secret file to a WSL path
        WSL_KCFG=$(wslpath "$KCFG_WIN")

        # Everything below runs INSIDE WSL Ubuntu
        wsl.exe -d Ubuntu -- bash -lc '
          set -e
          export KUBECONFIG="'$WSL_KCFG'"
          export ANSIBLE_PY=/home/nadhem/miniconda3/bin/python3

          # Make sure required libs are in your Conda Python
          $ANSIBLE_PY -m pip install --user --upgrade pip
          $ANSIBLE_PY -m pip install --user ansible kubernetes docker requests requests-unixsocket

          # Collections (idempotent)
          ansible-galaxy collection install -q kubernetes.core community.docker

          # Ensure Docker SDK talks to Linux socket in WSL
          export DOCKER_HOST=unix:///var/run/docker.sock

          # Sanity print
          $ANSIBLE_PY - <<PY
import sys, kubernetes, docker
print("Interpreter:", sys.executable)
print("k8s:", kubernetes.__version__, "docker:", docker.__version__)
PY

          # Run playbook (force Ansible to use Conda Python)
          ansible-playbook -i localhost, -c local \
            -e ANSIBLE_PY="$ANSIBLE_PY" \
            -e kubeconfig_path="$KUBECONFIG" \
            playbookCICD.yml
        '
      '''
    }
  }
}

  post {
    always { cleanWs() }
    success { echo '✅ Deployment OK' }
    failure { echo '❌ Ansible playbook execution failed!' }
  }
}


