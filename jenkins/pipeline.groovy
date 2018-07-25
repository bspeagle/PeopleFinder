node {
    stage('Clone source') {
        sh 'rm -f PeopleFinder'
        git url: 'https://github.com/bspeagle/PeopleFinder.git'
    }

    stage('Build Docker Image') {
        sh '$(aws ecr get-login --no-include-email --region us-east-1)'
        sh 'docker build . -t peopleFinder'
        sh 'docker tag peoplefinder:latest 367592122643.dkr.ecr.us-east-1.amazonaws.com/peoplefinder:latest'
    }

    stage('Push Docker Image to ECR') {
        sh 'docker push 367592122643.dkr.ecr.us-east-1.amazonaws.com/peoplefinder:latest'
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