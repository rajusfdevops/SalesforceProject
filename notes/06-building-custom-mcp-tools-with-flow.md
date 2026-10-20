# 6. Building custom MCP tools with Flow for business-specific actions

## Why Flow first

Most business actions your org already has are in Flow: approvals, record updates, quote creation, a few callouts. Turning an existing Flow into a tool is usually the cheapest way to let an agent do one of those things. You do not write Apex, and the business rules stay in one place.

The trade-off is that a Flow is only as clear as its name and inputs. A model picks tools by reading their descriptions, so a Flow called "Subflow_v3_final" will be hard for it to use.

## Before you expose a Flow

Check these things first:

- **Name.** Use a verb and an object, such as "Create Renewal Quote" rather than "RQ Auto Create".
- **Inputs.** Each input should have a clear label and a description. Mark required inputs as required. Avoid inputs that only make sense inside the Flow, such as a helper variable.
- **Outputs.** Return the record ID and a short status message. The model needs something it can quote back to the user.
- **Side effects.** Note what the Flow changes. If it sends email or deletes data, do not expose it until you have a confirmation step.

## Steps

1. Pick a Flow that does one business task. Autolaunched flows are the usual choice for tool use.
2. Confirm it runs on its own with test inputs from Setup.
3. Add it to a custom hosted MCP server as a tool. Check that the tool description matches what the Flow does.
4. Connect a client and ask for the action in plain words. Confirm the Flow ran and the record changed.
5. Check the audit trail, so you know who or what triggered it.

## Example (illustrative)

A Flow called "Create Renewal Quote" takes an Account ID and a term in months. It builds a Quote from the current price book and returns the Quote ID.

Prompt: "Make a 12-month renewal quote for Bluebird Logistics."

What you should see: the agent asks for the Account ID if it cannot find one, calls the Flow, and returns the new Quote ID with a link. If it creates a quote for the wrong account because two names are similar, that points to the input description, not to the model.

## Common mistakes

- Exposing a Flow with a "Run as system" context. The tool then ignores the user's permissions. Check the Flow's run mode before you publish it.
- Assuming the Flow's error messages are useful. Make sure the Flow returns a clear error the model can read.
- Forgetting to test a second time. Flows that work once can fail on a second run because of duplicate checks.

## Try it

Choose one repeated task your team does by hand. Build the Flow, write a one-line tool description, and test it with three inputs: a normal case, a missing input, and an input that matches two records.
