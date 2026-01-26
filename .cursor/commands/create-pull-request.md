# create-pull-request
Create a pull request for the current changes.

Steps:
1. Summarize the purpose of the change in 2–3 concise sentences.
2. List the key implementation points (bullet points).
3. Specify which areas of the system were affected (frontend, backend, DB, API, infra).
4. Describe how the change was tested (commands run, tests added, manual steps).
5. Explicitly list risks, limitations, or follow-up work (or state “None”).
6. Provide clear reviewer instructions: what to focus on and how to verify.
If any section would be weak or incomplete, explicitly say so and explain why.
Do not invent tests or verification steps.

Output format:

Title:
<short, descriptive title>

Description:
## What
<summary>

## Why
<context / motivation>

## How
<implementation bullets>

## Testing
<tests + verification steps>

## Risk / Notes
<edge cases, trade-offs, or "None">

## Reviewer Focus
<what the peer reviewer should pay attention to>