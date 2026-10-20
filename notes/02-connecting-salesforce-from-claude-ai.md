# 2. Connecting and accessing Salesforce from Claude AI

## Before you start

You need three things:

- A Salesforce org where the hosted MCP server is enabled, and a user with a Salesforce license.
- A Claude plan that allows custom connectors (check the current plan table, since this changes).
- The server URL from the Salesforce setup page. Do not guess it from a blog post.

## Steps

1. In Claude, open the connectors or integrations settings and choose to add a custom connector.
2. Paste the MCP server URL from Salesforce.
3. Claude opens a Salesforce login window. Sign in as the user whose access you want the AI to have, then approve the requested scopes.
4. Back in Claude, start a new chat and check that the Salesforce tools show up in the tool list.

Pick the user on purpose. Whoever signs in is who the AI acts as.

## First test

Ask something you already know the answer to, such as "How many accounts did I create this month?" Compare the number with a report you run yourself. If they match, the connection and the permissions are both right. If they differ, look at the sharing and the date range before you blame the connector.

## Example (illustrative)

Prompt: "Summarize the open cases on the Acme account and list any that are older than 14 days."

Expected behavior: Claude runs a case query filtered by account name, then returns counts and a short list. If it asks you to confirm an account name that matches two records, that is correct behavior. It is better than picking one silently.

## Troubleshooting

- **Login loop or "unauthorized".** Usually the OAuth app or the user's license. Confirm the user can log in to Salesforce directly.
- **Tools missing.** The client may cache the tool list. Remove and re-add the connector.
- **Empty results.** Check the user's record access first, then the filters the model used. Ask Claude to show the query it ran, if the client exposes it.

## Try it

Connect the same org twice, once as an admin and once as a standard user. Ask both for the same list of records and write down the difference. That gap is what your security model is doing.
