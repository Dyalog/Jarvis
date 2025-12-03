def jarvis
def jarvis_d20
def BRANCH = env.BRANCH_NAME.toLowerCase()

node ('Docker') {
    stage ('Checkout') {
        checkout scm
    }
    withDockerRegistry(credentialsId: '0435817a-5f0f-47e1-9dcc-800d85e5c335') {
        stage ('Build Jarvis Containers (Dyalog v19.0)') {
            if (BRANCH == 'master') {
                jarvis=docker.build('dyalog/jarvis:dyalog-v19.0', '--no-cache .') // :latest
                jarvis_d20=docker.build('dyalog/jarvis:dyalog-v20.0', '-f Dockerfile.20.0 --no-cache .')
            } else {
                jarvis=docker.build("dyalog/jarvis:${BRANCH}-v19.0", '--no-cache .')
                jarvis_d20=docker.build("dyalog/jarvis:${BRANCH}-v20.0", '-f Dockerfile.20.0 --no-cache .')
            }
        }
        stage ('Publish Jarvis Containers (Dyalog v19.0)') {
            if ((BRANCH ==~ /^v\d.*/) || (BRANCH == 'master')) {
                jarvis.push()
            } else {
                echo 'Not publishing containers for this checkout.'
                return   
            }
        }
        stage ('Build and publish Jarvis Containers (Dyalog v20.0)')
            if ((BRANCH ==~ /^v\d.*/) || (BRANCH == 'master')) {
                // Make sure we have multiarch builders available
                sh '''
                    if ! docker buildx ls | grep multi-arch-builder ; then
                        docker run --rm --privileged docker/binfmt:66f9012c56a8316f9244ffd7622d7c21c1f6f28d
                        docker buildx create --use --name multi-arch-builder
                    fi
                '''
                // Build and publish multiarch container
                sh 'docker buildx build --file ./Dockerfile.20.0 --no-cache --pull --platform linux/amd64,linux/arm64 --tag dyalog/jarvis:dyalog-v20.0 --tag dyalog/jarvis:latest --progress=plain --push .'
            } else {
                echo 'Not publishing containers for this checkout.'
                return   
            }
    }
    stage ('Update DockerHub README file') {
        withCredentials([usernamePassword(credentialsId: '0435817a-5f0f-47e1-9dcc-800d85e5c335', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
            sh '''
            cd $WORKSPACE
            docker pushrm -f Docker/README.md dyalog/jarvis
            '''
        }
    }
    stage ('Cleanup') {
        sh 'docker image prune -f'
    }
}
