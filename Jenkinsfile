pipeline {
    agent {
        docker {
            image 'node:16'
        }
    }
    stages {
        stage('Install Dependencies') {
            steps {
                sh 'npm install --save'
            }
        }
        stage('Run Security Scan') {
          steps {
              // Install Snyk CLI if not already available
              sh 'npm install -g snyk'
              // Authenticate Snyk (SNYK_TOKEN in Jenkins credentials)
              sh 'snyk auth $SNYK_TOKEN'
              // Run vulnerability test, fail if High/Critical issues
              sh 'snyk test --severity-threshold=high'
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
