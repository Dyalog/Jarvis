def jarvis
def BRANCH = env.BRANCH_NAME.toLowerCase()
def docker_branches = [
    'dyalog-v20.0-techpreview'
]

node ('Docker') {
    stage ('Checkout') {
        checkout scm
    }
    withDockerRegistry(credentialsId: '0435817a-5f0f-47e1-9dcc-800d85e5c335') {
        stage ('Build Jarvis Container') {
            if (BRANCH == 'master') {
                jarvis=docker.build('dyalog/jarvis', '--no-cache .')
            } else if (BRANCH in docker_branches) {
                jarvis=docker.build("dyalog/jarvis:${BRANCH}", '--no-cache .')
            }
        }
        stage ('Publish Jarvis Container') {
            jarvis.push();
        }
    }
    stage ('Cleanup') {
        sh 'docker image prune -f'
    }
}
