pipeline {
  agent any

  environment {
    IMAGE_REPO   = 'nadhem9/my-country-service'
    IMAGE_TAG    = "${BUILD_NUMBER}"
    IMAGE_LATEST = 'latest'
    K8S_DEPLOYMENT = 'my-country-service'
    K8S_CONTAINER  = 'my-country-service'
  }

  stages {

    stage('Checkout') {
      steps {
        git branch: 'main', url: 'https://github.com/NadhemBenhadjali/Pipeline-CI/'
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

    stage('Deploy to Kubernetes') {
      steps {
        script {
          kubeconfig(credentialsId: 'kubeconfig-file', serverUrl: '') {
            sh 'kubectl apply -f deployment.yaml'
            sh 'kubectl apply -f service.yaml'
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

}
