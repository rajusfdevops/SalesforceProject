# 7. Using custom Salesforce capabilities from Claude via a custom MCP server and tools

## The big picture

Notes 10 and 12 cover how to build tools. This note covers the other half: getting Claude to use them. Once your custom server exists, Claude sees it the same way it sees any connector, through a list of tools with names, descriptions, and input schemas. Claude decides when to call a tool based on those descriptions.

So the work is mostly about descriptions and scope, not about Claude itself.

## Setup flow

1. Create the custom MCP server in Salesforce and add your tools to it.
2. In Claude, add the server as a custom connector, using the server URL.
3. Sign in with the Salesforce user who should own the actions.
4. Start a new chat and check that your custom tools appear by name.

If a tool is missing, the usual causes are that it is not added to the server, it is switched off, or the connector needs to be removed and added again.

## Writing descriptions Claude can use

Claude chooses tools from text, so write for it:

- Say what the tool does in one sentence, starting with a verb.
- Say what it does not do. "Creates a quote. Does not send it to the customer."
- Describe each input in plain words, including the format, such as "ISO date, for example 2026-03-31".

A description like "Process renewal" will get used at the wrong time. "Create a renewal quote for an existing Account. Requires the Account ID." will not.

## Example (illustrative)

Two custom tools exist: "Get Account Health" and "Create Renewal Quote".

Prompt: "Is Bluebird Logistics healthy enough to renew at a higher tier?"

A good sequence: Claude calls "Get Account Health" first, reads the score and open case count, and only then decides whether to offer a quote. It should not create a quote just because the tool exists. If it does, tighten the description of the quote tool or add a clear statement that it requires a request from the user.

## Limits and checks

- Keep the tool count small. A server with forty loosely related tools confuses the model. Group related actions into separate servers if you need many.
- Test with the exact wording a user would use. Your own careful phrasing is not a realistic test.
- Log which tools Claude called, so you can see patterns in misuse.

## Try it

Pick two tools. Ask Claude a question that needs only the first one, then a question that needs both. Check that it calls the right tools in the right order and does not call the write tool when it should only read.
