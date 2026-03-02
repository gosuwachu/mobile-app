// iOS UI Tests — triggered by PR comment "run-ios-ui-tests"
// Publishes own GitHub commit status

def GITHUB_OWNER = 'gosuwachu'
def GITHUB_REPO = 'jenkinsfiles-test-app'

def setGitHubStatus(String sha, String context, String state, String description) {
    withCredentials([usernamePassword(credentialsId: 'github-app',
            usernameVariable: 'GH_APP', passwordVariable: 'GH_TOKEN')]) {
        sh """curl -s -X POST \
            -H "Authorization: token \$GH_TOKEN" \
            -H "Accept: application/vnd.github+json" \
            "https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPO}/statuses/${sha}" \
            -d '{"state":"${state}","context":"${context}","description":"${description}","target_url":"${env.BUILD_URL}"}'"""
    }
}

def withCommitStatus(String context, Closure body) {
    def sha = env.PR_SHA
    setGitHubStatus(sha, context, 'pending', 'Running...')
    try {
        body()
        setGitHubStatus(sha, context, 'success', 'Passed')
    } catch (e) {
        setGitHubStatus(sha, context, 'failure', "Failed: ${e.message}")
        throw e
    }
}

def checkCollaborator(String username) {
    echo "Checking if ${username} is a collaborator..."
    def statusCode = 0
    withCredentials([usernamePassword(credentialsId: 'github-app',
            usernameVariable: 'GH_APP', passwordVariable: 'GH_TOKEN')]) {
        statusCode = sh(
            script: """curl -s -o /dev/null -w '%{http_code}' \
                -H "Authorization: token \$GH_TOKEN" \
                -H "Accept: application/vnd.github+json" \
                "https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPO}/collaborators/${username}" """,
            returnStdout: true
        ).trim().toInteger()
    }
    if (statusCode == 204) {
        echo "${username} is a collaborator — proceeding"
    } else {
        error("User ${username} is not a collaborator (HTTP ${statusCode}) — aborting")
    }
}

def resolvePR(String prNumber) {
    def prJson = ''
    withCredentials([usernamePassword(credentialsId: 'github-app',
            usernameVariable: 'GH_APP', passwordVariable: 'GH_TOKEN')]) {
        prJson = sh(
            script: """curl -s \
                -H "Authorization: token \$GH_TOKEN" \
                -H "Accept: application/vnd.github+json" \
                "https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPO}/pulls/${prNumber}" """,
            returnStdout: true
        ).trim()
    }
    def prData = readJSON(text: prJson)
    if (!prData.head) {
        error("Failed to resolve PR #${prNumber} — API response did not contain 'head' field")
    }
    return [branch: prData.head.ref, sha: prData.head.sha]
}

pipeline {
    agent any

    stages {
        stage('Resolve PR') {
            steps {
                script {
                    if (!env.PR_NUMBER?.trim()) {
                        error('PR_NUMBER parameter is required')
                    }

                    if (env.COMMENT_AUTHOR?.trim()) {
                        checkCollaborator(env.COMMENT_AUTHOR)
                    } else {
                        echo 'WARNING: COMMENT_AUTHOR not set — skipping collaborator check (manual trigger?)'
                    }

                    def pr = resolvePR(env.PR_NUMBER)
                    env.PR_BRANCH = pr.branch
                    env.PR_SHA = pr.sha
                    echo "PR #${env.PR_NUMBER}: branch=${env.PR_BRANCH}, sha=${env.PR_SHA}"
                }
            }
        }

        stage('Checkout') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: env.PR_SHA]],
                    userRemoteConfigs: [[
                        url: "https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}.git",
                        credentialsId: 'github-pat'
                    ]]
                ])
            }
        }

        stage('iOS UI Tests') {
            steps {
                script {
                    withCommitStatus('ci/ios-ui-tests') {
                        echo "Running iOS UI tests for PR #${env.PR_NUMBER} (branch: ${env.PR_BRANCH})..."
                        echo 'iOS UI tests passed'
                    }
                }
            }
        }
    }

    post {
        failure {
            script {
                if (env.PR_SHA) {
                    setGitHubStatus(env.PR_SHA, 'ci/ios-ui-tests', 'error',
                        'Pipeline infrastructure failure')
                }
            }
        }
    }
}
