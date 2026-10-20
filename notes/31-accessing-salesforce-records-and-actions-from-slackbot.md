# 31. Accessing Salesforce records and actions from Slackbot and Canvas

## Records and actions

Note 30 was about agents. This lesson covers the simpler case: Slackbot reads a record or runs a single action directly. A record lookup is a read. An action is a change, such as updating a status or creating a task.

Treat actions with more care than lookups. A lookup that goes wrong shows a wrong answer. An action that goes wrong changes data.

## Canvas

Canvas is where a Slack user can see a larger view of Salesforce content inside Slack. Check the current help article for what your workspace supports, since this area changes.

## Rules to set before you allow actions

- Start with reads only. Add actions one at a time, after each has been tested.
- Require a confirmation step for any change.
- Limit each action to the fields it needs.

## Example (illustrative)

A rep asks Slackbot to mark a task complete. Slackbot shows the task name and asks, "Mark this complete?" The rep confirms, and the task is updated. Without the confirmation step, a misread request would change the wrong task.

## Try it

Ask Slackbot to show one opportunity, then ask it to change one field on a sandbox record. Confirm the change appears in Salesforce and that Slackbot asked before making it.
