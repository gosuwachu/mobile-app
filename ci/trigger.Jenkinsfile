// Option 4A-MB: Trigger Jenkinsfile - orchestrates pipeline jobs (multibranch variant)
// Publishes per-stage GitHub Checks and passes BRANCH_NAME to child jobs

def branchToBuild = env.CHANGE_BRANCH ?: env.BRANCH_NAME

def runWithCheck(String checkName, String jobPath) {
    publishChecks name: checkName, status: 'IN_PROGRESS', summary: "Running ${checkName}..."
    try {
        build job: jobPath,
              parameters: [string(name: 'BRANCH_NAME', value: branchToBuild)],
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

    stages {
        stage('Start') {
            steps {
                echo "Starting Mobile CI/CD Pipeline (4A-MB) on branch: ${branchToBuild}"
            }
        }

        stage('Build & Quality') {
            parallel {
                stage('iOS Build') {
                    steps { script { runWithCheck('iOS Build', 'pipeline-4a-mb/ios-build') } }
                }
                stage('Android Build') {
                    steps { script { runWithCheck('Android Build', 'pipeline-4a-mb/android-build') } }
                }
                stage('iOS Tests') {
                    steps { script { runWithCheck('iOS Tests', 'pipeline-4a-mb/ios-unit-tests') } }
                }
                stage('Android Tests') {
                    steps { script { runWithCheck('Android Tests', 'pipeline-4a-mb/android-unit-tests') } }
                }
                stage('iOS Lint') {
                    steps { script { runWithCheck('iOS Lint', 'pipeline-4a-mb/ios-linter') } }
                }
                stage('Android Lint') {
                    steps { script { runWithCheck('Android Lint', 'pipeline-4a-mb/android-linter') } }
                }
            }
        }

        stage('Deploy') {
            parallel {
                stage('iOS Deploy') {
                    steps { script { runWithCheck('iOS Deploy', 'pipeline-4a-mb/ios-deploy') } }
                }
                stage('Android Deploy') {
                    steps { script { runWithCheck('Android Deploy', 'pipeline-4a-mb/android-deploy') } }
                }
            }
        }
    }
}
