pipeline {
    agent any

    // Note: Ensure a JDK named 'JAVA_21' is configured in:
    // Manage Jenkins -> Tools -> JDK Installations (or comment this block out if Java 21 is in system PATH)
    tools {
        jdk 'JAVA_21'
    }

    stages {
        stage('Checkout Source') {
            steps {
                echo 'Pulling code from SCM...'
                checkout scm
            }
        }

        stage('Build') {
            steps {
                echo 'Building application binary...'
                script {
                    if (isUnix()) {
                        sh 'chmod +x mvnw || true'
                        sh './mvnw clean package -DskipTests'
                    } else {
                        bat 'mvnw.cmd clean package -DskipTests'
                    }
                }
            }
        }

        stage('Test') {
            steps {
                echo 'Running Unit & Integration Tests...'
                script {
                    if (isUnix()) {
                        sh './mvnw test'
                    } else {
                        bat 'mvnw.cmd test'
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying artifact to staging/production environment...'
                script {
                    if (isUnix()) {
                        sh 'echo "Deployment successful!"'
                    } else {
                        bat 'echo Deployment successful!'
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline executed successfully.'
        }

        failure {
            echo 'Pipeline failed. Check logs for details.'
        }
    }
}
