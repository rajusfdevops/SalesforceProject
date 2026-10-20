# 22. Building custom MCP tools with named queries for custom data requirements

## Why named queries

Sometimes the standard object tools are not enough. A user wants "open renewals in my region with a discount above 15 percent", and no single object endpoint answers that cleanly. A named query lets you write the query once, give it a name, and expose it as a tool. The agent passes in the few values it needs, and the query stays fixed.

The main benefit is control. The agent never writes SOQL, so it cannot pull fields or filters you did not intend.

## Design the query before the tool

Write the query first, outside Salesforce, as plain SOQL. Decide:

- Which fields the user actually needs. Leave out the rest.
- Which inputs the agent may set, such as region or a date range.
- Which inputs are fixed, such as "status is open".
- A row limit. Always set one.

Fixed filters belong in the query. Anything the agent controls should be a bind variable with a clear name.

## Naming and description

The tool name and description are what the model reads when it chooses a tool. Write them for that reader. "Find open renewals above a discount threshold for one region. Returns up to 50 rows." is useful. "Renewal query v2" is not.

## Testing

- Run the query in Developer Console with each combination of inputs.
- Check the empty result.
- Check the row limit is applied.
- Connect a client and ask a question that needs exactly this tool. Confirm it does not call a different tool.

## Example (illustrative)

A named query returns open renewals for a region above a discount threshold. A user asks, "Which EMEA renewals are discounted more than 15 percent?" The agent sets region to EMEA and threshold to 15, and gets back at most 50 rows. If it returns nothing, check the discount field is populated on those records before you assume the tool is wrong.

## Try it

Write one named query for a question your team asks often. Test it in the Developer Console with three inputs, then wire it to a tool and ask the same question in a client.
