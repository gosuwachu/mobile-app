// Android Unit Tests — publishes own GitHub commit status

def setGitHubStatus(String sha, String context, String state, String description) {
    withCredentials([usernamePassword(credentialsId: 'github-app',
            usernameVariable: 'GH_APP', passwordVariable: 'GH_TOKEN')]) {
        sh """curl -s -X POST \
            -H "Authorization: token \$GH_TOKEN" \
            -H "Accept: application/vnd.github+json" \
            "https://api.github.com/repos/gosuwachu/jenkinsfiles-test-app/statuses/${sha}" \
            -d '{"state":"${state}","context":"${context}","description":"${description}","target_url":"${env.BUILD_URL}"}'"""
    }
}

def withCommitStatus(String context, Closure body) {
    def sha = env.GIT_COMMIT ?: sh(script: 'git rev-parse HEAD', returnStdout: true).trim()
    setGitHubStatus(sha, context, 'pending', 'Running...')
    try {
        body()
        setGitHubStatus(sha, context, 'success', 'Passed')
    } catch (e) {
        setGitHubStatus(sha, context, 'failure', "Failed: ${e.message}")
        throw e
    }
}

pipeline {
    agent any
    stages {
        stage('Android Unit Tests') {
            steps {
                script {
                    withCommitStatus('ci/android-unit-tests') {
                        // echo 'Running Android tests...'
                        throw new Exception('Random test failure')
                    }
                }
            }
        }
    }
}
