# Playbook: A Fast, Supply-Chain-Safe CI Pipeline with One Gate

## WHY

A single "lint and test" job is a start, but it does not test what ships, does not look at the image, trusts floating dependencies and base images, and ties branch protection to job names that break whenever someone renames a job. The aim is a pipeline under five minutes where nothing merges unless every check has passed, what is tested is what is shipped, and updates arrive as reviewable pull requests that the pipeline itself judges.

## WHAT This Playbook Delivers

A workflow of parallel jobs (lint, a test matrix) feeding a build-once image job, then a smoke test and a vulnerability scan on that same image, summed up by one always-reporting gate job that is the only required check. Plus locked dependencies, a pinned slim base image, and Dependabot for actions, Python packages and the base image.

## Prerequisites

The CI and required-check setup from github-actions-ci-and-required-checks.md. Public repositories use standard runners at no cost; check billing before using larger runners or private repositories. Dependabot and Trivy are free.

## Steps

1. Split the work into jobs that run in parallel where they do not depend on each other: `lint` and `test` together, then `build` (needs both), then `smoke` and `scan` together (both need only `build`). Set a `timeout-minutes` on every job and `fail-fast: false` on the matrix so one failing version does not hide the other.

2. Test on every Python version you support with a matrix, and make sure at least one matrix entry is the version the image actually runs. Testing on one version and shipping another is how "it passed CI" stops meaning anything.

3. Add one gate job, `ci-ok`, with `if: always()` and `needs:` listing every other job. It fails if any needed job result is `failure`, `cancelled` or `skipped`. Make `ci-ok` the only required status check in branch protection. Reason: GitHub counts a skipped required job as passing, so a failure upstream can silently let a pull request through; the gate treats skipped as a failure. It also means adding, renaming or matrix-expanding a job never breaks protection. The trap: a new job that is not added to the gate's `needs` list is not gated.

4. Lock dependencies. Keep the direct dependencies in `requirements.in`, compile a fully pinned `requirements.txt` with hashes (`uv pip compile requirements.in --generate-hashes`), and install with `pip install --require-hashes` in both the test job and the image build. Floating indirect dependencies are a supply-chain gap; the hashes close it. Development tools (pytest, ruff) pinned to exact versions in a separate file are a smaller gap if they are not hash-locked; say so.

5. Make it fast: pip caching through the Python setup action and Docker layer caching (`cache-from`/`cache-to: type=gha`). Time the run and compare with the target; record the number.

6. Build the image once and reuse it. The build job writes the image to a tar file and uploads it as an artifact with a one-day retention; the smoke and scan jobs download that same file. Never rebuild for the scan, or the scan checks something other than what was tested. Upload test results (JUnit XML) as artifacts with a short retention, always, so a failure can be read afterwards.

7. Smoke-test the image you just built: load it, run it, request it, check the expected text, and check it runs as the non-root user. Poll with a retry loop rather than a fixed `sleep`, which is flaky on slow runners.

8. Scan the image with Trivy and fail on HIGH and CRITICAL. Fix findings by removing the cause, not by an ignore list. In the session five HIGH findings disappeared by uninstalling `pip` from the runtime image, because the running app never needs it. Know what the gate does not catch: `ignore-unfixed: true` means findings with no available fix do not fail the run, and a scan only runs when someone pushes, so add a scheduled run to catch vulnerabilities published later.

9. Slim and pin the base image. Use a multi-stage build, a non-root user, and a base reference that carries both the tag and the digest: `python:3.13-alpine@sha256:<digest>`. The digest says which exact bytes; the tag says which stream, and update tools read the tag to decide what an update means. With a bare digest, Dependabot proposed `python:latest` (Debian), which broke `adduser -D` (an Alpine command); the pipeline caught it, the pull request was closed with an explanation, and a tag-plus-digest pin replaced it.

10. Add Dependabot for `github-actions` (grouped), `pip` and `docker`, weekly. Treat every update as a pull request to read: look at the diff, let the gate judge it, then merge or close with a reason. Do not enable auto-merge until the gate has proven itself on several updates. When an update is wrong, fix the cause (here, the pin format), not just close the pull request.

11. Review requirement for workflow changes (CODEOWNERS plus required reviews on `.github/workflows/`): worth it for a team, but with one person on a repository GitHub will not let you approve your own pull request, so it would block every workflow change. Record it as a team setting and do not turn it on for a solo repository.

12. Finish by checking main: the push run for the last merge is green, and no unexpected pull requests are open.

## Guardrail Check

Never require individual job names in branch protection; require the single gate. Never let skipped count as success. Never silence a vulnerability with an ignore entry without a written reason and an expiry. Never use `latest` or a bare digest where automation reads the reference. Never rebuild the image between the test, the smoke test and the scan. Never put secrets in artifacts or logs. Never use `pull_request_target` with fork code. Keep action references pinned to commit SHAs, with `contents: read` unless a job needs more. Never auto-merge dependency updates for the base image or workflow actions before the gate has proven itself; changes to branch protection need the operator's approval.

## Reference Implementation

See github.com/SwitchhToDevOpsIn90/devops-journey, Session 43: `.github/workflows/ci.yml` (jobs lint, test matrix on 3.12 and 3.13, build, smoke, scan, ci-ok), `.github/dependabot.yml`, `session22-dockerfile/Dockerfile` (multi-stage, `python:3.13-alpine@sha256:9ef1a5…`, non-root `appuser`, pip removed from runtime), `requirements.in` / hash-locked `requirements.txt`. Merged in pull request 26 (bab1df6); Dependabot updates merged as 28 (flask 3.0.0 to 3.1.3, 2f71294) and 29 (pytest 8.3.3 to 9.2.0, 95a9756); pull request 27 (a bump to `python:latest`) closed; pull request 30 (ea917f1) pinned tag plus digest. I read the workflow, Dockerfile, Dependabot file and requirements files directly. From the pasted output: pull request 30 merged with all 7 checks passing and the merge state clean, local check showed `appuser` and Python 3.13.18, and the main run list showed the two Dependabot merges green. Reported by the lab but not shown as raw output to me: the pipeline time of about one minute (build 19 seconds, scan 12, smoke 9), the five HIGH findings removed by deleting pip, the before and after image sizes, and the refusal of a deliberately failing pull request even for an administrator with `ci-ok` as the only required check. Not confirmed: the push run for pull request 30 was still running when last listed. Gaps: development tools are not hash-locked, the smoke test uses a fixed sleep, there is no scheduled scan, `ignore-unfixed` is on, and cancel-in-progress also cancels earlier runs on main. Not exercised: secrets and environments, OIDC to AWS (Session 44), CODEOWNERS with required reviews, reusable workflows.
