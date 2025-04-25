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

        stage('Install PHP Extensions') {
            steps {
                sshagent (credentials: ['ec2-ssh-key']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no ubuntu@56.228.19.181 '
                            sudo apt update &&
                            sudo apt install -y php-xml php-curl php-mbstring php-zip php-bcmath php-gd php-mysql unzip
                        '
                    '''
                }
            }
        }


        stage('Laravel Setup') {
            steps {
                sshagent (credentials: ['ec2-ssh-key']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ubuntu@56.228.19.181 "
                            sudo chown -R ubuntu:ubuntu /var/www/html &&
                            cd /var/www/html &&
                            mkdir -p vendor && 
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
                            sudo chown -R www-data:www-data /var/www/html/storage &&
                            sudo chmod -R 775 /var/www/html/storage &&
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


*/

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
                            sudo git clone ${REPO_URL} /var/www/html/hotelManagement &&
                            sudo chown -R www-data:www-data /var/www/html/hotelManagement &&
                            sudo chmod -R 755 /var/www/html/hotelManagement
                        "
                    """
                }
            }
        }

        stage('Install PHP Extensions') {
            steps {
                sshagent (credentials: ['ec2-ssh-key']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no ubuntu@56.228.19.181 '
                            sudo apt update &&
                            sudo apt install -y php php-cli php-xml php-curl php-mbstring php-zip php-bcmath php-gd php-mysql unzip apache2 libapache2-mod-php
                        '
                    '''
                }
            }
        }

        stage('Apache Config & Laravel Setup') {
            steps {
                sshagent (credentials: ['ec2-ssh-key']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ubuntu@56.228.19.181 "
                            # Update Apache to point to public folder
                            sudo bash -c 'cat > /etc/apache2/sites-available/000-default.conf <<EOF
<VirtualHost *:80>
    DocumentRoot /var/www/html/hotelManagement/public

    <Directory /var/www/html/hotelManagement/public>
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF' &&

                            sudo a2enmod rewrite &&
                            sudo systemctl restart apache2 &&

                            # Laravel Setup
                            sudo chown -R ubuntu:ubuntu /var/www/html/hotelManagement &&
                            cd /var/www/html/hotelManagement &&
                            cp .env.example .env &&
                            composer install &&
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
                        ssh -o StrictHostKeyChecking=no ubuntu@56.228.19.181 '
                            sudo chown -R www-data:www-data /var/www/html/hotelManagement/storage /var/www/html/hotelManagement/bootstrap/cache &&
                            sudo chmod -R 775 /var/www/html/hotelManagement/storage /var/www/html/hotelManagement/bootstrap/cache &&
                            sudo touch /var/www/html/hotelManagement/storage/logs/laravel.log &&
                            sudo chown www-data:www-data /var/www/html/hotelManagement/storage/logs/laravel.log &&
                            sudo chmod 664 /var/www/html/hotelManagement/storage/logs/laravel.log &&
                            cd /var/www/html/hotelManagement &&
                            php artisan config:clear &&
                            php artisan route:clear &&
                            php artisan view:clear &&
                            php artisan config:cache &&
                            php artisan migrate --force
                        '
                    """
                }
            }
        }
    }
}

*/

pipeline {
    agent any

    environment {
        REMOTE_USER = "ubuntu"
        REMOTE_HOST = "56.228.19.181"
        PROJECT_DIR = "/var/www/html/hotelManagement"
        SSH_CREDENTIALS_ID = 'ec2-ssh-key'
    }

    stages {
        stage('Pull Latest Code') {
            steps {
                sshagent (credentials: [env.SSH_CREDENTIALS_ID]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST} '
                            cd ${PROJECT_DIR} &&
                            git pull origin main
                        '
                    """
                }
            }
        }

        // stage('Laravel Update') {
        //     steps {
        //         sshagent (credentials: ['ec2-ssh-key']) {
        //             sh """
        //                 ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST} '
        //                     cd ${PROJECT_DIR} &&
        //                     composer install --no-interaction --prefer-dist --optimize-autoloader &&
        //                     php artisan migrate --force &&
        //                     php artisan config:clear &&
        //                     php artisan config:cache &&
        //                     php artisan route:clear &&
        //                     php artisan view:clear
        //                 '
        //             """
        //         }
        //     }
        // }
    }
}


/*

pipeline {
    agent any

    environment {
        EC2_HOST = '13.51.166.58'
        EC2_USER = 'ubuntu'
        PROJECT_DIR = '/var/www/html/hotelManagement'
        SSH_CREDENTIALS_ID = 'ec2-ssh-key'
    }

    stages {
        stage('Pull Latest Code') {
            steps {
                sshagent (credentials: [env.SSH_CREDENTIALS_ID]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${env.EC2_USER}@${env.EC2_HOST} '
                            cd ${env.PROJECT_DIR} &&
                            git reset --hard &&
                            git pull origin main &&
                            composer install --no-interaction --prefer-dist --optimize-autoloader
                        '
                    """
                }
            }
        }

        stage('Laravel Maintenance & Cache') {
            steps {
                sshagent (credentials: [env.SSH_CREDENTIALS_ID]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${env.EC2_USER}@${env.EC2_HOST} '
                            cd ${env.PROJECT_DIR} &&
                            php artisan down || true &&
                            php artisan migrate --force &&
                            php artisan config:clear &&
                            php artisan route:clear &&
                            php artisan view:clear &&
                            php artisan config:cache &&
                            php artisan up
                        '
                    """
                }
            }
        }
    }
}
*/







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
                            sudo git pull env.{REPO_URL} /var/www/html/hotelManagement &&
                            sudo chown -R www-data:www-data /var/www/html/hotelManagement &&
                            sudo chmod -R 755 /var/www/html/hotelManagement
                        "
                    """
                }
            }
        }
/*        
        stage('Pull Latest Code') {
            steps {
                sshagent (credentials: ['ec2-ssh-key']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST} '
                            cd ${PROJECT_DIR} &&
                            git pull origin main
                        '
                    """
                }
            }
        }

        stage('Install PHP Extensions') {
            steps {
                sshagent (credentials: ['ec2-ssh-key']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no ubuntu@56.228.19.181 '
                            sudo apt update &&
                            sudo apt install -y php php-cli php-xml php-curl php-mbstring php-zip php-bcmath php-gd php-mysql unzip apache2 libapache2-mod-php
                        '
                    '''
                }
            }
        }

        stage('Apache Config & Laravel Setup') {
            steps {
                sshagent (credentials: ['ec2-ssh-key']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ubuntu@56.228.19.181 "
                            # Update Apache to point to public folder
                            sudo bash -c 'cat > /etc/apache2/sites-available/000-default.conf <<EOF
<VirtualHost *:80>
    DocumentRoot /var/www/html/hotelManagement/public

    <Directory /var/www/html/hotelManagement/public>
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF' &&

                            sudo a2enmod rewrite &&
                            sudo systemctl restart apache2 &&

                            # Laravel Setup
                            sudo chown -R ubuntu:ubuntu /var/www/html/hotelManagement &&
                            cd /var/www/html/hotelManagement &&
                            cp .env.example .env &&
                            composer install &&
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
                        ssh -o StrictHostKeyChecking=no ubuntu@56.228.19.181 '
                            sudo chown -R www-data:www-data /var/www/html/hotelManagement/storage /var/www/html/hotelManagement/bootstrap/cache &&
                            sudo chmod -R 775 /var/www/html/hotelManagement/storage /var/www/html/hotelManagement/bootstrap/cache &&
                            sudo touch /var/www/html/hotelManagement/storage/logs/laravel.log &&
                            sudo chown www-data:www-data /var/www/html/hotelManagement/storage/logs/laravel.log &&
                            sudo chmod 664 /var/www/html/hotelManagement/storage/logs/laravel.log &&
                            cd /var/www/html/hotelManagement &&
                            php artisan optimize:clear
                        '
                    """
                }
            }
        }
    }
}

*/