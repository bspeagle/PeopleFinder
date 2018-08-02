import java.net.URL;

node {
    stage('Clone source') {
        sh 'rm -f PeopleFinder'
        git url: 'https://github.com/bspeagle/PeopleFinder.git'
    }

    stage('Get ENV variables from S3') {
        withCredentials([usernamePassword(credentialsId: 'peopleFinder-S3', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
            sh 'AWS_ACCESS_KEY_ID=$USERNAME AWS_SECRET_ACCESS_KEY=$PASSWORD aws s3 cp s3://peoplefinder-files/.env .'
        }
    }

    stage('Build Docker Image') {
        sh '$(aws ecr get-login --no-include-email --region us-east-1)'
        sh 'docker build . -t peoplefinder'
        sh 'docker tag peoplefinder:latest 367592122643.dkr.ecr.us-east-1.amazonaws.com/peoplefinder:latest'
    }

    stage('Push Docker Image to ECR') {
        sh 'docker push 367592122643.dkr.ecr.us-east-1.amazonaws.com/peoplefinder:latest'
    }

    stage('Terraform Env-B') {
        dir ('terraform/prod/A') {
            echo 'Getting .tfstate file from S3...'
            withCredentials([usernamePassword(credentialsId: 'peopleFinder-S3', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                try {
                    sh 'AWS_ACCESS_KEY_ID=$USERNAME AWS_SECRET_ACCESS_KEY=$PASSWORD aws s3 cp s3://peoplefinder-files/terraform/prod/A/terraform.tfstate .'
                }
                catch(Exception ex) {
                    echo '.tfstate file does not exist yet. Moving on.'
                }
            }
            sh 'terraform init'
            configFileProvider([configFile(fileId: 'LMB-TF-VARS', targetLocation: '../../files/')]) {
                sh 'terraform apply -auto-approve -var-file="../../files/terraform.tfvars"'
            }
            echo 'Uploading .tfstate to S3.'
            withCredentials([usernamePassword(credentialsId: 'peopleFinder-S3', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                sh 'AWS_ACCESS_KEY_ID=$USERNAME AWS_SECRET_ACCESS_KEY=$PASSWORD aws s3 cp ./terraform.tfstate s3://peoplefinder-files/terraform/prod/A/'
            }
        }
    }

    stage('Deploy updates to ECS') {
        sh 'aws ecs update-service --cluster PeopleFinder-PROD-B --service PF-App-Deploy --force-new-deployment'
    }

    stage('Check Env-B health') {
        def url
        def message =""
        boolean fail=true
        def urlString="http://peoplefinderB.teamspeagle.com"
        def urlCheck = checkURL(urlString)
        echo urlCheck()
    }

    def checkURL = { urlString ->
        return {
            int status_code
            URL URLserver = new URL("urlString");
            URLConnection connection = (HttpURLConnection)URLserver.openConnection();
            status_code = connection.getResponseCode();
            println status_code;
        }
    }
}