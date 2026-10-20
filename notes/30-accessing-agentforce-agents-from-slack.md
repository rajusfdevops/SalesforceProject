# 30. Accessing Agentforce agents as MCP tools from Slack

## Same pattern, different client

Note 26 covered exposing an agent as an MCP tool. This lesson is the same idea with Slackbot as the client. Once the agent is a tool on your server, Slackbot can call it the way it calls any other tool.

## Why this is handy

A team can ask one question in Slack and get an answer that took several steps inside Salesforce. The agent does the orchestration, and Slackbot shows the result. Nobody needs to know which steps ran.

## Checks before you rely on it

- The agent works inside Salesforce with the same user who will ask in Slack.
- The tool description tells Slackbot when to use the agent and when not to.
- Long answers are summarized, so the thread stays readable.

## Example (illustrative)

A manager asks in a thread, "Summarize risks on the top three deals this quarter." Slackbot calls the agent tool. The agent returns three short summaries. The manager can reply with "Open the second one", and Slackbot gives the record link.

## Try it

Ask a multi-step question from Slack and time the response. Then ask the same question in Claude and compare the answers. Note any difference in wording or detail.
