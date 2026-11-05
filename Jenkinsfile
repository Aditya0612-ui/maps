
pipeline {
    agent any

    tools {
        jdk 'JAVA_21'
    }

    stages {

        stage('Checkout Source') {
            steps {
                echo 'Connecting to GitHub...'

                git branch: 'main',
                    credentialsId: 'maps',
                    url: 'https://github.com/Aditya0612-ui/maps.git'

                echo 'GitHub checkout successful!'
            }
        }

        stage('Verify Project') {
            steps {
                sh 'ls -la'
                sh 'test -f pubspec.yaml'

                echo 'Flutter project verified!'
            }
        }

        stage('Build') {
            steps {
                echo 'Build stage executed successfully.'
            }
        }

        stage('Test') {
            steps {
                echo 'Test stage executed successfully.'
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }

        failure {
            echo 'Pipeline failed. Check Console Output.'
        }
    }
}
