pipeline {
    agent any

    tools {
        jdk 'JDK21'       
        maven 'mymaven'  
    }
    
    environment {
        NEXUS_VERSION = "nexus3"
        NEXUS_PROTOCOL = "http"
        NEXUS_URL = "localhost:8081"
        NEXUS_REPOSITORY = "maven-snapshots" 
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
    withSonarQubeEnv('MySonarQubeServer') {
      sh 'mvn -B sonar:sonar -Dsonar.projectKey=country-service'
    }
  }
}
     stage('Publish to Nexus Repository Manager') {
            steps {
                script {
                    pom = readMavenPom file: "pom.xml"
                    filesByGlob = findFiles(glob: "target/*.${pom.packaging}")
                    if (filesByGlob.size() == 0) {
                        error "No artifact found in target/ to upload to Nexus"
                    }
                    artifactPath = filesByGlob[0].path
                    echo "📤 Uploading ${artifactPath} to Nexus"
                    nexusArtifactUploader(
                        nexusVersion: NEXUS_VERSION,
                        protocol: NEXUS_PROTOCOL,
                        nexusUrl: NEXUS_URL,
                        groupId: pom.groupId,
                        version: pom.version,
                        repository: NEXUS_REPOSITORY,
                        credentialsId: NEXUS_CREDENTIAL_ID,
                        artifacts: [
                            [artifactId: pom.artifactId,
                             classifier: '',
                             file: artifactPath,
                             type: pom.packaging],
                            [artifactId: pom.artifactId,
                             classifier: '',
                             file: "pom.xml",
                             type: "pom"]
                        ]
                    )
                }
            }
        }
        stage('Deploy to Tomcat') {
  steps {
    withCredentials([usernamePassword(credentialsId: 'TOMCAT_CRED', usernameVariable: 'TC_USER', passwordVariable: 'TC_PASS')]) {
      script {
        def pom = readMavenPom file: 'pom.xml'
        def filesByGlob = findFiles(glob: "target/*.${pom.packaging}")
        if (!filesByGlob) { error "❌ No artifact found in target/ to deploy" }

        def artifactRel = filesByGlob[0].path                    
        def ws = pwd()                                          
        def artifactAbs = "${ws}/${artifactRel}"                

        echo "🚀 Deploying ${artifactRel} to Tomcat via Ansible"

        sh '''
          set -e
          export PATH="$HOME/.local/bin:$PATH"
        ''' 
        sh """
      ansible-playbook -i localhost, -c local deploy/deploy-tomcat.yml \
        --extra-vars "artifact=${artifactAbs} tomcat_user=${TC_USER} tomcat_password=${TC_PASS} tomcat_host=localhost tomcat_port=8082 tomcat_context=/country"
     """

      }
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
