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

3. Run the container process as a non-root user inside the image, never as root, to limit the damage possible if the container is ever compromised.

4. Use a multi-stage build for compiled languages, so the final image contains only the compiled artifact and runtime dependencies, not the entire build toolchain.

5. Add a HEALTHCHECK instruction so orchestration tools can detect a genuinely unhealthy container, not just a crashed one.

6. Build the image locally and test it runs correctly before pushing anywhere.

7. Tag the image with both a specific version and never rely solely on the latest tag for anything running in production, since latest can silently change underneath a deployment.

8. Push to a container registry scoped with least-privilege credentials, matching the same IAM discipline used for AWS access elsewhere in this framework.

## A Real, Recurring Debugging Pattern: PATH Issues Inside Containers

A command that installs successfully via apt but then fails with "executable file not found in $PATH" when run as a Dockerfile CMD or ENTRYPOINT is a genuinely common, easy-to-hit issue — not a sign anything is fundamentally wrong. Some packages install their binaries into locations not included in the container's default PATH, most commonly /usr/games for certain utility packages.

When this happens: run the image interactively (docker run --rm -it IMAGE bash), confirm the binary is missing from PATH with which BINARY_NAME, then locate its actual installed location with find / -name BINARY_NAME 2>/dev/null. Fix by referencing the full absolute path directly in the Dockerfile's CMD or ENTRYPOINT instruction, rather than relying on it being discoverable via PATH.

This same root cause (a package installing outside the expected PATH) can appear identically on a bare Linux server with no Docker involved at all — recognizing the pattern once means recognizing it instantly in either context.

## A Second Real Gotcha: Image References by Name vs ID

Some Docker commands, particularly docker history, can behave inconsistently when referencing an image by its tagged name versus its image ID, even when docker images clearly confirms the named image exists. If a name-based reference unexpectedly fails, retry the same command using the image ID from docker images output as a reliable fallback before assuming something is broken.

## Guardrail Check

Never push an image tagged as a production version without the human operator confirming it has been tested. Never run a container with unnecessary elevated privileges or with the Docker socket mounted inside it unless there is a specific, reviewed reason.

## Reference Implementation

See github.com/iam-veeramalla/Docker-Zero-to-Hero for foundational patterns and example Dockerfiles across multiple application types. See github.com/SwitchhToDevOpsIn90/devops-journey, Session 21, for a real, live example of both the PATH debugging pattern and the name-vs-ID image reference quirk, including the exact diagnostic commands used to resolve each.
