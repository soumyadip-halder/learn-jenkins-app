pipeline {
    agent any
    stages {
        stage('Build') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
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
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                 echo "Testing stage started"
                 test -f build/index.html
                 npm run test
                '''
            }
        }
        stage('E2E') {
            agent {
                docker {
                    image 'mcr.microsoft.com/playwright:v1.55.0-noble'
                    reuseNode true
                }
            }
            steps {
                sh '''
                 echo "E2E step started"
                 npm install -g serve
                 serve - s build
                 npx playwright test
                '''
            }
        }
    }
    post {
        always {
            junit 'test-results/junit.xml'
        }
    }
}
