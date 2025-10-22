pipeline {
    agent any

    tools {
        jdk 'JDK21'       
        maven 'mymaven'  
    }
    
    environment {
        SCANNER_HOME = tool 'MySonarScanner'
        NEXUS_VERSION = "nexus3"
        NEXUS_PROTOCOL = "http"
        NEXUS_URL = "localhost:8081"
        NEXUS_REPOSITORY = "maven-1"
        NEXUS_CREDENTIAL_ID = "NEXUS_CRED"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/NadhemBenhadjali/Pipeline-CI'
            }
        }

        stage('Compile') {
            steps {
                echo '🔧 Compiling source code...'
                sh 'mvn clean compile'
            }
        }

        stage('Test') {
            steps {
                echo '🧪 Running unit tests...'
                sh 'mvn test'
            }
            post {
                always {
                    junit allowEmptyResults: true, testResults: '**/target/surefire-reports/*.xml'
                }
            }
        }

        stage('Package') {
            steps {
                echo 'Packaging the application...'
                sh 'mvn clean package'
            }
        }
                stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }
        stage('SonarQube Analysis') {
    steps {
        withSonarQubeEnv(installationName: 'MySonarQubeServer', credentialsId: 'sonar') {
            sh "mvn sonar:sonar -Dsonar.projectKey=country-service -Dsonar.projectName=country-service"
        }
    }
}

    }


    post {
        always {
            echo 'Pipeline completed!'
        }
        success {
            echo 'Build, Test, Package, Nexus Upload, and Deployment succeeded!'
        }
        failure {
            echo 'Pipeline failed. Check console logs for details.'
        }
    }
}
