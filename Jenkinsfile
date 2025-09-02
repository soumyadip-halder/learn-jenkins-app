pipeline {
    agent any
    environment {
        PYTHON_PATH = ""
        NETLIFY_SITE_ID = '7cbf4bf5-2d69-4b42-a0ab-692d224b3396'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
        REACT_APP_VERSION = "1.0.$BUILD_ID"
    }
    stages {
        stage('Docker') {
            steps {
                sh '''
                 docker build -t my-playwright .
                '''
            }
        }
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
                        // docker {
                        //     image 'mcr.microsoft.com/playwright:v1.55.0-noble'
                        //     reuseNode true
                        //     args '--user root' 
                        // }
                        docker {
                            image 'my-playwright'
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                        echo "E2E step started"
                        #npm install serve
                        #node_modules/.bin/serve -s build &
                        serve -s build &
                        sleep 5
                        npx playwright install chromium
                        npx playwright test
                        '''
                    }
                }
            }
        }
        stage('Deploy to staging') {
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
                 node_modules/.bin/netlify deploy --dir=build
                '''
            }
        }
        stage('Approve') {
            steps {
                timeout(time: 15, unit: 'MINUTES') {
                    input message: 'Do you want to deploy to prod', ok: 'Yes I am sure'
                }
            }
        }
        stage('Deploy to prod') {
            agent {
                // docker {
                //     image 'node:18-alpine'
                //     reuseNode true
                //     args '--user root' 
                // }
                docker {
                    image 'my-playwright'
                    reuseNode true
                }
            }
            steps {
                sh '''
                 echo "Deployment stage started"
                 #apk update
                 #apk add --no-cache python3 py3-pip
                 #export npm_config_python="$(which python3)"
                 #npm config set python "$(which python3)"
                 #npm install netlify-cli@20.1.1
                 #node_modules/.bin/netlify --version
                 netlify --version
                 echo "Deploying to production. Site ID: $NETLIFY_SITE_ID"
                 #node_modules/.bin/netlify status
                 netlify status
                 #node_modules/.bin/netlify deploy --dir=build --prod
                 netlify deploy --dir=build --prod
                '''
            }
        }
        stage('Prod E2E') {
            agent {
                // docker {
                //     image 'mcr.microsoft.com/playwright:v1.55.0-noble'
                //     reuseNode true
                //     args '--user root' 
                // }
                docker {
                    image 'my-playwright'
                    reuseNode true
                }
            }
            environment {
                CI_ENVIRONMENT_URL = 'https://friendly-muffin-852f81.netlify.app'
            }
            steps {
                sh '''
                 echo "E2E production test stage starts"
                 npx playwright install chromium
                 npx playwright test
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
