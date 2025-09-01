pipeline {
    agent any
    environment {
        PYTHON_PATH = ""
        NETLIFY_SITE_ID = '7cbf4bf5-2d69-4b42-a0ab-692d224b3396'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
    }
    stages {
        stage('Build') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                    args '--user root' 
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
        stage('Tests') {
            parallel {
                stage('Test') {
                    agent {
                        docker {
                            image 'node:18-alpine'
                            reuseNode true
                            args '--user root' 
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
                            args '--user root' 
                        }
                    }
                    steps {
                        sh '''
                        echo "E2E step started"
                        npm install serve
                        node_modules/.bin/serve -s build &
                        sleep 5
                        npx playwright install chromium
                        npx playwright test
                        '''
                    }
                }
            }
        }
        stage('Deploy') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                    args '--user root' 
                }
            }
            steps {
                sh '''
                 echo "Deployment stage started"
                 apk update
                 apk add --no-cache python3 py3-pip
                 export npm_config_python="$(which python3)"
                 #npm config set python "$(which python3)"
                 npm install netlify-cli@20.1.1
                 node_modules/.bin/netlify --version
                 echo "Deploying to production. Site ID: $NETLIFY_SITE_ID"
                 node_modules/.bin/netlify status
                 node_modules/.bin/netlify deploy --dir=build --prod
                '''
            }
        }
        stage('Prod E2E') {
            agent {
                docker {
                    image 'mcr.microsoft.com/playwright:v1.55.0-noble'
                    reuseNode true
                    args '--user root' 
                }
            }
            environment {
                CI_ENVIRONMENT_URL = 'https://friendly-muffin-852f81.netlify.app'
            }
            steps {
                sh '''
                 echo "E2E production test stage starts"
                 npx playright install chromium
                 npx playright test
                '''
            }
        }
    }
    post {
        always {
            junit 'jest-results/junit.xml'
        }
    }
}
