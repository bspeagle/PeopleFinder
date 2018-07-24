node {
    stage('Clone source') {
        sh 'rm -f PeopleFinder'
        git url: 'https://github.com/bspeagle/PeopleFinder.git'
    }

    stage('Terraform!') {
        dir ('terraform') {
            sh 'terraform init'
            configFileProvider([configFile(fileId: 'LMB-TF-VARS', targetLocation: '../files/')]) {
                //sh 'terraform destroy -auto-approve -var-file="../files/terraform.tfvars"'
                sh 'terraform apply -auto-approve -var-file="../files/terraform.tfvars"'
            }
        }
    }
}