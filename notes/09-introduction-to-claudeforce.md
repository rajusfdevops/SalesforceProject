# 9. Introduction to Claudeforce: Salesforce inside Claude

## What it is

Claudeforce is Salesforce's plugin for Claude. It brings your Salesforce accounts, opportunities, and pipeline into a Claude chat, so you can ask about them without switching tabs. It ships with a set of sales skills and two connectors, one for Salesforce and one for Slack.

It is in beta. That matters for how much you rely on it in a live forecast meeting.

## Who can use it

- The org needs access to a recent Sales Cloud Enterprise Edition.
- A Salesforce admin requests beta access through AgentExchange. Once approved, the admin gets an email with setup steps.
- On the Claude side, someone with Primary Owner or Owner rights has to finish the connection.
- Individual users then add the plugin and sign in with their own Salesforce login.

So there are two layers of setup: the admin connects the org, and each user connects their own account. Access in Claude follows each user's Salesforce permissions.

## Where it runs

At the time of the beta, it works in regular chat and in Claude Cowork, on web and desktop. Check the current Claude Help Center article before you promise anyone a specific surface.

## What it is not

It does not replace Salesforce reports or your forecast process. Think of it as a faster way to ask questions. If Claude gives a number you would not put in front of a manager, open the record and check it.

## Try it

Ask Claude which of your open opportunities closes this month and has no next step filled in. Then run the same check with a standard report. If the lists differ, figure out why before you trust either one.
