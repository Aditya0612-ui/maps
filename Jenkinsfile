pipeline {
    agent any

    triggers {
        githubPush()
    }

    options {
        disableConcurrentBuilds()
        timeout(time: 45, unit: 'MINUTES')
        skipDefaultCheckout()
    }

    environment {
        CI = 'true'
        FLUTTER_ROOT = '/opt/flutter'
        ANDROID_HOME = '/usr/lib/android-sdk'
        ANDROID_SDK_ROOT = '/usr/lib/android-sdk'
        GRADLE_OPTS = '-Dorg.gradle.daemon=false -Dorg.gradle.jvmargs="-Xmx2048m -XX:MaxMetaspaceSize=512m"'
        PATH = "/opt/flutter/bin:/usr/lib/android-sdk/cmdline-tools/latest/bin:/usr/lib/android-sdk/platform-tools:${env.PATH}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Verify Toolchain') {
            steps {
                sh 'flutter --version'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'flutter pub get'
            }
        }

        stage('Analyze Project') {
            steps {
                sh 'flutter analyze'
            }
        }

        stage('Run Tests') {
            steps {
                sh 'flutter test'
            }
        }

        stage('Build App Bundle (AAB)') {
            steps {
                // Inject release keystore from Jenkins Credentials.
                // Add these credentials in Jenkins → Manage Jenkins → Credentials:
                //   - ID: release_keystore   → Secret File  (upload release.keystore)
                //   - ID: key_alias          → Secret Text  ("release")
                //   - ID: key_password       → Secret Text  (keystore key password)
                //   - ID: store_password     → Secret Text  (keystore store password)
                withCredentials([
                    file(credentialsId: 'release_keystore', variable: 'KEYSTORE_PATH'),
                    string(credentialsId: 'key_alias',      variable: 'KEY_ALIAS'),
                    string(credentialsId: 'key_password',   variable: 'KEY_PASSWORD'),
                    string(credentialsId: 'store_password', variable: 'STORE_PASSWORD')
                ]) {
                    sh 'flutter build appbundle --release'
                }
            }
        }

        stage('Build APK') {
            steps {
                withCredentials([
                    file(credentialsId: 'release_keystore', variable: 'KEYSTORE_PATH'),
                    string(credentialsId: 'key_alias',      variable: 'KEY_ALIAS'),
                    string(credentialsId: 'key_password',   variable: 'KEY_PASSWORD'),
                    string(credentialsId: 'store_password', variable: 'STORE_PASSWORD')
                ]) {
                    sh 'flutter build apk --release'
                }
            }
        }
    }

    post {
        success {
            archiveArtifacts artifacts: 'build/app/outputs/bundle/release/app-release.aab, build/app/outputs/flutter-apk/app-release.apk', fingerprint: true
            echo 'Flutter Android build completed successfully! Both AAB and APK generated.'
        }
        failure {
            echo 'Pipeline failed. Check the Jenkins console output.'
        }
    }
}
