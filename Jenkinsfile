pipeline {
    agent {
        docker {
            image 'node:16'
            args '-v /var/jenkins_home/workspace:/workspace'
        }
    }
    environment {
        SNYK_TOKEN = credentials('SNYK_TOKEN')
    }
    stages {
        stage('Install Dependencies') {
            steps {
                sh 'npm install --save'
            }
        }
        stage('Run Security Scan') {
            steps {
                sh 'npm install -g snyk && snyk auth $SNYK_TOKEN && snyk test --severity-threshold=high'
            }
        }
        stage('Run Tests') {
            steps {
                sh 'npm test'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    def image = "xu524873/assignment2:${BUILD_NUMBER}"
                    sh "docker build -t ${image} ."
                }
            }
        }
        stage('Push Docker Image') {
            steps {
                script {
                    def image = "xu524873/assignment2:${BUILD_NUMBER}"
                    sh "docker push ${image}"
                }
            }
        }
    }
}
