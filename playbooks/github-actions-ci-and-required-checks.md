# Playbook: GitHub Actions CI with Required Checks That Even Admins Cannot Bypass

## WHY

A test suite nobody is forced to pass is advice, not a control. Teams get a CI file, see green most days, and then someone merges a red pull request (or an admin "just this once" overrides it). The aim is lint and tests that run on every change, a check that GitHub requires before merge, and proof that a red change cannot get in, including from the repository owner.

## WHAT This Playbook Delivers

One workflow file that lints and tests on pull requests and on pushes to the main branch, pinned and least-privileged, plus branch protection that requires that check, with administrators included. Proven by deliberate failures.

## Prerequisites

A repository with a test suite and a linter. Public repositories get standard GitHub-hosted runners free; private ones draw on a monthly allowance and larger runners are always charged, so check billing first and use the standard `ubuntu-latest` runner only. Record the current protection rule (`gh api repos/<owner>/<repo>/branches/main/protection > a file kept outside /tmp`) before changing it, so it can be restored.

## Steps

1. Compare with Jenkins to place the concepts: workflow file in `.github/workflows/` is the Jenkinsfile, a hosted runner is an agent you do not run, repository secrets are credentials, and there is no controller to patch or expose. The trade is control for upkeep.

2. Write the workflow with the narrowest rights. Set `permissions: contents: read` at the top, `timeout-minutes` on the job, `concurrency` so a newer push cancels an older run on the same ref, and `persist-credentials: false` on checkout so the token is not left in the checked-out repo.

3. Pin every third-party action to a full commit SHA with the version as a comment (`uses: actions/checkout@<40-char sha> # v7.0.1`), not `@v4`. A tag can be moved to different code; a SHA cannot. This is the same idea as pinning a Docker base image by digest. Pin tool versions too (`ruff==...`, `pytest==...` in a requirements file) and let the language setup action cache pip.

4. Make the steps order cheap-to-expensive: checkout, set up language, install, lint, test. Name the job with a stable name such as `lint-and-test`; branch protection refers to that exact name.

5. Add `workflow_dispatch` so the run can be started by hand while developing.

6. Run it on a pull request first and read the failure honestly. The first run caught a real import-order lint error (ruff I001) that had been invisible locally; the fix was one line. A first run that fails for a true reason is the pipeline working.

7. Prove the test gate: add a deliberately failing test on a branch, push, and confirm lint passes, the test step fails, the run is red, and the pull request cannot be merged ("base branch policy prohibits the merge"). Then revert it as a new commit and confirm the run goes green.

8. Make the check required: branch protection on main with the exact job name as a required status check, pull request required before merge, and Include administrators (`enforce_admins: true`) switched on. Rebuild the rule from the full existing one rather than from scratch so nothing is silently dropped. Without `enforce_admins`, the owner's `gh pr merge --admin` merges a red pull request.

9. Prove the admin cannot bypass it: with the failing change still open, run `gh pr merge --admin` and expect `Required status check "lint-and-test" is failing`. Then revert, wait for green, and merge with the normal command.

10. Run the same check after merge with `push: branches: [main]`, so main itself is verified, not only the pull request. Confirm a run with event `push` on `main` finishes green.

11. Do not filter the pull request trigger by paths if the check is required (see the trap below). Remove `paths:` from `pull_request:` so every pull request reports the check; a filter on the `push` to main trigger can stay because that run is not the merge gate. If you must limit what runs on pull requests, keep the required job always running and put the path decision inside the job, or use a small always-running gate job that is the required check. Prove it with a pull request that changes only the README: the check must run, pass and allow a normal merge.

12. Keep pins fresh: SHA-pinned actions do not update themselves, so add Dependabot for the `github-actions` ecosystem or review them on a schedule. Add a CODEOWNERS or review requirement for `.github/workflows/` changes, because a workflow edit can change what the check does.

## The Path Filter Trap

If `pull_request:` has a `paths:` filter and the job is a required status check, any pull request that touches none of those paths never starts the workflow. The required check then stays "Expected, waiting for status" forever and the pull request cannot be merged by anyone, administrators included once `enforce_admins` is on. Documentation-only and other-folder changes get stuck. The Session 42 workflow was limited to one folder and one workflow file while the check was required on the whole repository, so the next pull request outside those paths would have been stuck. This was caught in review before it bit, not reproduced; the fix (remove `paths:` from `pull_request:`) was then proven with a README-only pull request.

## Guardrail Check

Never leave a required check that can silently never run, and prove every required check with a pull request that touches only an unrelated file. Never turn on `enforce_admins` without first saving the current protection rule and knowing how to restore it; changing protection on a shared repository needs the operator's approval. Never use `@main`, `@v4` or other movable references for third-party actions. Never give the workflow write permissions it does not need, and never print secrets in a log. Never use larger runners without a cost ceiling. Never use `--admin` to merge past a failing check. Untrusted fork pull requests must not get secrets (`pull_request_target` with a checkout of fork code is a known way to leak them).

## Reference Implementation

See github.com/SwitchhToDevOpsIn90/devops-journey, Session 42: `.github/workflows/ci.yml` (job `lint-and-test`, ubuntu-latest, Python 3.13, `ruff==0.17.5`, `pytest==8.3.3`, actions pinned to SHAs, contents read-only, merged in pull request #23 as f4fe090 after a deliberate failing test 885302e and its revert cddc460). Seen in the pasted output: the `--admin` merge refused with `Required status check "lint-and-test" is failing`; the normal merge succeeding once green; the feature branch deleted; and a `CI` run on `main`, event `push`, finishing successfully in 13 seconds. Reported by the lab but not shown as raw output to me: the first-run ruff I001 failure, the failing-test run (lint passed, test failed) and the "base branch policy prohibits the merge" message. After the fix, pull request 25 changed only `README.md`; `CI/lint-and-test (pull_request)` ran and passed in 7 seconds, `gh pr checks` exited 0, and the pull request merged normally as 8661ff0 and its branch was deleted. The rollback copy of the old protection rule was saved outside /tmp (the lab's listing of that folder was not shown to me). The stuck state before the fix was not reproduced. Not exercised: matrix builds, a pinned dependency lock file, secrets and environments, OIDC to AWS, reusable workflows, fork safety, Dependabot, and a review requirement for workflow changes.
