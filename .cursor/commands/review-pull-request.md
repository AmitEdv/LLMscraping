# review-pull-request

Please review this implementation as a peer reviewer.
Be explicit: request changes if needed, or approve with justification.
Suggest simplifications where possible.

Review the provided pull request as a senior peer engineer.

Review process:
1. Summarize what the PR does in your own words (1–2 sentences).
2. Evaluate correctness:
   - Does the implementation fully meet the stated goal?
   - Are there missing edge cases or failure modes?
3. Evaluate code quality:
   - Clarity, readability, naming
   - Structure and separation of concerns
4. Evaluate tests:
   - Are meaningful tests added or updated?
   - Do they actually validate behavior, not just implementation?
5. Evaluate risk:
   - Breaking changes
   - Security, performance, data integrity concerns
6. Decide:
   - Approve
   - Request changes (must be specific and actionable)

Output format:

## Summary
<what this PR does>

## What’s Good
- <bullet points>

## Issues / Questions
- <specific issues, or "None">

## Suggested Improvements
- <concrete, actionable suggestions, or "None">

## Test Coverage Review
<assessment of tests>

## Risk Assessment
<low / medium / high + justification>

## Verdict
<Approve / Request changes>