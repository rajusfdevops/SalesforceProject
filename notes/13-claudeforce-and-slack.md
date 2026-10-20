# 13. Claudeforce + Slack: working with Salesforce and Slack directly from Claude

## Why Slack is in the picture

The Claudeforce plugin includes a Slack connector next to the Salesforce one. The idea is that you can pull what your team said in a channel alongside the record it relates to. A deal discussion in Slack and the opportunity it belongs to are often in two places. This connector lets Claude look at both.

## Setup

- The Slack connector is part of the plugin, so the admin setup in note 10 covers the organization side.
- Each user signs in to Slack with their own account. Claude can only read the channels that account can see.
- Check the channels you expect Claude to search. Private channels you are not in will not show up.

## Good uses

- Summarizing a deal thread before a call, with a link back to the opportunity.
- Finding who on the account team last mentioned a competitor.
- Turning a long channel discussion into next steps you can log in Salesforce.

## Things to be careful about

- Slack messages are informal. A message saying "we're basically sold" is not a signed deal. Check the opportunity stage before you trust it.
- Do not paste confidential Slack content into a Salesforce record unless your org allows it.
- Ask Claude to say which messages it used, so you can read them yourself.

## Example (illustrative)

Prompt: "Find the Slack thread about the Northwind pricing concern this week and tell me whether it was resolved."

A good answer names the channel, the date, and the last message. It should also say if it could not find a resolution, rather than guessing.

## Try it

Pick one open deal with active Slack discussion. Ask Claude for a summary with sources. Read two of the cited messages yourself and check the summary matches them.
