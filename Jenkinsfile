pipeline {
    agent any

    tools {
        maven 'mymaven'
        jdk 'JDK21'        // Must match the name in "Global Tool Configuration"

    }

    environment {
        KUBECONFIG = credentials('kubeconfig-file')
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
                script {
                    // Copier le kubeconfig dans le workspace
                    sh 'cp $KUBECONFIG config'

                    // Exécuter le playbook Ansible
                    sh 'ansible-playbook -i hosts playbookCICD.yml --check'
                }
            }
        }
    }

    post {
        always {
            cleanWs()  // Nettoyer l'espace de travail après l'exécution
        }
        success {
            echo 'Pipeline exécuté avec succès !'
        }
        failure {
            echo 'L\'exécution du pipeline a échoué !'
        }
    }
}





