# Evaluation Harness (v0: blind paper tests)

Purpose: measure whether a fresh AI, given only this repository, picks the right role and playbooks, stops at the right guardrails and plans the right verification. Accuracy is a measured number, not a claim.

## Method

1. Start a fresh agent with no prior context. Give it only the repository path and one scenario prompt from scenarios.md.
2. Tell it this is a paper exercise: read files only, run no cloud commands, change nothing, and do not read the evals folder.
3. Ask for five sections: role and playbooks used; plan; guardrails that would pause it; verification; anything confusing or missing.
4. Score the answer against the scenario's expected result (also in scenarios.md): pass/fail per criterion.
5. Record the results in results/ with the date, the models used and the repository commit. Fix every confusing or missing item the agents report, then re-run.

## Limits (be honest about what this does not prove)

- It tests routing and planning on paper, not whether the commands work on real infrastructure.
- Scenarios were written by the repository author, so they are not adversarial.
- Small sample, and a single model family in the baseline run. Run more scenarios and more models before quoting a pass rate.
- Agents' claims about gaps need checking against the files before fixing; some reports are wrong.

## Next versions

v1: more scenarios, several models, repeated runs for variance. v2: executed tests on a free local cluster. v3: dry-run project for a fictional client (see docs/vision.md).
