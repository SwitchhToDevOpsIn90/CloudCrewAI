# Playbook: Package Pinning and Safe System Upgrades

## WHY

A routine system upgrade can silently replace a package version that a client's application depends on, breaking something that was working perfectly the day before. This is a genuinely common, avoidable incident — the fix is knowing which packages are load-bearing before running a blanket upgrade, not discovering it after something breaks.

## WHAT This Playbook Delivers

A safe, repeatable process for identifying critical packages, protecting their exact version from unwanted upgrades, safely applying routine updates to everything else, and correctly handling any kernel update that requires a reboot to actually take effect.

## Prerequisites

sudo or root access on the target Linux server. Awareness of which installed packages, if any, are version-sensitive for the client's actual running application (this is a conversation to have with the client or check application documentation for, not something to guess at).

## Steps

1. Identify any packages where the exact currently-installed version matters — a specific database client library, a specific language runtime, or any dependency the client has explicitly flagged as version-sensitive.

2. Pin each identified package to its current version using apt-mark hold, preventing it from being touched by any future upgrade until explicitly released.

3. Confirm the pin took effect using apt-mark showhold before proceeding with any upgrade.

4. Run the standard update and upgrade cycle for everything else — apt update to refresh available package information, then apt upgrade to apply available updates, confirming held packages are correctly skipped.

5. Check specifically whether a kernel update was among the applied updates, since a new kernel package being installed does not mean the running system is actually using it yet — a reboot is required to activate a new kernel.

6. Before rebooting any server running scheduled automation, check the current time against that automation's schedule to avoid an awkward collision, then reboot.

7. After a reboot, a dropped SSH session is expected, not an error. Wait a reasonable interval, then reconnect and verify the new kernel is genuinely active using uname -r.

8. If direct SSH reconnection fails from a different network than previously configured, remember that a Security Group locked to one specific IP will block any other network entirely — use a browser-based fallback such as AWS Session Manager, which does not depend on port 22 or IP allowlisting.

## Guardrail Check

Never run a blanket system upgrade on a client's production server without first checking for any version-sensitive dependencies specific to their application. Never reboot a production server without first checking its current time against any scheduled automation running on it. Confirm a reliable non-SSH fallback connection method exists before initiating any reboot, in case a networking issue prevents immediate SSH reconnection afterward.

## Reference Implementation

See github.com/SwitchhToDevOpsIn90/devops-journey, Session 20 — apt-mark hold used to protect a package through a full upgrade cycle, followed by a real kernel update requiring a reboot, completed safely around an active cron schedule, with a real Security-Group-related reconnection issue resolved via Session Manager.
