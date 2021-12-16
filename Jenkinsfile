def jarvis
def BRANCH = env.BRANCH_NAME.toLowerCase()

node ('Docker') {
    stage ('Checkout') {
        checkout scm
    }
    withDockerRegistry(credentialsId: '0435817a-5f0f-47e1-9dcc-800d85e5c335') {
        stage ('Build Jarvis Container') {
            if (BRANCH == 'master') {
                jarvis=docker.build('dyalog/jarvis', '--no-cache .')
            } else {
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
