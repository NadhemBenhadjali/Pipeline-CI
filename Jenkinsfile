pipeline {
    agent any

    tools {
        maven 'mymaven'
    }

    environment {
        KUBECONFIG = credentials('kubeconfig-file')
        ANSIBLE_PYTHON_INTERPRETER = '/home/nadhem/miniconda3/bin/python'
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
        stage('Check Python Interpreter') {
            steps {
                script {
                    sh 'which python'
                    sh 'python --version'
                    sh 'python3 --version'
                }
            }
        }
        stage('Deploy using Ansible playbook') {
            steps {
                script {
                    // Copier le kubeconfig dans le workspace
                    sh 'cp $KUBECONFIG config'
                    
                    sh 'ansible-playbook -i hosts playbookCICD.yml'
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo 'Pipeline executed successfully!'
        }
        failure {
            echo 'Pipeline execution failed!'
        }
    }
}


