/*
pipeline {
    agent any

    environment {
        GIT_REPO = "https://github.com/chaudhary-prateek/Hotel-Management.git"
        GIT_BRANCH = "main"
        DOCKER_IMAGE = "hotel-management-app"
        AWS_REGION = "us-east-1"
        ECR_REPO = "hotel-management-app"
    }

    stages {
        stage('Clone Repository') {
            steps {
                git branch: "${GIT_BRANCH}", url: "${GIT_REPO}"
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_IMAGE}:latest ."
                }
            }
        }

        stage('AWS Authentication') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: '178623b5-1795-4dd4-884a-ea8209c3653a',
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                    )
                ]) {
                    script {
                        sh """
                            mkdir -p ~/.aws
        
                            echo "[default]" > ~/.aws/credentials
                            echo "aws_access_key_id=${AWS_ACCESS_KEY_ID}" >> ~/.aws/credentials
                            echo "aws_secret_access_key=${AWS_SECRET_ACCESS_KEY}" >> ~/.aws/credentials
        
                            echo "[default]" > ~/.aws/config
                            echo "region=${AWS_REGION}" >> ~/.aws/config
                            echo "output=json" >> ~/.aws/config
                        """
                    }
                }
            }
        }

        stage('Create ECR Repository') {
            steps {
                script {
                    sh '''
                        aws ecr describe-repositories --repository-names ${ECR_REPO} || \
                        aws ecr create-repository --repository-name ${ECR_REPO}
                    '''
                }
            }
        }

        stage('Push Docker Image to ECR') {
            steps {
                script {
                    sh '''
                        AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

                        aws ecr get-login-password --region ${AWS_REGION} | \
                        docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.${AWS_REGION}.amazonaws.com

                        docker tag ${DOCKER_IMAGE}:latest $AWS_ACCOUNT_ID.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:latest

                        docker push $AWS_ACCOUNT_ID.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:latest
                    '''
                }
            }
        }
    }

    // Post actions to handle success or failure
    post {
        success {
            echo '✅ Pipeline completed: Code cloned, image built, ECR created, image pushed!'
        }
        failure {
            echo '❌ Something went wrong in the pipeline.'
        }
    }
}



pipeline {
    agent any

    stages {
        stage('Install Git on EC2') {
            steps {
                sshagent (credentials: ['ec2-ssh-key']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no ubuntu@56.228.19.181 "sudo apt update && sudo apt install -y git"
                        
                        git -v
                    '''
                }
            }
        }
    }
}


pipeline {
    agent any

    stages {
        stage('Deploy Code to EC2') {
            steps {
                sshagent (credentials: ['ec2-ssh-key']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no ubuntu@56.228.19.181 "sudo rm -rf /var/www/html/* /var/www/html/.* 2>/dev/null || true"
                        ssh -o StrictHostKeyChecking=no ubuntu@56.228.19.181 "sudo git clone https://github.com/chaudhary-prateek/Hotel-Management.git /var/www/html"
                        ssh -o StrictHostKeyChecking=no ubuntu@56.228.19.181 "sudo chown -R www-data:www-data /var/www/html && sudo chmod -R 755 /var/www/html"
                    '''
                }
            }
        }
    }
}
*/

// Jenkinsfile for deploying code to EC2 instance
// This Jenkinsfile is designed to clone a Git repository and deploy the code to an EC2 instance

/*

pipeline {
    agent any

    environment {
        REPO_URL = ""
    }

    stages {
        stage('Checkout Repo') {
            steps {
                checkout scm
                script {
                    REPO_URL = sh(script: "git config --get remote.origin.url", returnStdout: true).trim()
                    echo "Repo URL is: ${REPO_URL}"
                }
            }
        }

        stage('Deploy Code to EC2') {
            steps {
                sshagent (credentials: ['ec2-ssh-key']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ubuntu@56.228.19.181 "
                            sudo rm -rf /var/www/html/* /var/www/html/.* 2>/dev/null || true &&
                            sudo git clone ${REPO_URL} /var/www/html &&
                            sudo chown -R www-data:www-data /var/www/html &&
                            sudo chmod -R 755 /var/www/html
                        "
                    """
                }
            }
        }
    }
    post {
        success {
            echo '✅ Code deployed successfully!'
        }
        failure {
            echo '❌ Deployment failed.'
        }
    }
}

*/

pipeline {
    agent any

    environment {
        REPO_URL = ""
    }

    stages {
        stage('Checkout Repo') {
            steps {
                checkout scm
                script {
                    REPO_URL = sh(script: "git config --get remote.origin.url", returnStdout: true).trim()
                    echo "Repo URL is: ${REPO_URL}"
                }
            }
        }

        stage('Deploy Code to EC2') {
            steps {
                sshagent (credentials: ['ec2-ssh-key']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ubuntu@56.228.19.181 "
                            sudo rm -rf /var/www/html/* /var/www/html/.* 2>/dev/null || true &&
                            sudo git clone ${REPO_URL} /var/www/html &&
                            sudo chown -R www-data:www-data /var/www/html &&
                            sudo chmod -R 755 /var/www/html
                        "
                    """
                }
            }
        }

        stage('Laravel Setup') {
            steps {
                sshagent (credentials: ['ec2-ssh-key']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ubuntu@56.228.19.181 "
                            cd /var/www/html &&
                            composer install &&
                            cp .env.example .env &&
                            php artisan key:generate &&
                            sudo chown -R www-data:www-data storage bootstrap/cache &&
                            sudo chmod -R 775 storage bootstrap/cache
                        "
                    """
                }
            }
        }

        stage('Run Artisan Commands') {
            steps {
                sshagent (credentials: ['ec2-ssh-key']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ubuntu@56.228.19.181 "
                            cd /var/www/html &&
                            php artisan config:clear &&
                            php artisan cache:clear &&
                            php artisan migrate --force
                        "
                    """
                }
            }
        }
    }
}
