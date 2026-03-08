# App Repo (mobile-app)

Mobile app repository for the Jenkins CI/CD test environment. Contains the orchestrator pipeline and platform source directories.

## Project Structure

```
├── ci/
│   └── trigger.Jenkinsfile          # Orchestrator pipeline (multibranch)
├── ios/
│   ├── main.swift                   # Placeholder source file
│   └── ios_build/                   # Build scripts invoked by ci-cli
│       ├── build.sh                 # iOS build (simulates xcodebuild)
│       ├── lint.sh                  # iOS linter (simulates SwiftLint)
│       ├── unit-tests.sh            # iOS unit tests
│       └── ui-tests.sh             # iOS UI tests
└── android/
    ├── main.kt                      # Placeholder source file
    └── android_build/               # Build scripts invoked by ci-cli
        ├── build.sh                 # Android build (simulates gradle assembleDebug)
        ├── lint.sh                  # Android linter (simulates gradle lint)
        ├── unit-tests.sh            # Android unit tests
        └── ui-tests.sh             # Android UI tests
```

## How It Works

The Jenkins multibranch pipeline (`mobile-app/trigger`) discovers branches and PRs in this repo and runs `ci/trigger.Jenkinsfile`.

The trigger orchestrator:
1. Checks if the PR author is a collaborator (blocks non-collaborators without approved reviews)
2. Detects which platforms changed (compares PR diff against `ios/` and `android/` directories)
3. Publishes "skipped" statuses for unchanged platforms
4. Triggers child jobs in parallel via the omnibus job (`mobile-app-support/omnibus`), passing:
   - `BRANCH_NAME` — the branch to build
   - `COMMIT_SHA` — pinned to `env.GIT_COMMIT` so all child jobs use the same commit
   - `CHANGE_ID` — PR number (from Jenkins native `env.CHANGE_ID`, empty for branch builds)
   - `JENKINSFILE` — path to the child Jenkinsfile in the CI repo
   - `CI_BRANCH` — CI repo branch to checkout Jenkinsfiles from (defaults to `main`, configurable via pipeline parameter)

### Pipeline Stages

```
Start (collaborator check + platform detection)
  → Build & Quality (parallel: iOS/Android build, tests, lint)
      Build jobs trigger their corresponding deploy jobs directly via omnibus,
      passing CONTEXT_JSON (structured JSON from the build step's stdout)
```

### Commit Status Contexts

| Platform | Contexts |
|----------|----------|
| iOS | `ci/ios-build`, `ci/ios-unit-tests`, `ci/ios-linter`, `ci/ios-deploy` |
| Android | `ci/android-build`, `ci/android-unit-tests`, `ci/android-linter`, `ci/android-deploy` |
| Comment-triggered | `ci/ios-ui-tests` |

## Modifying the Trigger

Edit `ci/trigger.Jenkinsfile`, push to this repo, and re-run the multibranch scan or wait for the next build. The trigger runs from the app repo's branch, not from `main` of the CI repo.

Key sections in `trigger.Jenkinsfile`:
- `IOS_CONTEXTS` / `ANDROID_CONTEXTS` — lists of commit status context names
- `checkCollaborator()` — GitHub API call to verify PR author
- `detectPlatforms()` — git diff against target branch to determine iOS/Android changes
- `publishSkippedStatuses()` — marks skipped platforms as "success" with "Skipped" description

## Credentials

- `github-app` — used via `withCredentials` for GitHub API calls (collaborator checks, skipped statuses)
- `github-pat` — used by Jenkins SCM for checkout (avoids github-checks plugin auto-publishing)

## Companion Repos

- [jenkins-setup](https://github.com/gosuwachu/jenkins-setup) — Jenkins Docker environment, Job DSL, seed job
- [mobile-app-ci](https://github.com/gosuwachu/mobile-app-ci) — child Jenkinsfiles and Python CI CLI
