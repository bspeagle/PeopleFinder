node {
    stage('Clone source') {
        sh 'rm -f PeopleFinder'
        git url: 'https://github.com/bspeagle/PeopleFinder.git'
    }

    stage('Build Docker Image') {
        sh '$(sudo aws ecr get-login --no-include-email --region us-east-1)'
        echo 'logged in!'
        sh 'sudo docker build . -t peopleFinder'
        echo 'image built!'
        sh 'sudo docker tag peoplefinder:latest 367592122643.dkr.ecr.us-east-1.amazonaws.com/peoplefinder:latest'
    }

    stage('Push Docker Image to ECR') {
        sh 'sudo docker push 367592122643.dkr.ecr.us-east-1.amazonaws.com/peoplefinder:latest'
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