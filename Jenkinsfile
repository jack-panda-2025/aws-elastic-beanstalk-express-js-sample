pipeline {
    agent any

    environment {
        // Snyk API token stored securely in Jenkins Credentials
        SNYK_TOKEN = credentials('SNYK_TOKEN')

        // Docker-in-Docker (DinD) connection settings
        DOCKER_HOST = 'tcp://docker:2376'
        DOCKER_TLS_VERIFY = '1'
        DOCKER_CERT_PATH = '/certs/client'
    }

    stages {

        stage('Checkout Code') {
            steps {
                // Pull the source code from the configured SCM repository
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                echo "===== Starting Build Stage ====="
                // Use a Node.js 16 container to install project dependencies
                sh '''
                docker run --rm \
                    -v ${WORKSPACE}:/app -w /app \
                    -u $(id -u):$(id -g) \
                    node:16 \
                    npm install --save
                '''
            }
        }

        stage('Run Security Scan') {
            steps {
                // Run a Snyk security scan to detect vulnerabilities in dependencies
                sh '''
                docker run --rm \
                    -v ${WORKSPACE}:/app -w /app \
                    -e SNYK_TOKEN=$SNYK_TOKEN \
                    node:16 sh -c "
                        npm install -g snyk && \
                        snyk auth $SNYK_TOKEN && \
                        snyk test --severity-threshold=high
                    "
                '''
            }
        }

        stage('Run Unit Tests') {
            steps {
                echo "===== Running Tests ====="
                // Execute unit tests inside a Node.js 16 container
                sh '''
                docker run --rm \
                    -v ${WORKSPACE}:/app -w /app \
                    -u $(id -u):$(id -g) \
                    node:16 \
                    npm test
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def imageName = "xu524873/assignment2:${BUILD_NUMBER}"
                    // Build the Docker image using Docker-in-Docker
                    sh "docker build -t ${imageName} ${WORKSPACE}"
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    def image = "xu524873/assignment2:${BUILD_NUMBER}"
                    // Authenticate to Docker Hub and push the built image
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh """
                        docker login -u $DOCKER_USER -p $DOCKER_PASS
                        docker push ${image}
                        docker logout
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            echo "✅ Build finished with status: ${currentBuild.currentResult}"

            // 1️⃣ Archive important artifacts (e.g., logs, test reports, scan results)
            // These files will be stored under each build record for later review
            archiveArtifacts artifacts: '**/npm-debug.log, **/snyk-report.json, **/test-results.xml', allowEmptyArchive: true

            // 2️⃣ Configure build retention policy
            // Keep only the latest 10 builds to avoid excessive log storage
            buildDiscarder(logRotator(numToKeepStr: '10'))

            // 3️⃣ Print build metadata for quick reference
            echo "Build number: ${env.BUILD_NUMBER}, started by: ${env.BUILD_USER}"
        }

        failure {
            // Executed only if the pipeline fails
            echo "❌ Build failed! Check console logs for detailed error information."
        }
    }
}
