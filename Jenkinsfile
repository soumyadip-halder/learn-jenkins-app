pipeline {
    agent any
    stages {
        stage('Build') {
            agent {
                docker {
                    image 'node:18-alpine'
                }
            }
            steps {
                sh '''
                 echo "Started the build stage"
                 npm --version
                 node --version
                 npm ci
                 npm run build
                 ls -la
                '''
            }
        }
        stage('Test') {
            steps {
                sh '''
                 echo "Testing stage started"
                 test -f build/index.html
                 npm run test
                '''
            }
        }
    }
}