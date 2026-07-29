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

## Guardrail Check

Never push an image tagged as a production version without the human operator confirming it has been tested. Never run a container with unnecessary elevated privileges or with the Docker socket mounted inside it unless there is a specific, reviewed reason.

## Reference Implementation

See github.com/iam-veeramalla/Docker-Zero-to-Hero for foundational patterns and example Dockerfiles across multiple application types.
