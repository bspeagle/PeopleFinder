node {
    stage("SSH t-t-time!") {
        sshagent (credentials: ['aws-ec2-user']) {
            withCredentials([string(credentialsId: 'appServer', variable: 'IP')]) {
                sh 'ssh -o StrictHostKeyChecking=no -l ec2-user $IP "rm -r -f PeopleFinder; git clone https://github.com/bspeagle/peoplefinder.git; cd PeopleFinder; composer install --no-interaction; cd ..; rsync -av --progress PeopleFinder /var/www/html --exclude terraform --exclude jenkins --exclude .git --exclude .vscode; cd ..; rm -r PeopleFinder"'
            }
        }
    }
}