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

    stage('Deploy updates to ECS') {
        sh 'aws ecs update-service --cluster PeopleFinder --service PF_DEPLOY_SVC --force-new-deployment'
    }

    /*stage('Terraform!') {
        dir ('terraform') {
            sh 'terraform init'
            configFileProvider([configFile(fileId: 'LMB-TF-VARS', targetLocation: './files/')]) {
                sh 'terraform apply -auto-approve -var-file="./files/terraform.tfvars"'
            }
        }
    }*/


}