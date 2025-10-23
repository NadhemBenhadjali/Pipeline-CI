pipeline {
  agent any

  environment {
    IMAGE_REPO     = 'nadhem9/my-country-service'
    IMAGE_TAG      = "${BUILD_NUMBER}"
    IMAGE_LATEST   = 'latest'
    CONTAINER_NAME = 'my-country-service'   // container name on the host
    SERVICE_PORT   = '8082'
  }

  stages {

    stage('Build & Push Docker image') {
      steps {
        script {
          // Build image with two tags: build number and latest
          sh """
            docker build \
              -t ${IMAGE_REPO}:${IMAGE_TAG} \
              -t ${IMAGE_REPO}:${IMAGE_LATEST} \
              .
          """

          // Login to Docker Hub (password stored in Jenkins secret text 'dockerhub-pwd')
          withCredentials([string(credentialsId: 'dockerhub-pwd', variable: 'DOCKERHUB_PWD')]) {
            sh 'echo "$DOCKERHUB_PWD" | docker login -u nadhem9 --password-stdin'
          }

          // Push both tags
          sh """
            docker push ${IMAGE_REPO}:${IMAGE_TAG}
            docker push ${IMAGE_REPO}:${IMAGE_LATEST}
          """
        }
      }
    }

    stage('Deploy micro-service') {
      steps {
        script {
          // Stop & remove only the target container if it exists
          sh """
            docker stop ${CONTAINER_NAME} || true
            docker rm   ${CONTAINER_NAME} || true
          """

          // Run the new container
          sh """
            docker run -d --name ${CONTAINER_NAME} \
              -p ${SERVICE_PORT}:${SERVICE_PORT} \
              --restart unless-stopped \
              ${IMAGE_REPO}:${IMAGE_TAG}
          """
        }
      }
    }
  }
}
