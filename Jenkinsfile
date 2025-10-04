pipeline {
    agent any  
    environment {
        // Snyk API token
        SNYK_TOKEN = credentials('SNYK_TOKEN') 
        // Docker-in-Docker (DinD) connection details
        DOCKER_HOST = 'tcp://dind:2376'        
        DOCKER_TLS_VERIFY = '1'
        DOCKER_CERT_PATH = '/certs/client'
    }
    stages {
        stage('Install Dependencies') {
            steps {
                // Install Node.js dependencies inside Node 16 container in DinD
                // Mount current workspace into container (-v)
                // Set working directory inside container (-w)
                sh '''
                docker run --rm \
                    -v $PWD:/app -w /app \
                    node:16 \
                    npm install --save
                '''
            }
        }
        stage('Run Security Scan') {
            steps {
                // Run Snyk security vulnerability scan inside Node 16 container
                // 1. Install Snyk CLI globally
                // 2. Authenticate with SNYK_TOKEN
                // 3. Fail pipeline if High/Critical vulnerabilities detected
                sh '''
                docker run --rm \
                    -v $PWD:/app -w /app \
                    -e SNYK_TOKEN=$SNYK_TOKEN \
                    node:16 sh -c "
                        npm install -g snyk && \
                        snyk auth $SNYK_TOKEN && \
                        snyk test --severity-threshold=high
                    "
                '''
            }
        }
        stage('Run Tests') {
            steps {
                // Run unit tests using npm test inside Node 16 container
                sh '''
                docker run --rm \
                    -v $PWD:/app -w /app \
                    node:16 \
                    npm test
                '''
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    // Build Docker image of the application using DinD
                    // Tag image with Jenkins BUILD_NUMBER for versioning
                    def image = "xu524873/assignment2:${BUILD_NUMBER}"
                    sh "docker build -t ${image} ."
                }
            }
        }
        stage('Push Docker Image') {
            steps {
                script {
                    // Push Docker image to Docker Hub or private registry using DinD
                    def image = "xu524873/assignment2:${BUILD_NUMBER}"
                    sh "docker push ${image}"
                }
            }
        }
    }
}
