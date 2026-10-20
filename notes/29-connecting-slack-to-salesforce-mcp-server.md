# 29. Connecting Slack to the Salesforce MCP server: step-by-step setup

## Before the steps

You need four things in place:

1. A Slack test workspace with limited Slackbot access (note 27).
2. A Salesforce sandbox with the MCP server you want to expose.
3. An admin on both sides, or someone who can act for them.
4. A test user in each system who matches the other.

Doing this in a sandbox first means a wrong permission setting costs you a test, not a production record.

## Steps

1. In Salesforce, confirm the MCP server is published and has at least one read-only tool.
2. In Slack, open the Slackbot setup for MCP connections and add a new server.
3. Enter the server details from Salesforce, then sign in with the test user when prompted.
4. Approve the access requested. Read it, rather than clicking through.
5. Back in Slack, check the new tools appear for the test user.

The exact labels in Slack change over time, so use the current help article for names.

## If a step fails

- A login error usually means the Salesforce user cannot sign in to that org, or is not set up for API access.
- Tools missing means the server was not published, or the tool is switched off.
- An IP restriction error means the org needs an exception for Slack. Ask the admin before you change anything.

## Example (illustrative)

You add the server and see no tools. You check the server in Salesforce and find it was saved but never published. You publish it, return to Slack, and the tools appear after a refresh.

## Try it

Connect one read-only tool. Ask Slackbot a question that needs it. Then write down each setting you changed, so you can repeat the setup for production.
