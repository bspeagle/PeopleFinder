node {
    stage("SSH t-t-time!") {
        sshagent (credentials: ['aws-ec2-user']) {
            withCredentials([string(credentialsId: 'appServer', variable: 'IP')]) {
                sh 'ssh -o StrictHostKeyChecking=no -l ec2-user $IP "rm -r -f peoplefinder; git clone https://github.com/bspeagle/peoplefinder.git; cd peoplefinder; composer install --no-interaction; cd ..; rsync -av --progress peoplefinder /var/www/html --exclude terraform --exclude jenkins --exclude .git --exclude .vscode; rm -r peoplefinder; aws s3 cp s3://peoplefinder-prod-filez/.env /var/www/html/peoplefinder;"'
            }
        }
    }
}