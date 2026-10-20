# 15. Enabling HXL and creating an MCP server

## Before you start

HXL has to be turned on for the org before any widget will render. Check that your org and your Salesforce edition support it, then ask an admin to enable it in Setup. Doing this first saves you from debugging a widget that never had a chance to load.

## Creating the MCP server

The MCP server is the entry point clients use to reach your tools. Keep it small at first:

1. Create a custom MCP server in Setup.
2. Give it a clear name that says what it serves, such as `OrderInsights`.
3. Leave it with no tools yet. Add them one at a time, testing each.

A good naming habit: the server name should describe a business area, and each tool name should be a verb plus an object.

## Testing the empty server

Connect a client to the empty server and confirm it connects without errors. This tells you the endpoint and login work before any widget is involved. Many people skip this and then blame the widget for a connection problem.

## Common mistakes

- Enabling HXL in a sandbox and forgetting production.
- Naming the server with a placeholder like `test1` and keeping it.
- Adding several tools before any of them has been tested.

## Example (illustrative)

You create `OrderInsights` in a sandbox, connect Claude, and see it listed with zero tools. Then you add one read-only tool, "Get Recent Orders", and confirm Claude can call it and get plain data back. Only after that do you attach a widget to it in the next lessons.

## Try it

Create an empty MCP server in a sandbox and connect one client. Write down the exact steps and any error text. You will need this when something breaks later.
