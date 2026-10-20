# 5. Connecting and accessing Salesforce from OpenAI ChatGPT

## What you need

- A Salesforce org with the hosted MCP server enabled.
- A ChatGPT plan that supports connecting external tools through MCP. Check the current plan details, since OpenAI changes these often.
- A Salesforce user whose access matches what the assistant should be allowed to do.

The steps are close to the Claude setup in note 02. The main differences are where you add the connector and what the screens look like, which change over time. Follow the on-screen wording, not old screenshots.

## Steps

1. In ChatGPT, open the settings for connected apps or tools and choose to add an MCP server.
2. Paste the server URL from Salesforce.
3. Complete the Salesforce OAuth login and approve the access.
4. Start a chat and turn the Salesforce connector on for that chat if your plan asks you to.

## Test it

Ask: "List the five most recently modified opportunities I own." Then check the list in Salesforce. Matching results mean the connection and permissions work. Different results usually mean a different user was signed in, so check which login the browser used.

## Example (illustrative)

Prompt: "Which contacts at Northwind have an email address but no phone number?"

A good answer names the contacts and says how many were checked. If ChatGPT answers without calling the Salesforce tool, the connector was probably not enabled for that chat. Turn it on and ask again.

## Differences to keep in mind

- **Same data, different client.** The permissions are the same whichever client you use. Only the interface changes.
- **Session length.** Long chats can drop tool access. If a tool stops working mid-conversation, start a new chat.
- **Shared accounts.** Do not share one login across a team to save setup time. Every answer will be based on that one person's access.

## Try it

Ask the same question in Claude and ChatGPT, then compare the record counts. If they differ, check whether both were signed in as the same Salesforce user and whether both had the same tools enabled.
