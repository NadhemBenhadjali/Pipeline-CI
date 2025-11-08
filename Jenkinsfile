pipeline {
    agent any

    tools {
        maven 'mymaven'
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

        stage('Install Python dependencies') {
            steps {
                script {
                    // Mettre à jour pip et installer Kubernetes et Ansible
                    sh 'pip install --upgrade pip'  // Met à jour pip
                    sh 'pip install kubernetes ansible'  // Installe kubernetes et ansible
                }
            }
        }

        stage('Build maven') {
            steps {
                sh 'mvn clean install -DskipTests'
            }
        }

        stage('Check Python Interpreter') {
            steps {
                script {
                    // Vérifier la version de Python
                    sh 'python --version'  // Ou 'python3 --version' si nécessaire
                }
            }
        }

        stage('Deploy using Ansible playbook') {
            steps {
                script {
                    // Copier le kubeconfig dans le workspace
                    sh 'cp $KUBECONFIG config'

                    // Exécuter le playbook Ansible
                    sh 'ansible-playbook -i hosts playbookCICD.yml -vvvv'
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
