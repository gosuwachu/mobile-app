// Option 4A-MB: Trigger Jenkinsfile - orchestrates pipeline jobs (multibranch variant)
// Publishes per-stage GitHub Checks and passes BRANCH_NAME to child jobs
// Smart re-run: detects GitHub Check re-run and skips already-passed child jobs

def GITHUB_OWNER = 'gosuwachu'
def GITHUB_REPO = 'jenkinsfiles-test-app'
def CHECK_SUFFIX = '(4A-MB)'

def STAGE_NAMES = [
    'iOS Build', 'Android Build', 'iOS Tests', 'Android Tests',
    'iOS Lint', 'Android Lint', 'iOS Deploy', 'Android Deploy',
]

// Detect if this build is a GitHub Check re-run and compute which stages to skip
def computeRerunSkips(stageNames, checkSuffix) {
    def skips = [:]
    stageNames.each { s -> skips[s] = false }

    def rerunCauses = currentBuild.getBuildCauses(
        'io.jenkins.plugins.checks.github.CheckRunGHEventSubscriber$GitHubChecksRerunActionCause'
    )
    if (!rerunCauses) {
        echo 'Not a check re-run — running all stages normally'
        return skips
    }

    echo "Detected GitHub Check re-run: ${rerunCauses[0]}"
    echo 'Querying GitHub API for existing check statuses...'

    def commitSha = env.GIT_COMMIT ?: sh(script: 'git rev-parse HEAD', returnStdout: true).trim()

    try {
        def checksJson = ''
        withCredentials([usernamePassword(credentialsId: 'github-app',
                usernameVariable: 'GH_APP', passwordVariable: 'GH_TOKEN')]) {
            checksJson = sh(script: """
                curl -s -H "Authorization: token \$GH_TOKEN" \
                     -H "Accept: application/vnd.github+json" \
                     "https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPO}/commits/${commitSha}/check-runs?per_page=100"
            """, returnStdout: true).trim()
        }

        def checks = readJSON text: checksJson
        def checkConclusions = [:]
        checks.check_runs.each { cr ->
            checkConclusions[cr.name] = cr.conclusion
        }

        echo "Found ${checkConclusions.size()} check runs for commit ${commitSha}"

        stageNames.each { stageName ->
            def fullCheckName = "${stageName} ${checkSuffix}"
            def conclusion = checkConclusions[fullCheckName]
            if (conclusion == 'success') {
                echo "  SKIP ${stageName} — already SUCCESS"
                skips[stageName] = true
            } else {
                echo "  RUN  ${stageName} — conclusion: ${conclusion ?: 'not found'}"
            }
        }

        // If ALL stages would be skipped, run everything (user explicitly re-ran a passed check)
        if (skips.values().every { it }) {
            echo 'All checks already passed — re-running everything'
            skips.each { k, v -> skips[k] = false }
        }
    } catch (e) {
        echo "WARNING: GitHub API call failed: ${e.message}. Running all stages."
        skips.each { k, v -> skips[k] = false }
    }

    return skips
}

def runWithCheck(String checkName, String jobPath, String branch) {
    def fullCheckName = "${checkName} ${CHECK_SUFFIX}"
    publishChecks name: fullCheckName, status: 'IN_PROGRESS', summary: "Running ${checkName}..."
    try {
        build job: jobPath,
              parameters: [string(name: 'BRANCH_NAME', value: branch)],
              wait: true
        publishChecks name: fullCheckName, status: 'COMPLETED',
            conclusion: 'SUCCESS', summary: "${checkName} passed"
    } catch (e) {
        def rerunLink = ''
        if (env.JOB_URL) {
            def encodedStage = java.net.URLEncoder.encode(checkName, 'UTF-8')
            rerunLink = "\n\n[Re-run only ${checkName}](${env.JOB_URL}buildWithParameters?ONLY_STAGE=${encodedStage})"
        }
        publishChecks name: fullCheckName, status: 'COMPLETED',
            conclusion: 'FAILURE', summary: "${checkName} failed: ${e.message}${rerunLink}"
        throw e
    }
}

pipeline {
    agent any

    parameters {
        string(name: 'ONLY_STAGE', defaultValue: '', description: 'If set, run only this stage (e.g. "Android Tests"). Leave empty to run all.')
    }

    environment {
        BRANCH_TO_BUILD = "${env.CHANGE_BRANCH ?: env.BRANCH_NAME}"
    }

    stages {
        stage('Start') {
            steps {
                script {
                    echo "Starting Mobile CI/CD Pipeline (4A-MB) on branch: ${env.BRANCH_TO_BUILD}"

                    // Compute effective skips
                    def stageSkips = [:]

                    if (params.ONLY_STAGE?.trim()) {
                        echo "ONLY_STAGE='${params.ONLY_STAGE}' — running only that stage"
                        STAGE_NAMES.each { s ->
                            stageSkips[s] = (s != params.ONLY_STAGE.trim())
                        }
                    } else {
                        stageSkips = computeRerunSkips(STAGE_NAMES, CHECK_SUFFIX)
                    }

                    env.STAGE_SKIPS = writeJSON(returnText: true, json: stageSkips)

                    // Publish NEUTRAL for skipped stages
                    stageSkips.each { stageName, skip ->
                        if (skip) {
                            def fullCheckName = "${stageName} ${CHECK_SUFFIX}"
                            publishChecks name: fullCheckName, status: 'COMPLETED',
                                conclusion: 'NEUTRAL', summary: "${fullCheckName} skipped"
                        }
                    }
                }
            }
        }

        stage('Build & Quality') {
            parallel {
                stage('iOS Build') {
                    when { expression { !readJSON(text: env.STAGE_SKIPS)['iOS Build'] } }
                    steps { script { runWithCheck('iOS Build', 'pipeline-4a-mb/ios-build', env.BRANCH_TO_BUILD) } }
                }
                stage('Android Build') {
                    when { expression { !readJSON(text: env.STAGE_SKIPS)['Android Build'] } }
                    steps { script { runWithCheck('Android Build', 'pipeline-4a-mb/android-build', env.BRANCH_TO_BUILD) } }
                }
                stage('iOS Tests') {
                    when { expression { !readJSON(text: env.STAGE_SKIPS)['iOS Tests'] } }
                    steps { script { runWithCheck('iOS Tests', 'pipeline-4a-mb/ios-unit-tests', env.BRANCH_TO_BUILD) } }
                }
                stage('Android Tests') {
                    when { expression { !readJSON(text: env.STAGE_SKIPS)['Android Tests'] } }
                    steps { script { runWithCheck('Android Tests', 'pipeline-4a-mb/android-unit-tests', env.BRANCH_TO_BUILD) } }
                }
                stage('iOS Lint') {
                    when { expression { !readJSON(text: env.STAGE_SKIPS)['iOS Lint'] } }
                    steps { script { runWithCheck('iOS Lint', 'pipeline-4a-mb/ios-linter', env.BRANCH_TO_BUILD) } }
                }
                stage('Android Lint') {
                    when { expression { !readJSON(text: env.STAGE_SKIPS)['Android Lint'] } }
                    steps { script { runWithCheck('Android Lint', 'pipeline-4a-mb/android-linter', env.BRANCH_TO_BUILD) } }
                }
            }
        }

        stage('Deploy') {
            parallel {
                stage('iOS Deploy') {
                    when { expression { !readJSON(text: env.STAGE_SKIPS)['iOS Deploy'] } }
                    steps { script { runWithCheck('iOS Deploy', 'pipeline-4a-mb/ios-deploy', env.BRANCH_TO_BUILD) } }
                }
                stage('Android Deploy') {
                    when { expression { !readJSON(text: env.STAGE_SKIPS)['Android Deploy'] } }
                    steps { script { runWithCheck('Android Deploy', 'pipeline-4a-mb/android-deploy', env.BRANCH_TO_BUILD) } }
                }
            }
        }
    }
}
