# 26. Using Agentforce agents as MCP tools

## The idea

Note 25 built an agent that works inside Salesforce. This lesson exposes that agent as one tool on an MCP server. An outside client, such as Claude or Slackbot, calls the tool, and the agent does the multi-step work behind it. The client receives one answer.

This is useful when the task needs several actions in order, and you do not want the external client to know about each step.

## Setup in outline

1. Make sure the agent works on its own inside Salesforce.
2. In the custom MCP server setup, add a tool and choose the agent as its backing type.
3. Give the tool a name and a description. The description tells the client when to use it, so describe the outcome, not the internals.
4. Publish the server and connect a client.

The exact screens may differ by org edition and release, so follow the current setup guide for your org.

## Choose the description carefully

The client decides whether to call your agent based on the description. A vague one means the agent is never used, or used for the wrong questions. Include the kind of question it answers and the kind it does not.

## Watch the permissions

The agent runs with the permissions it has been given, and the caller's identity may not carry through in the way you expect. Test with a user who has narrow access, and confirm the agent cannot show records that user should not see.

## Example (illustrative)

A tool called "Account Order Status" wraps an agent. Claude asks it for the status of one customer's open orders. The agent looks up the account, gathers the orders, and returns a summary. Claude passes the summary to the user without knowing the steps. If the agent asks a question back, the client needs to pass it along, so test that round trip.

## Try it

Expose one agent as a tool. Ask a question that needs two steps inside the agent, then check the answer against the records. Then ask a question the agent should refuse, and confirm it does.
