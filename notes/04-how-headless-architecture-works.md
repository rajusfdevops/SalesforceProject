# 4. How Salesforce headless architecture works

## Plain definition

"Headless" means the back end works without a fixed front end. The logic and data stay in Salesforce. The screen is one of several ways to reach them, and not necessarily the main one.

A useful comparison is a restaurant kitchen. The kitchen makes the food whether the order comes from the dining room, a delivery app, or a phone call. Lightning pages are the dining room. Headless 360 adds the other order channels.

## What changes

- Before: most work started in a Lightning page, and custom logic was often tied to that page.
- After: the same logic can be called from an API, an MCP tool, a CLI command, or an agent.

Salesforce is clear that Lightning is not going away. Headless adds routes, it does not remove the front end.

## A request, step by step

Say an external app wants to create a Case when a customer submits a form on a website.

1. The website sends a request to a Salesforce endpoint, with an OAuth token for an integration user.
2. Salesforce checks that the integration user can create Cases.
3. The Case is created, and any Flow or validation rule on Case runs exactly as it would from the UI.
4. The response returns the new record ID.

Nothing special happened in step 3. That is the point. If you have business rules in Flows and triggers, they still apply, which is good for consistency and bad if you forget they exist.

## Things to watch

- **Integration users.** Give them the smallest set of permissions that works. A headless integration with System Administrator rights is a common and serious mistake.
- **Rate and volume.** Agents can call tools many times in a loop. Check API limits before you go live.
- **Order of operations.** A UI user and an API caller both trigger the same automation. Test both.

## Example (illustrative)

A support team had a Flow that set Case priority from the account tier. A new web form created Cases through the API and the Flow ran, so priority was set correctly. A second team wrote their own Apex trigger for the same field, and the two overwrote each other depending on the order of execution. The fix was to keep one owner for that field. The lesson is that headless makes shared logic more visible, not less.

## Try it

Pick one action your team does in the UI, such as converting a Lead. Find every place its logic lives: Flows, triggers, validation rules, and page layouts. Write down which of them would still run if the same action came through an API call.
