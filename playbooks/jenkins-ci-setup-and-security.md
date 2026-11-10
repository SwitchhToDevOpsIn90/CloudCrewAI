# Playbook: Setting Up Jenkins Safely (Controller, Agents, Credentials, Access)

## WHY

A CI server holds the keys to everything it builds and deploys: credentials, source code and the ability to run arbitrary commands. A Jenkins installed with defaults and exposed carelessly is a common way systems get compromised. The goal is a working Jenkins whose default posture is closed, with every opening a deliberate, recorded choice.

## WHAT This Playbook Delivers

A Jenkins controller with data that survives the container, builds that run on agents (not on the controller), credentials protected by access control, a trigger that works without exposing the server, a tested backup, and pinned versions. All verified with real output.

## Prerequisites

Docker on the host (a Mac, a laptop or a VM). A cost ceiling of $0 for a local setup; any move to a cloud VM needs a stated ceiling and approval per guardrails/never-do-without-approval.md. No secrets in the repository.

## Steps

1. Run the controller in Docker with its data in a named volume (`-v jenkins_home:/var/jenkins_home`). Jobs, users and history survive deleting and recreating the container; prove it by doing exactly that and checking that no setup wizard reappears.

2. Publish the UI on the loopback address only (`-p 127.0.0.1:8080:8080`), so other devices on the network cannot reach it. This is the local equivalent of keeping port 8080 closed on a cloud server. Never publish it on all interfaces without approval.

3. Pin versions. Use an exact tag (for example `jenkins/jenkins:2.580.2-lts-jdk21`) and record the image digest, not a floating tag like `lts-jdk21`. Pin the agent image too; a floating `latest-jdk21` agent tag is the same risk. Check plugin updates deliberately instead of letting them drift (4 of 92 plugins had updates within a day).

4. Unlock with the one-time initial admin password read from inside the container, never pasted into files or chat. Create a named admin user, not a shared default.

5. Run builds on agents, not the controller. Add an inbound agent as a second container on a private Docker network, connected over WebSocket. Read its secret with `read -s` so it stays out of shell history. Then set the controller's executors to 0. The controller holds configuration and credentials, so untrusted build steps must not run on it.

6. Prove the label routing. A job that requests a label no agent has waits in the queue indefinitely instead of failing, and fixing the job does not change an already-queued build. Make "waiting forever" a known symptom, not a surprise.

7. Handle credentials as secrets that access control protects. Store them as Jenkins credentials and use `withCredentials`. Log masking only hides exact matches; printing a secret with spaces between the characters bypassed masking in testing. Anyone who can edit a pipeline can extract its credentials, so restrict who can configure jobs.

8. Set matrix-based security: an admin with Administer, authenticated users with only Overall Read and Job Read, anonymous with nothing. Test it as a read-only user: no Build Now or Configure in the menu, and typing the configure and Script Console URLs directly is denied. Prefer API tokens over passwords for automation; revoke a token afterwards and confirm it returns 401. The Script Console runs arbitrary code on the controller; treat access to it as admin-only and avoid using it as a routine workaround.

9. Choose the trigger to fit the exposure. A webhook cannot reach a Jenkins bound to 127.0.0.1, and a tunnel would expose it, so use polling (`pollSCM`) for a local setup. Prove it with a push that starts a build marked "Started by an SCM change". Remove any polling accidentally added to other jobs.

10. Back up `jenkins_home` and treat the backup as a secret: it contains `credentials.xml` and `secrets/master.key`. Keep it outside the repository with owner-only permissions. Restore is untested until it has been restored once.

11. For Docker builds inside Jenkins, never mount the host's Docker socket into the controller or an agent without approval: whoever controls Jenkins then controls Docker on the host. Prefer a separate build agent with its own isolated Docker engine over TLS, or a daemonless builder. A socket mount on a throwaway agent is acceptable only with the risk stated and approved.

12. Scan before committing: `tools/scan-secrets.sh` on the session folder. Keep the run script free of secrets (the secret is read at run time), and keep backups and `jenkins_home` out of Git.

## Guardrail Check

Never publish Jenkins on all interfaces, or open a cloud security group to 0.0.0.0/0 for it, without approval. Never mount the Docker socket without approval. Never let the controller run builds. Never commit `jenkins_home`, backups, agent secrets or the initial admin password. Never rely on log masking as protection. Never use a floating image tag for a CI server you depend on. Jenkins on a cloud VM needs a stated cost ceiling and approval first.

## Reference Implementation

See github.com/SwitchhToDevOpsIn90/devops-journey, Session 39 (feature commit pull request #18, merged as b45f0c3) and its add-on (pull request #19 merged as b2c5ef6, and pull request #20 merged as 8923283 which pinned the version after the first add-on commit missed it). Jenkins 2.580.2 on Docker on a Mac, zero AWS cost: volume survival proven by deleting the container; a pipeline ran on a Linux/aarch64 agent with the controller at 0 executors; masking bypass shown; matrix security tested as a viewer; API token 201 / viewer 403 / revoked 401; a push built through `pollSCM`; a 192 MB backup containing the master key kept outside the repo; and the floating `lts-jdk21` tag resolved to 2.580.2. Not yet exercised: a private repository with a scoped token and a Jenkinsfile read from Git (Session 40), and Docker builds through an isolated engine (Session 41). The agent image in the Session 39 script was still the floating `latest-jdk21` tag, which this playbook says to pin. The "Create User" form failed with a crumb error in two browsers, and the user was created from the Script Console as a workaround.
