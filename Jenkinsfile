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
                    // Mettre à jour pip et installer Kubernetes et Ansible pour /usr/bin/python3
                    sh '/usr/bin/python3 -m pip install --upgrade pip'  // Assurez-vous que pip est à jour
                    sh '/usr/bin/python3 -m pip install kubernetes ansible'  // Installer kubernetes et ansible
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
                    // Vérifier la version de Python pour s'assurer que /usr/bin/python3 est utilisé
                    sh '/usr/bin/python3 --version'
                }
            }
        }

        stage('Deploy using Ansible playbook') {
            steps {
                script {
                    // Copier le kubeconfig dans le workspace
                    sh 'cp $KUBECONFIG config'

                    // Exécuter le playbook Ansible avec le Python configuré dans /usr/bin/python3
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
