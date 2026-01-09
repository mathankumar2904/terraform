pipeline {
    agent any

    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
    }

    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        TERRAFORM_VERSION     = "1.6.0"
        TERRAFORM_DIR         = "terraform_bin"
    }

    stages {
        stage('Checkout') {
            steps {
                echo "Cloning Terraform repository..."
                git url: 'https://github.com/yeshwanthlm/Terraform-Jenkins.git', branch: 'main'
            }
        }

        stage('Download Terraform') {
            steps {
                echo "Downloading Terraform..."
                bat """
                if not exist %TERRAFORM_DIR% mkdir %TERRAFORM_DIR%
                curl -o terraform.zip https://releases.hashicorp.com/terraform/%TERRAFORM_VERSION%/terraform_%TERRAFORM_VERSION%_windows_amd64.zip
                powershell -Command "Expand-Archive -Path terraform.zip -DestinationPath %TERRAFORM_DIR% -Force"
                """
            }
        }

        stage('Init & Plan') {
            steps {
                echo "Initializing Terraform..."
                bat """
                cd terraform
                ..\\%TERRAFORM_DIR%\\terraform.exe init
                ..\\%TERRAFORM_DIR%\\terraform.exe plan -out=tfplan
                ..\\%TERRAFORM_DIR%\\terraform.exe show -no-color tfplan > tfplan.txt
                """
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
                        parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                }
            }
        }

        stage('Apply') {
            steps {
                echo "Applying Terraform plan..."
                bat """
                cd terraform
                ..\\%TERRAFORM_DIR%\\terraform.exe apply -auto-approve tfplan
                """
            }
        }
    }

    post {
        always {
            echo "Pipeline finished."
        }
    }
}
