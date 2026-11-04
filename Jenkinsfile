pipeline {
    agent any

    tools {
        jdk 'JAVA_21'
    }

    stages {

        stage('Checkout Source') {
            steps {
                git branch: 'main',
                    credentialsId: 'maps',
                    url: 'https://github.com/Aditya0612-ui/maps.git'
            }
        }

        stage('Build') {
            steps {
                echo 'Building application...'
            }
        }

        stage('Test') {
            steps {
                echo 'Running tests...'
            }
        }
    }
}