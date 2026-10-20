# 24. Creating custom MCP tools from Apex REST services

## Two routes to the same goal

Note 23 used the API catalog. This lesson covers the other route: taking an Apex REST service and exposing it directly as a custom MCP tool, from your own custom MCP server. The result is similar, but you control the tool's name, description, and inputs.

Use the catalog when a standard endpoint already does the job. Use a custom tool when you need your own logic or your own input names.

## Steps

1. Start from a working `@RestResource` class, like the one in note 23.
2. Add it to a custom MCP server as a tool.
3. Map each tool input to a parameter the REST method reads.
4. Write the description for the agent, not for yourself.
5. Redeploy the server and reconnect the client.

Reconnect after each change. A client that connected before the change may still show the old tool list.

## Input mapping

Be exact about names. If the REST method reads `region` from the query string, the tool input should map to `region`. A mismatch returns an empty result, which looks like "no data" rather than an error.

## Errors

Return a readable error from the Apex method when input is missing, rather than letting it throw an unhelpful exception. The agent can only explain what it receives. A message like "region is required" lets it ask the user for the value.

## Example (illustrative)

A tool called "Get Open Renewals" takes a region. A user asks about "the Nordics", and the agent passes "Nordics" as the region. The query returns nothing because the picklist value is "Nordic". The fix is in the tool description: list the valid region values, so the agent can map the user's words to them.

## Try it

Expose your read-only REST class as a tool. Ask about a region in three different ways, such as "EMEA", "Europe", and "the European team". Note which phrasings work without help and fix the description for the ones that do not.
