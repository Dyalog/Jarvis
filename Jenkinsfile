def jarvis

node ('Docker') {
    stage ('Checkout') {
        checkout scm
    }
    withDockerRegistry(credentialsId: '6d50b250-e0a3-4240-91de-b11a1b206597') {
        stage ('Build Jarvis Container') {
            jarvis=docker.build('dyalog/jarvis', '--no-cache .')
        }
        stage ('Publish Jarvis Container') {
            jarvis.push();
        }
    }
    stage ('Cleanup') {
        sh 'docker image prune -f'
    }
}
