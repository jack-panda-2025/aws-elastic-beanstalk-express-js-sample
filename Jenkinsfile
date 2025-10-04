pipeline {
    agent any
    environment {
        // Snyk API token stored in Jenkins Credentials
        SNYK_TOKEN = credentials('SNYK_TOKEN')

        // Docker-in-Docker connection (DinD)
        DOCKER_HOST = 'tcp://docker:2376'
        DOCKER_TLS_VERIFY = '1'
        DOCKER_CERT_PATH = '/certs/client'
    }
    stages {
        stage('Checkout Code') {
            steps {
                // 拉取代码到 Jenkins workspace
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                // 使用 Node 16 容器安装 npm 依赖
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
                // Snyk 安全扫描
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
                // 在 Node 16 容器里执行单元测试
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
                    // 使用 DinD 构建 Docker 镜像
                    sh "docker build -t ${imageName} ${WORKSPACE}"
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    def image = "xu524873/assignment2:${BUILD_NUMBER}"
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

            // 1️⃣ Archive build artifacts such as logs, test reports, and scan results
            // These files will be stored under each build record for later review
            archiveArtifacts artifacts: '**/npm-debug.log, **/snyk-report.json, **/test-results.xml', allowEmptyArchive: true

            // 2️⃣ Configure build retention policy
            // Keep only the latest 10 builds to prevent excessive log storage
            buildDiscarder(logRotator(numToKeepStr: '10'))

            // 3️⃣ Print useful build information to the console
            echo "Build number: ${env.BUILD_NUMBER}, started by: ${env.BUILD_USER}"
        }

        failure {
            // Executed only if the pipeline fails
            echo "❌ Build failed! Check console logs for detailed errors."
        }
    }
}
