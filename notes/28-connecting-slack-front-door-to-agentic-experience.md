# 28. Connecting Slack: the front door of an agentic experience to Salesforce

## Slack as the entry point

In this section, Slack is where people ask questions. Slackbot receives the request, reaches Salesforce through MCP, and returns the answer in the thread. The user never opens Salesforce. That is why it is called a front door: Slack is the way in, and Salesforce does the work behind it.

## What changes for the user

- Questions happen where the team already talks.
- Answers can point back to a record, so the user can open it if needed.
- Anyone who can see the Slack conversation can see the answer, so think about what you expose.

## Two directions

Slackbot can call Salesforce tools, and Salesforce agents can be reached from Slack. Know which one you are setting up, because the steps and the permissions differ.

## Points to check first

- The Slack workspace and the Salesforce org are both set up, as covered in note 27.
- The user asking the question has a Salesforce account with the access they need.
- The tools Slackbot will use have been tested outside Slack first.

## Example (illustrative)

A sales rep asks Slackbot in a DM, "What is the next step on the Northwind deal?" Slackbot calls the opportunity lookup tool as that rep, gets the next step field, and replies in the same thread. If the field is empty, the reply says so, rather than inventing a step.

## Try it

Ask Slackbot the same question from two Slack accounts, one with access to the record and one without. Write down what each sees.
