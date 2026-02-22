// Option 4B-MB: Trigger Jenkinsfile - orchestrates pipeline jobs (multibranch variant)
// Pure orchestrator — child jobs publish their own commit statuses
// No publishChecks here; each child job handles its own GitHub status reporting

pipeline {
    agent any

    environment {
        BRANCH_TO_BUILD = "${env.CHANGE_BRANCH ?: env.BRANCH_NAME}"
    }

    stages {
        stage('Start') {
            steps {
                echo "Starting Mobile CI/CD Pipeline (4B-MB) on branch: ${env.BRANCH_TO_BUILD}"
            }
        }

        stage('Build & Quality') {
            parallel {
                stage('iOS Build') {
                    steps {
                        build job: 'pipeline-4b-mb/ios-build',
                              parameters: [string(name: 'BRANCH_NAME', value: env.BRANCH_TO_BUILD)],
                              wait: true
                    }
                }
                stage('Android Build') {
                    steps {
                        build job: 'pipeline-4b-mb/android-build',
                              parameters: [string(name: 'BRANCH_NAME', value: env.BRANCH_TO_BUILD)],
                              wait: true
                    }
                }
                stage('iOS Tests') {
                    steps {
                        build job: 'pipeline-4b-mb/ios-unit-tests',
                              parameters: [string(name: 'BRANCH_NAME', value: env.BRANCH_TO_BUILD)],
                              wait: true
                    }
                }
                stage('Android Tests') {
                    steps {
                        build job: 'pipeline-4b-mb/android-unit-tests',
                              parameters: [string(name: 'BRANCH_NAME', value: env.BRANCH_TO_BUILD)],
                              wait: true
                    }
                }
                stage('iOS Lint') {
                    steps {
                        build job: 'pipeline-4b-mb/ios-linter',
                              parameters: [string(name: 'BRANCH_NAME', value: env.BRANCH_TO_BUILD)],
                              wait: true
                    }
                }
                stage('Android Lint') {
                    steps {
                        build job: 'pipeline-4b-mb/android-linter',
                              parameters: [string(name: 'BRANCH_NAME', value: env.BRANCH_TO_BUILD)],
                              wait: true
                    }
                }
            }
        }

        stage('Deploy') {
            parallel {
                stage('iOS Deploy') {
                    steps {
                        build job: 'pipeline-4b-mb/ios-deploy',
                              parameters: [string(name: 'BRANCH_NAME', value: env.BRANCH_TO_BUILD)],
                              wait: true
                    }
                }
                stage('Android Deploy') {
                    steps {
                        build job: 'pipeline-4b-mb/android-deploy',
                              parameters: [string(name: 'BRANCH_NAME', value: env.BRANCH_TO_BUILD)],
                              wait: true
                    }
                }
            }
        }
    }
}
