pipeline {
   agent any
   
   // parameters {
   //    credentials credentialType: 'com.cloudbees.jenkins.plugins.awscredentials.AWSCredentialsImpl', defaultValue: 'automation_terraform', name: 'AWS', required: false
   // }

   environment {
      PATH = "${PATH}:${getTerraformPath()}"
   }

   stages{
      stage('Initial Deployment Approval') {
              steps {
                script {
                def userInput = input(id: 'confirm', message: 'Start Pipeline?', parameters: [ [$class: 'BooleanParameterDefinition', defaultValue: false, description: 'Start Pipeline', name: 'confirm'] ])
             }
           }
        }

      stage('Terraform Init'){
         steps {
            slackSend (color: '#FFFF00', message: "STARTED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
            sh "terraform init"
         }
      }

      stage('Terraform Plan'){
         steps {
            sh "terraform plan -out=tfplan -input=false"
         }
      }

      stage('Final Deployment Approval') {
         steps {
            script {
               def userInput = input(id: 'confirm', message: 'Apply Terraform?', parameters: [ [$class: 'BooleanParameterDefinition', defaultValue: false, description: 'Apply terraform', name: 'confirm'] ])
            }
         }
      }

      // stage('Terraform Apply'){
      //    steps {
      //       sh "terraform apply  -input=false tfplan"
      //    }
      // }

      stage('Terraform Destroy'){
         steps {
            sh "terraform destroy -auto-approve"
         }
      }
   }

   post {
      //Trigger on Success
      success {
         slackSend (color: '#3EB991', message: "SUCCESS: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
      }

      //Trigger on Failure
      failure {
         slackSend (color: '#E01563', message: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
      }
   }

}
def getTerraformPath(){
   def tfHome = tool name: 'terraform-14', type: 'terraform'
   return tfHome
}