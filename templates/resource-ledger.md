# Resource Ledger — <project name>

This file shows the format. Keep the real ledger with `tools/ledger.py` (default file `.crew/ledger.md`): `init`, `add`, `note`, `close`/`keep`, `check`. The tool refuses secrets and masks 12-digit numbers.

Record every cost-bearing resource at the moment it is created, so teardown is a checklist, not a memory exercise. Never record secrets or account IDs.

Cost ceiling: <amount>   Region: <region>   Owner: <accountable person>

| Created (UTC) | Type | Name / ID | Est. cost | Created by (skill / playbook) | Teardown command | Removed (UTC) | Verified by |
|---|---|---|---|---|---|---|---|
| | | | | | | | |

Rule: a project is not finished while any row has an empty "Removed" or "Verified by" cell, unless the resource is intentionally kept and says so.
