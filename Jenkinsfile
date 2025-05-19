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
            } else {
                echo 'This checkout is not marked for Docker image publication. To publish a docker image from this branch, add the branch name to docker_branches in Jenkinsfile.'
                jarvis=0
                return
            }
        }
        stage ('Publish Jarvis Container') {
            if (jarvis == 0) { // Not in a docker image branch
                return
            } else {
                jarvis.push();
            }
        }
    }
    stage ('Cleanup') {
        sh 'docker image prune -f'
    }
}
