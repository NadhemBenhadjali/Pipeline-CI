pipeline {
  agent any

  environment {
    IMAGE_REPO     = 'nadhem9/my-country-service'
    IMAGE_TAG      = "${BUILD_NUMBER}"
    IMAGE_LATEST   = 'latest'
    K8S_DEPLOYMENT = 'my-country-service'
    K8S_CONTAINER  = 'my-country-service'
  }

  stages {

    stage('Checkout') {
      steps {
        git branch: 'main', url: 'https://github.com/NadhemBenhadjali/Pipeline-CI'
      }
    }

    stage('Build (Maven)') {
      steps {
        sh 'mvn clean install -DskipTests=false'
      }
    }

    stage('Build & Push Docker image') {
      steps {
        script {
          sh """
            docker build \
              -t ${IMAGE_REPO}:${IMAGE_TAG} \
              -t ${IMAGE_REPO}:${IMAGE_LATEST} \
              .
          """

          withCredentials([string(credentialsId: 'dockerhub-pwd', variable: 'DOCKERHUB_PWD')]) {
            sh 'echo "$DOCKERHUB_PWD" | docker login -u nadhem9 --password-stdin'
          }

          sh """
            docker push ${IMAGE_REPO}:${IMAGE_TAG}
            docker push ${IMAGE_REPO}:${IMAGE_LATEST}
          """
        }
      }
    }
    stage('Test Kubernetes Connection') {
  steps {
    script {
      kubeconfig(credentialsId: 'kubeconfig-file', serverUrl: '') {
        sh 'kubectl get pods'
      }
    }
  }
}

    stage('Deploy to Kubernetes') {
      steps {
        timeout(time: 30, unit: 'SECONDS') {
          script {
            kubeconfig(credentialsId: 'kubeconfig-file', serverUrl: '') {
              sh 'echo "Current kubectl context:"'
              sh 'kubectl config current-context || true'
              sh 'kubectl cluster-info || true'
              sh 'kubectl apply -f deployment.yaml'
              sh 'kubectl apply -f service.yaml'
              sh "kubectl set image deployment/${K8S_DEPLOYMENT} ${K8S_CONTAINER}=${IMAGE_REPO}:${IMAGE_TAG} --record || true"
              sh "kubectl rollout status deployment/${K8S_DEPLOYMENT} --timeout=30s || true"
            }
          }
        }
      }
    }
  }

  post {
    always {
      echo "Pipeline finished. Image=${IMAGE_REPO}:${IMAGE_TAG}"
    }
  }
}


