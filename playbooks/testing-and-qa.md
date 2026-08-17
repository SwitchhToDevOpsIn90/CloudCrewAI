# Playbook: Testing and Quality Assurance

## WHY

Code without automated tests is code nobody can safely change. Every future modification becomes a guess about whether it broke something else, verified only by manually clicking through the application again — which does not scale, gets skipped under deadline pressure, and misses regressions a computer would have caught instantly. A real engineering team treats untested code as unfinished code, not optional polish.

## WHAT This Playbook Delivers

An automated test suite covering the meaningful behavior of an application, running automatically on every code change before it can merge, with clear visibility into what is and is not covered — turning "I think this still works" into "the tests confirm this still works."

## Prerequisites

A working application with defined, understandable behavior. A CI environment (or the intention to add one) where tests can run automatically, not just on a developer's own machine.

## Steps

1. Write unit tests first for the smallest independently testable pieces of logic — a single function, a single class method — verifying that specific inputs produce specific expected outputs, including edge cases and expected failure conditions, not only the happy path.

2. Write integration tests for the points where independently-working pieces must work correctly together — an API endpoint that reads from a real (or realistic test) database, a service that calls another service — since unit tests passing individually does not guarantee they function correctly combined.

3. Write end-to-end tests sparingly, for the most critical user-facing flows only — a full end-to-end test simulating real usage is valuable but slow and brittle compared to unit and integration tests, so reserve it for the handful of flows where a real user failure would be genuinely severe.

4. Configure test coverage reporting, and treat the resulting percentage as a signal to investigate untested code, not a target to game — a codebase with artificially inflated coverage from trivial tests is more dangerous than one with honest, lower coverage, since it creates false confidence.

5. Run the full test suite automatically on every pull request, before merge is possible, not as a manual step someone might forget to run locally.

6. Block merging on test failure by default, and treat a team member bypassing a failing test as an event worth understanding, not a routine occurrence — a failing test is either revealing a real bug or is itself broken and needs fixing, never something to silently ignore.

7. For any bug found in production that tests did not catch, write a new test reproducing that specific bug before fixing it, confirming the fix by watching that specific test go from failing to passing — this ensures the exact same regression cannot silently reappear later.

## Guardrail Check

Never merge code with a failing test without explicit, reasoned human approval and a clear plan to address it immediately afterward. Never treat 100% test coverage as inherently meaning safe — coverage measures whether a line executed during tests, not whether the test meaningfully verified correct behavior.

## Reference Implementation

This is a foundational team-operating practice rather than a single traced incident. Apply consistently from the first test written on any project, establishing the habit before complexity makes retrofitting tests significantly harder.
