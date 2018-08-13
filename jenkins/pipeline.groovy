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
        withCredentials([usernamePassword(credentialsId: 'awsCLI', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
            sh '$(AWS_ACCESS_KEY_ID=$USERNAME AWS_SECRET_ACCESS_KEY=$PASSWORD aws ecr get-login --no-include-email --region us-east-1)'
        }
        sh 'docker build . -t peoplefinder'
        sh 'docker tag peoplefinder:latest 367592122643.dkr.ecr.us-east-1.amazonaws.com/peoplefinder:latest'
    }

    stage('Push Docker Image to ECR') {
        sh 'docker push 367592122643.dkr.ecr.us-east-1.amazonaws.com/peoplefinder:latest'
    }

    stage('Terraform!') {
        dir ('terraform/prod/') {
            echo 'Getting .tfstate file from S3...'
            withCredentials([usernamePassword(credentialsId: 'peopleFinder-S3', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                try {
                    sh 'AWS_ACCESS_KEY_ID=$USERNAME AWS_SECRET_ACCESS_KEY=$PASSWORD aws s3 cp s3://peoplefinder-files/terraform/prod/terraform.tfstate .'
                }
                catch(Exception ex) {
                    echo '.tfstate file does not exist yet. Moving on.'
                }
            }
            sh 'terraform init'
            configFileProvider([configFile(fileId: 'TF-VARS', targetLocation: '../files/')]) {
                sh 'terraform destroy -auto-approve -var-file="../files/terraform.tfvars"'
                try {
                    sh 'terraform apply -auto-approve -var-file="../files/terraform.tfvars"'
                    echo 'Uploading .tfstate to S3.'
                    withCredentials([usernamePassword(credentialsId: 'peopleFinder-S3', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                        sh 'AWS_ACCESS_KEY_ID=$USERNAME AWS_SECRET_ACCESS_KEY=$PASSWORD aws s3 cp ./terraform.tfstate s3://peoplefinder-files/terraform/prod/'
                    }
                }
                catch(Exception ex) {
                    echo 'Terraform apply failed :('
                    echo 'Uploading .tfstate to S3'
                    withCredentials([usernamePassword(credentialsId: 'peopleFinder-S3', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                        sh 'AWS_ACCESS_KEY_ID=$USERNAME AWS_SECRET_ACCESS_KEY=$PASSWORD aws s3 cp ./terraform.tfstate s3://peoplefinder-files/terraform/prod/'
                    }                        
                }
            }
        }
    }

    stage('Deploy updates to ECS ENV-A') {
        withCredentials([usernamePassword(credentialsId: 'awsCLI', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
            sh 'AWS_ACCESS_KEY_ID=$USERNAME AWS_SECRET_ACCESS_KEY=$PASSWORD aws ecs update-service --cluster PeopleFinder-PROD --service PF-App-Deploy --force-new-deployment'
        }
    }

    stage('Check Env-A health') {
        echo 'Sleeping for 120 secs before starting...'
        sleep 120
        echo 'Starting health check'
        sh 'statuscode=$(curl -o /dev/null --silent --head --write-out "%{http_code}\n" "peoplefinder.teamspeagle.com")'
        sh '''
            if [ $statuscode='200' ]
                then
                    echo 'Hurray! It worked!'
            else
                exit 1
            fi
        '''
    }
}