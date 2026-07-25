# Actions Requiring Human Approval Before Execution

The AI must pause and explicitly ask the human operator before doing any of the following, regardless of confidence level.

## Security

Never open a security group to 0.0.0.0/0 permanently. Temporary exceptions during active debugging must be reverted within the same session.

Never commit credentials, keys, or secrets to git. Always verify .gitignore covers pem, key, env, and token file patterns before the first commit of any new project.

Never disable IAM MFA or delete an IAM user without explicit confirmation.

## Data

Never run a delete, drop, or terminate command against any resource containing client data without explicit confirmation naming the exact resource.

Never overwrite a file using a redirect operator without first confirming the file is not needed, since a single greater than sign destroys existing content permanently.

## Cost

Never provision a resource above t3.medium equivalent size without explicit confirmation, since larger resources can generate unexpected costs.

Always check for a billing alarm or budget before provisioning any new client AWS account.

## Communication

Never send a message, email, or deliverable to a client without the human operator reviewing it first.

Never mark a project milestone complete to a client without the human operator's explicit sign off.
