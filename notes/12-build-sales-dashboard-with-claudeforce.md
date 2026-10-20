# 12. Build a complete Salesforce sales dashboard with Claudeforce

## What this lesson is about

The goal is a single view of your sales numbers, built by asking Claude for each panel instead of building it in a report builder. A dashboard in this sense is a set of related answers you can rerun and compare, not a saved Salesforce dashboard.

This approach is faster to set up, but it is less formal. Treat the output as a working view for your own review, not an official report, until you have checked it against your standard reports.

## Plan the panels first

Before you ask for anything, decide what the dashboard needs to answer. A practical set for one rep:

1. Open pipeline by stage, with totals.
2. Deals closing this month and next, with the amount and forecast category.
3. Deals with no activity in the last 14 days.
4. Deals with a close date already in the past.
5. Top five accounts by open value.

Five panels that answer real questions beat fifteen panels nobody reads.

## Build it one panel at a time

Ask for panel 1 first. Check it against a Salesforce report. Only then move on. If you build all five at once and one is wrong, you will not know which.

Keep a short note of the exact prompt you used for each panel. That way you can rerun it next week and compare.

## Example (illustrative)

Prompt for panel 3: "List my open opportunities over 25k with no activity in the last 14 days. Include the account name, owner, stage, and days since last activity."

Check the result. If an opportunity shows activity you know happened, the activity may be logged on a different record, such as the contact instead of the opportunity. That is a data problem to fix, not a dashboard problem.

## Keeping it honest

- Write down the date of each run. Pipeline changes daily.
- Note any panel you could not verify.
- Do not share the output as a forecast without a manager review.

## Try it

Build panels 1 and 4. Compare each against a standard report. Write down any difference and what caused it.
