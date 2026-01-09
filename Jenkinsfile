pipeline {
    agent any

    // Parameters
    parameters {
        booleanParam(
            name: 'autoApprove',
            defaultValue: false,
            description: 'Automatically run apply after generating plan?'
        )
    }

    // Environment - AWS credentials stored in Jenkins
    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION    = 'us-east-1'
    }

    stages {

        stage('Checkout') {
            steps {
                // Default SCM checkout
                echo 'Checking out Terraform repo...'
            }
        }

        stage('Init & Plan') {
            steps {
                // Use Terraform tool configured in Jenkins
                script {
                    def tfHome = tool name: 'Terraform', type: 'org.jenkinsci.plugins.terraform.TerraformInstallation'
                    withEnv(["PATH+TERRAFORM=${tfHome}"]) {
                        dir('terraform') {
                            echo 'Initializing Terraform...'
                            bat 'terraform init'

                            echo 'Planning Terraform changes...'
                            bat 'terraform plan -out=tfplan'

                            echo 'Saving plan output...'
                            bat 'terraform show -no-color tfplan > tfplan.txt'
                        }
                    }
                }
            }
        }

        stage('Approval') {
            when {
                not {
                    equals expected: true, actual: params.autoApprove
                }
            }
            steps {
                script {
                    def plan = readFile 'terraform/tfplan.txt'
                    input message: "Do you want to apply the plan?",
                          parameters: [
                              text(name: 'Plan', description: 'Please review the Terraform plan', defaultValue: plan)
                          ]
                }
            }
        }

        stage('Apply') {
            steps {
                script {
                    def tfHome = tool name: 'Terraform', type: 'org.jenkinsci.plugins.terraform.TerraformInstallation'
                    withEnv(["PATH+TERRAFORM=${tfHome}"]) {
                        dir('terraform') {
                            echo 'Applying Terraform plan...'
                            bat 'terraform apply -input=false tfplan'
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished.'
        }
    }
}
