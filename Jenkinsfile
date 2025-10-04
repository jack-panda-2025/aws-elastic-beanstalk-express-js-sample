stage('Checkout Code') {
    steps {
        echo "===== Starting Checkout Code Stage ====="
        checkout scm
    }
}

stage('Install Dependencies') {
    steps {
        echo "===== Starting Build Stage ====="
        sh '''
        docker run --rm \
            -v ${WORKSPACE}:/app -w /app \
            -u $(id -u):$(id -g) \
            node:16 \
            npm install --save
        '''
    }
}

stage('Run Unit Tests') {
    steps {
        echo "===== Running Tests ====="
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
        echo "===== Building Docker Image ====="
        script {
            def imageName = "xu524873/assignment2:${BUILD_NUMBER}"
            sh "docker build -t ${imageName} ${WORKSPACE}"
        }
    }
}

stage('Run Security Scan') {
    steps {
        echo "===== Running Security Scan ====="
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

post {
    always {
        echo "===== Archiving Artifacts ====="
        archiveArtifacts artifacts: '**/npm-debug.log, **/snyk-report.json, **/test-results.xml', allowEmptyArchive: true
        buildDiscarder(logRotator(numToKeepStr: '10'))
        echo "Build number: ${env.BUILD_NUMBER}, started by: ${env.BUILD_USER}"
    }
}
