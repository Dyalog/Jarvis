def jarvis
def jarvis_d20
def BRANCH = env.BRANCH_NAME.toLowerCase()
def TAG = env.TAG_NAME.toLowerCase()

node ('Docker') {
    stage ('Checkout') {
        checkout scm
    }
    withDockerRegistry(credentialsId: '0435817a-5f0f-47e1-9dcc-800d85e5c335') {
        stage ('Build Jarvis Containers') {
            if (BRANCH == 'master') {
                jarvis=docker.build('dyalog/jarvis', '--no-cache .') // :latest
                jarvis_d20=docker.build('dyalog/jarvis:dyalog-v20.0', '-f Dockerfile.20.0', '--no-cache')
            } else {
                jarvis=docker.build("dyalog/jarvis:${BRANCH}-v19.0", '--no-cache .')
                jarvis_d20=docker.build("dyalog/jarvis:${BRANCH}-v20.0", '-f Dockerfile.20.0', '--no-cache')
            }
        }
        stage ('Publish Jarvis Containers') {
            if ((TAG ==~ /^v\d.*/) || (BRANCH == 'master')) {
                jarvis.push()
                jarvis_d20.push()
            } else {
                echo 'Not publishing containers for this checkout.'
                return   
            }
        }
    }
    stage ('Cleanup') {
        sh 'docker image prune -f'
    }
}
