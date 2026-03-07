// Stub: loads orchestrator from CI repo shared library
// The real logic lives in mobile-app-ci/vars/triggerPipeline.groovy
def ciBranch = params.CI_BRANCH ?: 'main'
library identifier: "ci-lib@${ciBranch}", retriever: modernSCM(
    [$class: 'GitSCMSource',
     remote: 'https://github.com/gosuwachu/mobile-app-ci.git',
     credentialsId: 'github-pat'])
triggerPipeline()
