# 11. Working with Salesforce sales skills in Claude

## What a skill is

A skill is a written playbook. It tells Claude which data to pull, in what order, and how to present the result. When you ask for a pipeline review, the skill decides which fields to check, what counts as stale, and what the output should look like.

Skills are only as good as the question you ask. You do not need special syntax, but you do need to name the thing you want.

## Asking well

Compare these two prompts:

- "How's my pipeline?"
- "Review my pipeline for Q4. Flag deals over 50k with a close date in the past, and tell me which stage has the most value stuck."

The second one gives the skill a time window, a size threshold, and a specific question. You will get a more useful answer, and you can check it faster.

## Common skills and when to use them

- **Pipeline review.** Stage-by-stage health, coverage, and aging.
- **Deal review.** One opportunity in depth, including risks and missing qualification fields.
- **Call prep.** A brief before a meeting, built from the account history and open opportunities.
- **Account context.** A quick picture of an account across records, email, and calls.

Pick the narrowest skill that fits. A deal review is faster and tighter than a full pipeline review when you only care about one deal.

## Checking the output

Skills pull data, but they also write prose. Read the numbers against the source before you use them. Pay attention to:

- Dates. Confirm the "today" Claude is using matches your local date.
- Currency. Check the amounts are in the currency you expect.
- Missing items. If a skill says "no risks found," ask whether it checked the fields you care about.

## Example (illustrative)

You ask for a deal review on a 120k opportunity. The skill reports that the economic buyer is not on the opportunity contact roles. You check the account and find the buyer was added to the account but never to the opportunity. The skill was right, and the fix is a two-minute update in Salesforce.

## Try it

Run the same pipeline question twice, once vague and once specific. Note which answer you could act on without asking follow-up questions.
