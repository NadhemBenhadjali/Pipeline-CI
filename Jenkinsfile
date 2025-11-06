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
                sh 'mvn clean install -DskipTests'
            }
        }

        stage('Deploy using Ansible playbook') {
            steps {
                script {
                    // Exécution en mode check pour vérifier la syntaxe et les dépendances
                    sh 'ansible-playbook -i hosts playbookCICD.yml'
                }
            }
        }
    }

    post {
        always {
            // Nettoyage après chaque build
            cleanWs()
        }
        success {
            echo 'Ansible playbook executed successfully!'
        }
        failure {
            echo 'Ansible playbook execution failed!'
        }
    }
}


