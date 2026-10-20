# 3. Understanding Salesforce agentic enterprise architecture

## The short version

Salesforce is trying to make its platform something agents can use directly, not only something people click through. Headless 360, announced in April 2026, is the umbrella for that. The "agentic enterprise" is the picture of a company where agents do routine work across several systems, and people set the rules and handle the exceptions.

## Layers, as Salesforce describes them

Think of it as a stack. Each layer does one job.

1. **Data layer.** Where the customer data lives and gets unified. Salesforce points to Data 360, and MuleSoft and Informatica handle moving data in from outside systems.
2. **Capability layer.** The business logic: objects, Flows, Apex, and actions. Headless 360 exposes these as APIs, MCP tools, or CLI commands.
3. **Agent layer.** The agents themselves, including Agentforce agents and agents built on other platforms.
4. **Governance layer.** Agent Fabric is Salesforce's name for the control point that tracks which agent did what, across vendors.

Some of these pieces are mature and some are still new. Before you design around a layer, check its release status in the current docs.

## Why the layers matter for you

When a project goes wrong, it is usually in one layer but gets blamed on another. A few examples:

- An agent gives a wrong answer. The cause is often the data layer, such as duplicate accounts or stale fields, not the model.
- An agent cannot update a record. The cause is often the capability layer, such as a Flow that is not exposed as a tool.
- Two agents conflict. The governance layer should show you this, but only if logging is turned on.

## Example (illustrative)

A renewal process with three steps:

1. A scheduled agent finds contracts ending in 90 days (data layer plus a query tool).
2. It drafts a renewal quote by calling a Flow exposed as a tool (capability layer).
3. A person approves the quote before it goes out (governance: approval step and audit log).

The agent does steps 1 and 2. The human owns step 3. That split is the design, not a limitation to be removed later.

## Caveat

Existing orgs with years of custom code and loose permissions will not become agentic by switching on new features. Clean up the data and the permissions first, or the agents will reproduce the mess faster.

## Try it

Draw the three layers for one process you know well. Mark which layer each step lives in. Any step you cannot place is a gap to investigate.
