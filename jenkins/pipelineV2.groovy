node {
    stage("Clone repo and add .env file") {
        sh 'rm -r -f PeopleFinder'
        sh 'git clone https://github.com/bspeagle/PeopleFinder.git'
        dir ('PeopleFinder') {
            configFileProvider([configFile(fileId: 'peopleFinder_ENV', targetLocation: '.')]) {
                sh 'mv pf.env .env'
            }
        }
        configFileProvider([configFile(fileId: 'bspeagle_PEM', targetLocation: '.')]) {
            sh 'sudo chmod 600 bspeagle.pem'
            sh 'scp -i bspeagle.pem -r PeopleFinder ec2-user@34.201.20.194:/home/ec2-user'
        }
    }
    stage("SSH t-t-time!") {
        sshagent (credentials: ['aws-ec2-user']) {
            withCredentials([string(credentialsId: 'appServer', variable: 'IP')]) {
                sh 'ssh -o StrictHostKeyChecking=no -l ec2-user $IP "cd PeopleFinder; composer install --no-interaction; cd ..; rsync -av --progress PeopleFinder /var/www/html --exclude terraform --exclude jenkins --exclude .git --exclude .vscode; rm -r PeopleFinder"'
            }
        }
    }
}