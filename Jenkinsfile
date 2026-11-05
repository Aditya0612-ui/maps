pipeline {
    agent any

    options {
        skipDefaultCheckout(true)
    }

    environment {
        FLUTTER_HOME = '/opt/flutter'
        ANDROID_HOME = '/opt/android-sdk'
        ANDROID_SDK_ROOT = '/opt/android-sdk'
        PATH = "/opt/flutter/bin:/opt/android-sdk/platform-tools:/opt/android-sdk/cmdline-tools/latest/bin:${env.PATH}"
    }

    stages {

        stage('Checkout Source') {
            steps {
                echo 'Pulling code from GitHub...'
                checkout scm
            }
        }

        stage('Check Flutter Environment') {
            steps {
                sh '''
                    echo "Checking Flutter..."
                    flutter --version

                    echo "Checking Dart..."
                    dart --version

                    echo "Checking Android SDK..."
                    echo $ANDROID_HOME
                    flutter doctor -v
                '''
            }
        }

        stage('Install Dependencies') {
            steps {
                echo 'Installing Flutter dependencies...'
                sh 'flutter pub get'
            }
        }

        stage('Build APK') {
            steps {
                echo 'Building Android APK...'
                sh 'flutter build apk --release'
            }
        }

        stage('Test') {
            steps {
                script {
                    if (fileExists('test')) {
                        sh 'flutter test'
                    } else {
                        echo 'No test directory found. Skipping Flutter tests.'
                    }
                }
            }
        }

        stage('Archive APK') {
            steps {
                archiveArtifacts artifacts: 'build/app/outputs/flutter-apk/*.apk',
                                 fingerprint: true
            }
        }
    }

    post {
        success {
            echo 'Flutter Android build completed successfully!'
        }

        failure {
            echo 'Pipeline failed. Check the Jenkins console output.'
        }
    }
}
