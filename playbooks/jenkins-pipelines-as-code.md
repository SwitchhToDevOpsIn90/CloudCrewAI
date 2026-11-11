# Playbook: Jenkins Pipelines as Code (Jenkinsfile, Test Gate, Recovery)

## WHY

A pipeline clicked together in a web UI cannot be reviewed, reverted or reproduced. A pipeline defined in Git can. The aim is a build that runs the same checklist on every change, refuses to package code whose tests fail, and can be rebuilt from the repository alone.

## WHAT This Playbook Delivers

A Jenkinsfile in the application repository, run on a labelled agent whose toolchain is defined in a Dockerfile in Git; stages that build, test and package in that order; test results published to Jenkins; a quality gate proven by a deliberate failure; and a known recovery path after a restart.

## Prerequisites

A working Jenkins with agents and the controller at 0 executors, per jenkins-ci-setup-and-security.md. The application repository with real tests. A secret scan before every commit (`tools/scan-secrets.sh`).

## Steps

1. Put the pipeline in Git. Add a `Jenkinsfile` to the repository and configure the job as "Pipeline script from SCM" pointing at it, with a branch specifier. Work on a feature branch while building it, then merge and switch the job to `*/main`. The history is the audit trail of how the pipeline changed.

2. Run on a labelled agent (`agent { label '...' }`). If a build needs tools the agent lacks (Python, zip), define them in a Dockerfile in Git (for example `jenkins-agent-python:<tag>`) instead of installing by hand on a running container. Pin the base image: a floating `latest` tag makes the pipeline's toolchain change without a commit.

3. Order the stages Info, Build, Test, Package. Info prints the commit and tool versions so every log says what was built. Build installs dependencies into a virtual environment inside the workspace. Test runs the real tests and writes a JUnit file. Package runs only if Test passed.

4. Set safety options: `timestamps()`, a `timeout` (10 minutes), `buildDiscarder` with a log rotator (keep the last 10 builds) and `disableConcurrentBuilds()`. Without a timeout a hung build occupies the only agent indefinitely; without a discarder the disk grows.

5. Publish test results with `junit` in a `post { always { ... } }` block, so results appear even when the build fails. Archive the artifact (`archiveArtifacts ... fingerprint: true`) only in the Package stage, after the tests passed.

6. Use post blocks for outcome and tidiness: `success` and `failure` messages that say what to do next, and `cleanup { deleteDir() }` so a workspace never carries one build's files into the next.

7. Prove the quality gate before trusting it. On a branch, commit a deliberately failing test (a boundary check, for example), push, and build. The build must go red, the Test stage must fail, Package must be skipped and no artifact must exist. Then undo it with `git revert` (not by rewriting history), merge the branch, and confirm the next build is green with an artifact. The honest history reads break, revert, merge.

8. Verify with the logs, not the colour of the icon. Read the build log for the test count, the "built and archived" line and `Finished: SUCCESS`, for example `docker exec jenkins sh -c 'grep -E "passed|failed|PASS:|Finished" /var/jenkins_home/jobs/<job>/builds/<n>/log'`. Do this again for the first build from `main`.

9. Know the restart recovery. After stopping Docker or the host, the containers still exist. Start them with `docker start <controller> <agent>`; running `docker run` again fails with a name conflict. If the agent connects but fails its handshake, recreate the agent container with its secret (read with `read -s`, never in shell history or files).

10. For a private repository, prove it refuses anonymous access first (`git ls-remote` with no credential must fail). Then create a fine-grained token limited to that one repository with Contents read-only and a short expiry (7 days), store it in Jenkins as a credential with a clear id (for example `github-ro-session40`) and a description of its scope, and reference only the id in the job and the Jenkinsfile. Never paste the token into chat, files or logs. Show the repository is readable through the credential without the value appearing (the log shows the credential id, not the token).

11. Add a human approval gate before anything touches a real environment, using the `input` step with a named approver and a timeout, in its own stage before Deploy. Prove all four paths: the approver says yes and the deploy runs; nobody answers, the timeout aborts and nothing deploys; the approver says no, the build is rejected and Deploy is skipped; a user who is not the approver can neither approve nor reject (permission message). Put the `input` outside an agent block so a waiting build holds no executor. This is the pipeline form of the approval guardrails.

12. Lint the Jenkinsfile before committing, using the Jenkins declarative linter (`jenkins-cli declarative-linter` or the HTTP endpoint). Check a good file passes and a deliberately broken one fails with line numbers. It is cheaper than a failed build.

13. Offboard a CI credential in three steps and prove each: revoke it at the source (delete the token on GitHub), delete it from Jenkins, then run a build that is expected to fail and read why. Do not stop at "deactivated". Check the Jenkins side by query (`list-credentials | grep -c <id>` must print 0), then run the build that must fail. A checkout authentication error does not by itself show which side revoked the credential, so also look at the source's token list and confirm it is empty or no longer shows the token. Confirm the source-side deletion separately; a credential deleted only from Jenkins stays valid on GitHub until it is deleted there or expires.

## Guardrail Check

Never make a pipeline green by skipping or deleting tests. Never merge a deliberately broken commit without reverting it in the same change set. Never put secrets, tokens or the agent secret in a Jenkinsfile, Dockerfile or log. Never use a floating image tag for the agent. Never put a token in a Jenkinsfile, job config or chat; reference its id only. Never give a CI token more than read access to one repository, and never one without an expiry. Never deploy to a real environment from a pipeline without an approval gate and a named approver. Never call the pipeline done until a build from `main` is green and its log has been read. A pipeline that deploys to a real environment (later sessions) needs approval for the deploy target per guardrails/never-do-without-approval.md.

## Reference Implementation

See github.com/SwitchhToDevOpsIn90/devops-journey, Session 40 (merge pull request #21 as 8638db9; the deliberately failing test was commit 8e2ac97 and its revert 86e4a96). Jenkins in Docker on a Mac, zero cost. Jenkinsfile with Info, Build, Test and Package, options, and four post blocks; a custom agent image built from a Dockerfile in Git; real tests for DockerApp published as JUnit. Proven: a failing test turned the build red, skipped Package and left no artifact; after the revert builds 4 and 5 were green (2 passed, artifact archived, Finished: SUCCESS), build 5 from main; and recovery after a restart using `docker start` and a recreated agent. Add-on lab (run in a separate private demo repository, same session): anonymous `git ls-remote` of the private repo failed; a token limited to that one repo (Contents read-only, 7 days) stored as a Jenkins credential read it without the value appearing; the linter passed a good Jenkinsfile and failed a broken one at three line numbers; the `input` gate was proven on all four paths (approved, timed out and aborted, wrong user denied for both approve and reject, rejected so Deploy was skipped) and waiting builds held no executor; and the credential was deleted from Jenkins (`grep -c` printed 0) after which a build failed at checkout with an authentication error (exit code 2). Observed gaps this playbook closes: the agent Dockerfile in that session still used the floating `jenkins/inbound-agent:latest-jdk21` tag. Credential offboarding is proven at both layers: Jenkins no longer held it (`list-credentials | grep -c` printed 0 and the next build failed at checkout with an authentication error, exit code 2), and the GitHub fine-grained tokens page was later shown empty ("No fine-grained tokens created"). One detail stays unexplained: the failing build's log said "Invalid username or token", which GitHub also says for a blank login, and a search of that log for "credential" found only a stack-trace line, so the log alone cannot tell which side caused the failure. That is why the source-side check matters. Not yet exercised: multibranch pipelines, `when` branch conditions, parallel stages, and a pipeline that pushes a Docker image (Session 41, using an isolated Docker engine, never the host's socket).
