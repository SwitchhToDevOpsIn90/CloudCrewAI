$ gh pr diff 38 --name-only
README.md
$ gh pr checks 38
All checks were successful
0 cancelled, 0 failing, 7 successful, 1 skipped, and 0 pending checks
NAME                        ELAPSED
CI/lint (pull_request)      9s
CI/test (3.12) (pull_request) 14s
CI/test (3.13) (pull_request) 15s
CI/build (pull_request)     27s
CI/smoke (pull_request)     9s
CI/scan (pull_request)      12s
CI/ci-ok (pull_request)     4s
CI/deploy (pull_request)    skipped
$ gh pr merge 38 --merge
Merged pull request #38
