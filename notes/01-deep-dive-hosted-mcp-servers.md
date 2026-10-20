# 1. Deep dive into Salesforce hosted MCP servers

## What problem they solve

Before hosted MCP, if you wanted Claude or ChatGPT to read Salesforce records, someone had to build and run a connector: a server, a token store, a deploy pipeline, and a list of tools. Hosted MCP servers remove that work. Salesforce runs the server, and your AI client connects to it over the standard Model Context Protocol.

## The two kinds of server

- **Standard servers** ship with Salesforce. You turn them on and pick which capabilities to expose.
- **Custom servers** are the ones you define. A common pattern is to publish an existing Flow as a tool, so an agent can call "create renewal quote" the same way a person would run the Flow.

## What happens on a tool call

1. The client (Claude, ChatGPT, or your own agent) asks the server what tools exist.
2. The model picks a tool and sends arguments.
3. Salesforce checks the signed-in user's permissions, meaning object access, field-level security, and sharing rules.
4. The result comes back as structured data, and the model writes its answer from that.

Step 3 is the part to remember. The agent sees only what that user could see in the normal UI. It does not get a shortcut around security.

## Example (illustrative)

A sales rep asks Claude, "Which of my open opportunities over 50k haven't had activity in 21 days?"

- The client calls a read-only query tool with the rep's OAuth session.
- The query runs as the rep. Opportunities owned by other reps are excluded unless the rep has access through sharing.
- Claude gets back a list of records and summarizes it.

If the answer looks too small, check the rep's sharing before you suspect the tool. The most common cause of a "missing" record is access, not the connector.

## Things that catch people

- **Beta labels.** Some hosted servers are still beta. Check the release status before you promise a client they will work.
- **Setup is in Salesforce, not the client.** You enable the server in the org first. The client only connects.
- **Read-only vs. write tools.** Keep write tools off until you have tested them in a sandbox. A model that can update records will eventually update the wrong one.

## Try it

1. In a sandbox org, find the hosted MCP server settings and list which tools are on.
2. Connect one client and ask it to list a single object's records.
3. Log in as a second user with narrower access and repeat. Note what changes.
