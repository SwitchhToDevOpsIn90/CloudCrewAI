# Playbook: Docker Containerization

## WHY

An application that runs perfectly on one machine but fails on another due to different installed versions, missing dependencies, or configuration drift is a genuinely common and expensive problem. Containerizing an application packages it with everything it needs to run identically anywhere.

## WHAT This Playbook Delivers

A containerized application with a properly structured Dockerfile, a working image that builds reproducibly, and a container that runs consistently across the client's development, staging, and production environments.

## Prerequisites

Docker installed. The application's actual dependencies and runtime requirements clearly identified before writing the Dockerfile, not guessed at.

## Steps

1. Choose a minimal, official base image matching the application's actual runtime requirement, never a general-purpose full operating system image unless genuinely necessary.

2. Structure the Dockerfile to maximize layer caching: copy dependency manifests and install dependencies before copying the rest of the application code, so code changes do not force a full dependency reinstall on every rebuild.

3. Run the container process as a non-root user inside the image, never as root, to limit the damage possible if the container is ever compromised. Be precise about what this fixes and what it does not: this addresses container-level root only — the process inside the container. It does not address daemon-level root, a separate and more fundamental risk.

## Container-Level Root vs Daemon-Level Root — Two Separate Problems

A non-root USER instruction in a Dockerfile fixes container-level root: the process running inside that specific container no longer has root privileges if it escapes. This does not fix daemon-level root: the Docker daemon (dockerd) itself traditionally runs as root on the host, and the Docker socket is owned by root. Anyone with access to that socket — anyone in the host's docker group, no sudo required — has root-equivalent access to the entire host, regardless of what any individual container's USER is set to, since mounting the host filesystem into a container and chrooting into it is trivial with socket access.

Before assuming this risk applies, verify concretely rather than assuming: check whether a docker group actually exists on the target host with getent group docker, and check whether any running or planned container mounts the Docker socket. If the group is empty and no socket mounts are in use, standing daemon-level risk is genuinely low on that specific host, even though the underlying daemon architecture risk still exists in principle.

The real, stronger mitigation for daemon-level root is Docker Rootless mode, stable since Docker 20.10, which runs the daemon itself as an unprivileged user. This is a genuinely disruptive host-level change (different networking behavior, different socket paths) and should be a deliberate decision made on its own, not applied as a side effect of a routine Dockerfile hardening task — especially on a host already running other live services, where an unplanned daemon reconfiguration risks breaking unrelated things.

4. Use a multi-stage build for compiled languages, so the final image contains only the compiled artifact and runtime dependencies, not the entire build toolchain.

5. Add a HEALTHCHECK instruction so orchestration tools can detect a genuinely unhealthy container, not just a crashed one.

6. Build the image locally and test it runs correctly before pushing anywhere.

7. Tag the image with both a specific version and never rely solely on the latest tag for anything running in production, since latest can silently change underneath a deployment.

8. Push to a container registry scoped with least-privilege credentials, matching the same IAM discipline used for AWS access elsewhere in this framework.

9. Scan the image for known vulnerabilities before it reaches a registry, using an open-source scanner such as Trivy to check OS packages and language dependencies against published CVE databases. Treat scanner output as a signal to investigate, not an automatic truth in either direction — do not assume a flagged CVE is definitely real, and do not assume a scanner is broken and safe to ignore if a result seems surprising. When a scan result seems inconsistent with what should actually be installed, verify directly against the real filesystem: check the actual installed version with the package manager's own inspection command, read the package's real metadata file directly, and only conclude false positive after this direct verification, not before. A scanner disagreeing with a full rebuild and a cleared cache is itself a signal worth investigating thoroughly rather than dismissing.

10. Add a .dockerignore file before the first build, not after — this is genuinely a security step, not just a build-speed optimization. Without one, docker build copies everything in the current folder into the image's build context, including a .git folder, __pycache__ directories, or critically, a local .env file containing real secrets. A .dockerignore file listing at minimum .git, __pycache__, *.pyc, and .env prevents any of these from ever being baked permanently into an image layer — directly applying the same discipline as the secrets incident response playbook, but at the container-build stage specifically, before a leak can happen rather than after.

## A Real, Recurring Debugging Pattern: PATH Issues Inside Containers

A command that installs successfully via apt but then fails with "executable file not found in $PATH" when run as a Dockerfile CMD or ENTRYPOINT is a genuinely common, easy-to-hit issue — not a sign anything is fundamentally wrong. Some packages install their binaries into locations not included in the container's default PATH, most commonly /usr/games for certain utility packages.

When this happens: run the image interactively (docker run --rm -it IMAGE bash), confirm the binary is missing from PATH with which BINARY_NAME, then locate its actual installed location with find / -name BINARY_NAME 2>/dev/null. Fix by referencing the full absolute path directly in the Dockerfile's CMD or ENTRYPOINT instruction, rather than relying on it being discoverable via PATH.

This same root cause (a package installing outside the expected PATH) can appear identically on a bare Linux server with no Docker involved at all — recognizing the pattern once means recognizing it instantly in either context.

## A Second Real Gotcha: Image References by Name vs ID

Some Docker commands, particularly docker history, can behave inconsistently when referencing an image by its tagged name versus its image ID, even when docker images clearly confirms the named image exists. If a name-based reference unexpectedly fails, retry the same command using the image ID from docker images output as a reliable fallback before assuming something is broken.

## Guardrail Check

Never push an image tagged as a production version without the human operator confirming it has been tested. Never run a container with unnecessary elevated privileges or with the Docker socket mounted inside it unless there is a specific, reviewed reason. Never reconfigure a host's Docker daemon (including enabling Rootless mode) as a side effect of routine image hardening work — treat it as its own deliberate decision, especially on any host already running other live services. Never dismiss a scanner-reported vulnerability without direct filesystem verification, and never dismiss a scanner itself as broken without the same direct verification first.

## Reference Implementation

See github.com/iam-veeramalla/Docker-Zero-to-Hero for foundational patterns and example Dockerfiles across multiple application types. See github.com/SwitchhToDevOpsIn90/devops-journey, Session 21, for a real, live example of both the PATH debugging pattern and the name-vs-ID image reference quirk, including the exact diagnostic commands used to resolve each. See Session 22 for a real multi-stage Flask build and .dockerignore applied correctly before the first build. See Session 26 for a genuine daemon-level root distinction raised independently during the session, a real HIGH-severity CVE found and fixed via an explicit dependency upgrade, and a real Trivy false positive investigated and resolved through direct filesystem verification rather than assumption in either direction — including confirming no docker group existed on the target host as concrete evidence standing daemon-level risk was genuinely low there.
