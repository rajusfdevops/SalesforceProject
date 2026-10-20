# 27. Spinning up a Slack org with limited Slackbot AI access

## Why a separate Slack org

Before you connect Salesforce to Slack for real work, set up a Slack workspace for testing. Keep Slackbot's AI access limited in that workspace, so test messages and mistakes stay contained. Use real users and real channels only after the setup works.

## Limit what Slackbot can see

- Create a small test workspace with a few channels, none of them customer-facing.
- Invite only the people who will test.
- Turn on AI access for those people only, not for the whole workspace.

Limited access is a setting to check, not a default to assume. Check it after every change to the workspace.

## Check before you connect anything

- Confirm the workspace plan supports Slackbot and the features you need.
- Confirm the Salesforce org has no IP restrictions that would block the MCP connection. Slack's help article notes that Salesforce MCP servers cannot connect when the org restricts IP addresses.

## Example (illustrative)

Your test workspace has three channels: `#sf-test`, `#sales-sandbox`, and `#random`. Only `#sf-test` and `#sales-sandbox` are visible to the two test users. You ask Slackbot a question about a sandbox account. It answers from the sandbox org, and the answer stays inside those channels.

## Try it

Create the test workspace, invite two test users, and confirm Slackbot answers a simple question for one of them and not for a user you left out.
