# Playbook: SSH and Server Hardening

## WHY

Any server with a public IP is scanned by bots within minutes of going live, constantly probing port 22 for weak passwords or default credentials. Without hardening, a single successful brute-force guess grants full server access.

## WHAT This Playbook Delivers

A hardened SSH configuration using key-based authentication only, a host firewall allowing only necessary traffic, and automated brute-force protection that bans attacking IPs — all without risking a lockout during setup.

## Prerequisites

An EC2 instance or equivalent Linux server with an existing SSH key pair already configured and confirmed working. Root or sudo access to edit system configuration files.

## Steps

1. Confirm key-based SSH access is already working before touching any configuration — never harden a connection method you have not verified first.

2. Check both the main sshd_config AND any drop-in override files in sshd_config.d/, since cloud images often set critical defaults there rather than in the main file. In OpenSSH, the first matching value wins, so an override file can silently control real behavior.

3. Make hardening explicit and permanent in the main sshd_config: disable root login, limit authentication attempts, reduce the login grace period, and disable unused features like X11 forwarding.

4. Always validate the configuration syntax before restarting the SSH service. A syntax error combined with a restart can lock out all access permanently, since there is no other way in without console/rescue access.

5. Enable a host firewall, but allow SSH explicitly BEFORE enabling it. Enabling a firewall with the wrong rule order is a common, self-inflicted lockout.

6. Install brute-force protection that monitors authentication logs and automatically bans IPs after a small number of failed attempts within a time window.

7. Use a dedicated local override file for the brute-force tool's configuration rather than editing its default file directly, since package updates overwrite the default but never touch a local override.

## Guardrail Check

Never restart the SSH service without validating configuration syntax first. Never enable a firewall without explicitly allowing the current access method first. Confirm you have console/out-of-band access (e.g., AWS Session Manager) as a fallback before making any of these changes, in case a mistake does occur.

## Reference Implementation

See github.com/SwitchhToDevOpsIn90/devops-journey, Session 17 — sshd_config hardening, ufw firewall, and fail2ban brute-force protection, all validated live on a real EC2 instance.
