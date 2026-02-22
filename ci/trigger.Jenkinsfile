// Option 4A-MB: Trigger Jenkinsfile - orchestrates pipeline jobs (multibranch variant)
// Publishes per-stage GitHub Checks and passes BRANCH_NAME to child jobs

def runWithCheck(String checkName, String jobPath, String branch) {
    checkName = "${checkName} (4A-MB)"
    publishChecks name: checkName, status: 'IN_PROGRESS', summary: "Running ${checkName}..."
    try {
        build job: jobPath,
              parameters: [string(name: 'BRANCH_NAME', value: branch)],
              wait: true
        publishChecks name: checkName, status: 'COMPLETED',
            conclusion: 'SUCCESS', summary: "${checkName} passed"
    } catch (e) {
        publishChecks name: checkName, status: 'COMPLETED',
            conclusion: 'FAILURE', summary: "${checkName} failed: ${e.message}"
        throw e
    }
}

pipeline {
    agent any

    environment {
        BRANCH_TO_BUILD = "${env.CHANGE_BRANCH ?: env.BRANCH_NAME}"
    }

    stages {
        stage('Start') {
            steps {
                shell: 'env'
                echo "Starting Mobile CI/CD Pipeline (4A-MB) on branch: ${env.BRANCH_TO_BUILD}"
            }
        }

        stage('Build & Quality') {
            parallel {
                stage('iOS Build') {
                    steps { script { runWithCheck('iOS Build', 'pipeline-4a-mb/ios-build', env.BRANCH_TO_BUILD) } }
                }
                stage('Android Build') {
                    steps { script { runWithCheck('Android Build', 'pipeline-4a-mb/android-build', env.BRANCH_TO_BUILD) } }
                }
                stage('iOS Tests') {
                    steps { script { runWithCheck('iOS Tests', 'pipeline-4a-mb/ios-unit-tests', env.BRANCH_TO_BUILD) } }
                }
                stage('Android Tests') {
                    steps { script { runWithCheck('Android Tests', 'pipeline-4a-mb/android-unit-tests', env.BRANCH_TO_BUILD) } }
                }
                stage('iOS Lint') {
                    steps { script { runWithCheck('iOS Lint', 'pipeline-4a-mb/ios-linter', env.BRANCH_TO_BUILD) } }
                }
                stage('Android Lint') {
                    steps { script { runWithCheck('Android Lint', 'pipeline-4a-mb/android-linter', env.BRANCH_TO_BUILD) } }
                }
            }
        }

        stage('Deploy') {
            parallel {
                stage('iOS Deploy') {
                    steps { script { runWithCheck('iOS Deploy', 'pipeline-4a-mb/ios-deploy', env.BRANCH_TO_BUILD) } }
                }
                stage('Android Deploy') {
                    steps { script { runWithCheck('Android Deploy', 'pipeline-4a-mb/android-deploy', env.BRANCH_TO_BUILD) } }
                }
            }
        }
    }
}
