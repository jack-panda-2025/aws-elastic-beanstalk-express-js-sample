pipeline {
    agent any  // Use the Jenkins host environment, no Docker Pipeline plugin needed
    environment {
        SNYK_TOKEN = credentials('SNYK_TOKEN') // Retrieve Snyk API token from Jenkins Credentials
    }
    stages {
        stage('Install Dependencies') {
            steps {
                // Run npm install inside Node 16 Docker container
                // -v mounts current directory into container
                // -w sets working directory inside container
                sh 'docker run --rm -v $PWD:/app -w /app node:16 npm install --save'
            }
        }
        stage('Run Security Scan') {
            steps {
                // Run Snyk CLI inside Node 16 Docker container
                // 1. Install Snyk globally if not already installed
                // 2. Authenticate using SNYK_TOKEN from Jenkins Credentials
                // 3. Run vulnerability scan, fail pipeline if High/Critical issues found
                sh '''
                docker run --rm -v $PWD:/app -w /app node:16 sh -c "
                  npm install -g snyk && \
                  snyk auth $SNYK_TOKEN && \
                  snyk test --severity-threshold=high
                "
                '''
            }
        }
        stage('Run Tests') {
            steps {
                // Execute unit tests using npm test inside Node 16 container
                sh 'docker run --rm -v $PWD:/app -w /app node:16 npm test'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    // Build Docker image of the application
                    // Tag it with the Jenkins build number for versioning
                    def image = "xu524873/assignment2:${BUILD_NUMBER}"
                    sh "docker build -t ${image} ."
                }
            }
        }
        stage('Push Docker Image') {
            steps {
                script {
                    // Push the built Docker image to Docker Hub or your registry
                    def image = "xu524873/assignment2:${BUILD_NUMBER}"
                    sh "docker push ${image}"
                }
            }
        }
    }
}
