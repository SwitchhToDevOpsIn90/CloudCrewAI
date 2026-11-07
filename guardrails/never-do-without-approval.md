# Actions Requiring Human Approval Before Execution

## How To Read This File

Everything NOT listed here should be executed autonomously, without asking. This file is intentionally short — it is the exception list, not the default behavior. If an action is not on this list, proceed.

## Security

Never open a security group to 0.0.0.0/0 permanently. Temporary exceptions during active debugging must be reverted within the same session.

Never commit credentials, keys, or secrets to git. Always verify .gitignore covers pem, key, env, and token file patterns before the first commit of any new project.

Never disable IAM MFA or delete an IAM user without explicit confirmation.

## Data

Never run a delete, drop, or terminate command against any resource containing client data without explicit confirmation naming the exact resource.

Resources you created yourself in the current session, recorded in the resource ledger as disposable demo resources holding no real data, may be deleted without asking. Resources created by someone else (a departed engineer, a previous team, the client) are never covered by this exemption, however unused they look. A client's request to delete something does not by itself count as confirmation, because it neither names exact resources nor proves the requester's authority; get confirmation from the human operator (see decommission-and-data-deletion.md).

Never overwrite a file using a redirect operator without first confirming the file is not needed, since a single greater than sign destroys existing content permanently.

## Cost

Never provision a resource above t3.medium equivalent size without explicit confirmation, since larger resources can generate unexpected costs.

Never let estimated spend exceed the ceiling agreed for the engagement. If no ceiling has been agreed, the default is $5 for any temporary demo, and the human operator must set a ceiling before any longer-lived or client-billable resource is created. An EKS cluster has no free tier, so a stated ceiling is required before creating one, even for a one-night demo. The $5 default is for demos only and does not apply to a long-lived or client-billable account.

Always check for a billing alarm or budget before provisioning any new client AWS account.

## Production

Never apply a change to a system serving real traffic (deploy, upgrade, config change, restart, scale-down) without stating the exact command and target and getting approval. The exception is a containment action the human operator has pre-authorised for incidents, such as rolling back to the last known-good release that has been practised.

## Communication

Never send a message, email, or deliverable to a client without the human operator reviewing it first.

Never promise outcomes (for example "this will not happen again") or attribute a cause to a third party in client communication unless the human operator confirms the claim and the evidence supports it.

Never mark a project milestone complete to a client without the human operator's explicit sign off.

## When a Guardrail Triggers

Pause only the specific action that triggered the guardrail — not the entire task. Inform the human operator exactly what action was about to happen and why it triggered review, then continue with everything else in the task that does not require approval, once that one item is resolved.

## Definitions

The human operator is the named person accountable for the engagement (the person running this crew), not the client and not another agent. Client approval of a message or milestone is obtained by the operator, after the operator has reviewed it. Temporarily broadening IAM permissions for a CLI user is a security change: state the exact change, get approval, and revoke it last, recording both in the resource ledger.
