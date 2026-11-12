# Playbook: Building Docker Images in Jenkins and Pushing to ECR Safely

## WHY

Building images in CI normally tempts people to mount the host's Docker socket into Jenkins, which hands whoever controls Jenkins control of the host. Pushing to a registry also needs a credential, and a leaked one with broad rights is costly. The aim is an image that is built and pushed on every commit with no host socket, a credential that can do one thing, and proof at the end that every piece is gone.

## WHAT This Playbook Delivers

A pipeline that tests, builds an image on an isolated Docker engine, smoke-tests the running container, pushes it to ECR tagged with the commit, and verifies it landed by reading the registry. Plus a teardown that removes the credential, the IAM user and the repository, with proof.

## Prerequisites

Jenkins with agents set up per jenkins-ci-setup-and-security.md and a pipeline in Git per jenkins-pipelines-as-code.md. A cost check first: ECR private storage is free for the first 500 MB a month for new customers during the first year, then about $0.10 per GB-month; pushing is free, downloads to the internet are not. Check Billing credits and the Free Tier page before creating anything and record a cost ceiling.

## Steps

1. Never mount the host's Docker socket. Give Jenkins a separate build agent (label `docker-builder`) that talks over TLS to its own isolated Docker engine (Docker-in-Docker) on a private Docker network. The host's Docker is never reachable from the build. The isolated engine runs privileged inside the container runtime's VM, so creating it needs explicit approval (the policy hook blocks `--privileged` until the operator adds the exact command to `.crew/approvals.txt`), and its port must never be published outside the private network.

2. Pin the builder. Reference the base image by digest, not a floating tag, and copy the Docker CLI and buildx from a version-tagged CLI image (the session used `docker:29-cli`; a digest is stronger). Install the AWS CLI at a pinned version and verify its checksum; downloading "latest" over the network with no check is a supply-chain gap (the session's agent Dockerfile did exactly that).

3. Lay out the pipeline with `agent none` at the top and an agent per stage: Test on the test agent, then Build image, Smoke test and Push on the builder. Tests run first, so a failing test means no image is built or pushed.

4. Tag with the short commit hash (`git rev-parse --short=7 HEAD`), never `latest`. A new commit gives a new tag, so every published image is traceable to a commit. A revert is a new commit and gets a new tag. Enable ECR tag immutability to enforce this rather than rely on habit; the session did, and a re-push of an existing tag was refused.

5. Smoke test the image you just built before pushing it: run it in the isolated engine, request it, and check for the expected text. Always remove the container in a `post { always }` block.

6. Use a dedicated IAM user whose policy allows pushing to one repository only, store its key in Jenkins as a credential, and bind it with `withCredentials`. Never put keys in the Jenkinsfile, the Dockerfile or the log. Prove the boundary: the key must be refused for any other repository.

7. Keep the registry login off the agent's normal Docker config. Set `export DOCKER_CONFIG=$(mktemp -d)` and `trap 'rm -rf "$DOCKER_CONFIG"' EXIT` before `docker login`, so the token lands in a throwaway folder deleted when the step ends, pass or fail.

8. Verify the push by reading the registry, not by trusting the push's exit code: `aws ecr describe-images --repository-name <repo> --image-ids imageTag=<tag>` and print the tag, digest and size.

9. Know the size and architecture traps. The build log shows the uncompressed size (about 240 MB) while ECR stores compressed layers (about 52 MB). An image built on an arm64 laptop is arm64 and fails on standard x86 nodes with `exec format error`; build for the target with `docker buildx build --platform linux/amd64`.

10. Gate the push. Pushing from every branch fills the registry and lets an untrusted branch publish. Push only from `main` (`when { branch 'main' }`) and, for anything beyond a demo, put an `input` approval before it, per jenkins-pipelines-as-code.md. Not exercised in the session.

11. Tear down with proof, because the IAM key can push from anywhere until the user is deleted. Delete the Jenkins credential and prove it (`list-credentials | grep -c <id>` prints 0), delete the IAM user and search for it ("No users"), delete the ECR repository and list repositories ("No repositories"), then run the build and expect it to fail with `Could not find credentials entry with ID '<id>'`. Remove the CLI login file, stop the containers, and prune leftover images from the isolated engine (each unpacked image is about 240 MB and disks fill).

12. Mask the account ID fully in notes and logs with a placeholder such as `<ACCOUNT_ID>`. A partial mask that keeps the first digits still leaks part of it. Run `tools/scan-secrets.sh` before committing.

## Guardrail Check

Never mount the host's Docker socket into Jenkins or an agent. Never run a privileged container without approval, and never publish the isolated engine's port outside its private network. Never give the push credential rights beyond one repository, and never leave the IAM user, the key or the repository behind after a demo. Never push `latest`. Never push from an unreviewed branch to a shared registry. Never commit keys, the registry token or an unmasked account ID. Creating the IAM user and its key is a security change that needs approval; spend must stay inside the stated cost ceiling.

## Reference Implementation

See github.com/SwitchhToDevOpsIn90/devops-journey, Session 41 (feature commits dbd8809 builder image and Jenkinsfile with test, build and smoke test, and e250a51 push to ECR with a scoped credential verified by describe-images; merged in pull request #22 as 0c598b4). Jenkins in Docker on a Mac with an isolated Docker-in-Docker engine and a separate builder agent pinned by digest; ECR in eu-north-1, zero real cost within credits. Seen in the output: build 5 passed 2 tests, built `dockerapp:32124c6` (arm64, 239,646,740 bytes), pushed it, and the registry read-back showed `IN ECR: 32124c6`, a sha256 digest and 51,667,200 bytes, then `Finished: SUCCESS`. After the credential was deleted from Jenkins (`grep -c` printed 0), build 6 failed at the push stage with `Could not find credentials entry with ID 'aws-ecr-push'` (exit 2); the CLI login file was removed and all four containers stopped; the IAM user and the ECR repository were deleted and reported empty by the operator. Also seen in the logs: the key was refused for another repository (`AccessDeniedException` on `ecr:DescribeImages` for `repository/some-other-repo` and on `ecr:DescribeRepositories`); build 4 had `1 failed, 1 passed` and the Build image, Smoke test and Push to ECR stages were skipped, so a failing test means no push; build 3 was refused because `The image tag 'e250a51' already exists in the 'dockerapp' repository and cannot be overwritten because the tag is immutable`. Not verified: deletion of the IAM user and the ECR repository rests on the operator's word (no screenshot); only the Jenkins side is proven by build 6. Not exercised: pushing only from main, an approval gate before the push, and an amd64 build. Gaps this playbook closes: the AWS CLI was installed unpinned and unverified in the builder Dockerfile, and the push stage ran on every branch.
