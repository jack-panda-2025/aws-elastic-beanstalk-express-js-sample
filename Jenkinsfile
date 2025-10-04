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
                    def imageName = "xu524873/assignment2:${BUILD_NUMBER}"
                    // 推送镜像到 Docker Hub
                    sh "docker push ${imageName}"
                }
            }
        }
    }
}
