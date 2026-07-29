# Playbook: AI SQL Chatbot (Natural Language to Database Queries)

## WHY

Non-technical stakeholders constantly need answers from a database but cannot write SQL, creating a permanent bottleneck where every question requires an engineer's time. A natural language interface removes that bottleneck entirely, letting anyone ask a plain English question and get a real answer from live data.

## WHAT This Playbook Delivers

A working chat interface where a user types a plain English question, an LLM converts it into a valid SQL query scoped to the actual database schema, the query executes against the real database, and results return in readable form — with safeguards preventing the AI from ever running a destructive query.

## Prerequisites

A database (PostgreSQL or MySQL) with a known, documented schema. API access to an LLM capable of code generation (Claude, GPT, or similar). A read-only database user specifically for this chatbot to connect through.

## Steps

1. Create a dedicated read-only database user for this chatbot's connection. This single step is the most important guardrail in the entire playbook — the chatbot should be structurally incapable of modifying data, not merely instructed not to.

2. Extract the actual database schema (table names, column names, types, and relationships) and provide it to the LLM as context with every request, so generated queries reference real columns rather than guessed ones.

3. Write a system prompt instructing the LLM to generate only SELECT statements, to never generate INSERT, UPDATE, DELETE, DROP, or ALTER under any framing, and to explain its reasoning for the query it writes.

4. Build the request flow: user types a question, the question plus schema context goes to the LLM, the LLM returns a SQL query, the application validates the query is a SELECT statement before executing it (a second layer of defense beyond the read-only database user), then the query runs and results are formatted back to the user.

5. Add a query timeout and a maximum row limit on every executed query, so an accidentally expensive query (a full table scan on a massive table) cannot degrade the database for other users.

6. Log every generated query alongside the natural language question that produced it, both for debugging incorrect results and for demonstrating exactly what the system did if ever questioned.

7. Test extensively with ambiguous and adversarial phrasing, including attempts to trick the LLM into generating a destructive statement through creative wording, confirming the read-only database user blocks it regardless of what the LLM outputs.

## Guardrail Check

The read-only database user is non-negotiable and must exist before this chatbot ever goes live, regardless of how confident the query-validation logic seems. Never grant this chatbot's database user write permissions under any circumstances, even temporarily for testing, since a testing shortcut here is exactly the kind of exception that causes real incidents.

## Reference Implementation

This is a genuinely novel build, not based on an existing Zero to Hero series. Reference OpenAI or Anthropic's official documentation for structured tool use / function calling patterns, and PostgreSQL or MySQL's official documentation for creating a properly scoped read-only role.
