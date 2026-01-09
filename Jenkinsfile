pipeline {
    agent any

    parameters {
        booleanParam(
            name: 'autoApprove',
            defaultValue: false,
            description: 'Automatically run apply after generating plan?'
        )
    }

    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION    = 'us-east-1'
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'Checking out Terraform repo...'
                git branch: 'main', url: 'https://github.com/mathankumar2904/terraform.git'
            }
        }

        stage('Init & Plan') {
            steps {
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
                dir('terraform') {
                    echo 'Applying Terraform plan...'
                    bat 'terraform apply -input=false tfplan'
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
