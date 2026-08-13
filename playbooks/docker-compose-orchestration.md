# Playbook: Docker Compose Multi-Service Orchestration

## WHY

Real applications are rarely a single container — an app typically needs a database, sometimes a cache, sometimes a message queue, all running together and able to reach each other. Manually starting each container with the correct networking, environment variables, and startup order every time is repetitive and error-prone. Docker Compose defines the entire multi-service setup as one reviewable, version-controlled file.

## WHAT This Playbook Delivers

A working multi-container application (typically an app plus a database) that starts with a single command, where services reach each other by name rather than IP address, where database data genuinely survives a full teardown or even a host reboot, and where the app genuinely waits for its dependencies to be ready rather than merely started.

## Prerequisites

Individual services already working as standalone containers, per the Docker containerization playbook. A clear picture of which services need to talk to which, and on which ports.

## Steps

1. Define each service in a docker-compose.yml file, using the service name as the natural way other services will reach it — Compose provides automatic internal networking where a service can reach another simply by using its service name as the hostname, no manual IP configuration needed.

2. Externalize all configuration, especially credentials, to a .env file referenced by the compose file, exactly matching the discipline established in the secrets incident response playbook — confirm .env is listed in .gitignore before it ever contains a real value, not after. A .gitignore entry for .env at the repository root protects every subdirectory automatically, so this only needs setting up once per repository.

3. For any service that persists data (most commonly a database), define a named volume and mount it to the service's data directory. Without this, every docker compose down destroys all data — a genuinely common, painful mistake for anyone new to Compose.

4. Never rely on depends_on alone to guarantee a dependency is actually ready. depends_on only waits for a container to start, not for the service inside it to be genuinely accepting connections — a database container can report as started while Postgres itself is still initializing. Define a healthcheck on the dependency service using its own readiness-check tool (pg_isready for Postgres is the correct choice, not a generic port check), then use depends_on with condition: service_healthy on the service that needs it, so the app genuinely waits for real readiness, not just container start.

5. Verify the healthcheck is genuinely working, not just configured, by watching the startup log — Compose will explicitly show the dependency reaching a Healthy state before the dependent service starts, and the first request afterward should succeed without any retry needed. If requests still fail intermittently after this is in place, the healthcheck itself is not correctly detecting true readiness.

6. Prove volume persistence with a real test, not just by confirming the YAML has the right lines: insert real data, run a full docker compose down (not merely stop), bring the stack back up, and confirm the data survived. Configuration that looks correct on paper can still fail in practice; only an actual persistence test confirms it. For a genuinely stronger proof, test survival across an actual host reboot, not merely a container teardown and recreation — a named volume backed by real files on the host disk should survive both, but only a real reboot test proves the stronger claim.

7. Define an explicit restart policy on any service that must come back automatically after a host reboot or crash — restart: unless-stopped is the correct default for most services, restarting automatically after any reboot while still respecting a deliberate manual stop. Without this, a container will not automatically restart after a host reboot, silently leaving a database or service down until someone notices. Be precise about where this policy lives: in a docker-compose.yml, it is version-controlled and reapplied every time the stack is redeployed. Applied via docker update to a container started with a plain docker run, it is genuine but more fragile — it lives only in that specific running container's metadata and must be manually reapplied if the container is ever removed and recreated.

8. Test the actual integration end to end, not just that each service independently starts — confirm the app can genuinely reach and use the database through a real request, not just that both containers show as up.

9. Tear down cleanly when done, and verify no orphaned containers or networks remain afterward.

## Guardrail Check

Never commit a .env file containing real credentials to version control, even temporarily during testing. Never provision a compose stack's dependent services without a named volume for any service that must persist data across restarts. Confirm a service that other services depend on has a genuine, verified-working healthcheck, not just an assumed correct configuration.

## Reference Implementation

See github.com/SwitchhToDevOpsIn90/devops-journey, Session 24 — a real Flask application connected to a PostgreSQL database via Docker Compose, using environment-variable-based configuration matching the Session 19 secrets discipline. Volume persistence was proven with a genuine insert-teardown-recreate-verify test, not just YAML review. A pg_isready healthcheck combined with condition: service_healthy resolved a real intermittent connection failure — confirmed by the startup log explicitly showing the database reaching a Healthy state before the app started, after which the first request succeeded on every attempt with zero retries needed.

See also Session 25 for a stronger persistence proof and the restart-policy gap this playbook now covers — the same named-volume pattern was tested against a genuine EC2 instance reboot, not merely a container teardown, and survived intact. The session also surfaced, in review, that the running container had no restart policy applied, meaning it would not have automatically recovered after a real unplanned host reboot — corrected with restart: unless-stopped, and documented precisely as fragile when applied via docker update to a plain docker run rather than defined in the compose file itself.
