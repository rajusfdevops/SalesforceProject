# Advanced Custom Headless Salesforce Experience: Student Handout

**Path:** Salesforce screen → API → MCP tool → AI experience
**Duration:** 120 minutes
**Who this is for:** Salesforce developers and admins who have done basic Apex and metadata work

---

## What you will learn

By the end of the session you should be able to:

- Explain what "headless Salesforce" means and why it matters
- Explain why standard MCP tools are sometimes not enough
- Choose between a Named Query, a Flow, an Apex REST service, and an Agent for a given request
- Expose Salesforce capabilities as MCP tools
- Describe how Claude or ChatGPT can use Salesforce business logic
- Build a simple customer view from several Salesforce sources

---

## Before you start

You need:

- Access to the practice org (`AIforce_practice_1`), with the permissions your instructor gives you
- The project folder, with the `docs/` folder open
- The Salesforce CLI, if your instructor asks you to run commands

**Sample data in the org:**

| Order | Drink | Account | Status |
|---|---|---|---|
| 100 | Pepsi | Back Country Outpost (Sample) | Open |
| 101 | Coca Cola | National Parks Gear (Sample) | Processed |
| 102 | Mirinda | Back Country Outpost (Sample) | Dispatched |
| 103 | Pepsi | National Parks Gear (Sample) | Cancelled |
| 104 | Coca Cola | River Mountain Outfitters (Sample) | Open |

Accounts: Back Country Outpost (Sample), National Parks Gear (Sample), River Mountain Outfitters (Sample), plus others.

---

## Session plan

| Time | Part | Activity | Type |
|---|---|---|---|
| 0:00–0:15 | 1 | What is headless Salesforce? | Discussion |
| 0:15–0:35 | 2 | HXL widgets: build the card | Hands-on |
| 0:35–0:55 | 3 | Apex tools and tests | Hands-on |
| 0:55–1:10 | 4 | Named Query | Demo (verify first) |
| 1:10–1:30 | 5 | REST API and OpenAPI | Demo |
| 1:30–1:50 | 6 | Agent as a tool | Walkthrough (live if actions are attached) |
| 1:50–2:00 | 7 | Choosing the right tool | Exercise and close |

---

## Part 1: What is headless Salesforce? (15 min)

### Theory

Most users reach Salesforce through the UI: Lightning pages, tabs, related lists, reports, and dashboards.

```
User → Salesforce UI → Business logic → Database
```

Headless Salesforce exposes the same capabilities without the UI, so other tools can use them:

```
Claude / ChatGPT / Cursor / Copilot / Slack
   → MCP tool
   → Named Query, Flow, REST API, or Agent
   → Salesforce
```

### Discussion

Ask: *"Someone asks Claude, 'What is the status of order 100?' What does Salesforce need to answer?"*

Expected answer: a query for the order, its status, and some formatting. No screen is needed.

### Key idea

The customer does not ask for an object. They ask for a **customer view**: the account, its orders, its open issues, and its totals. That is what headless design exposes.

---

## Part 2: HXL widgets (20 min)

HXL lets you design a card or list once. It then renders in Agentforce, ChatGPT, Claude, and Slackbot.

### Steps

1. Open the project folder `force-app/main/default/uiWidgets/`.
2. Open `orderStatusCard/orderStatusCard.json`. Find the root node (`tile/widget`) and list each child node with its `definition`.
3. Open `orderStatusCard/schema.json`. Find the attributes the widget accepts (`orderNumber`, `status`).
4. Open `lightningTypes/orderStatusResult/renderer.json`. Find the line that maps `{!$attrs.outputValues.status}` to the widget's `status` attribute.
5. **Dry run the deploy** (your instructor will run this live if time is short):

   ```bash
   sf project deploy start --dry-run --manifest manifest/hxl-package.xml --target-org AIforce_practice_1 --wait 15
   ```

   Expected result: all components validated.

6. **Break it on purpose.** In `drinkOrdersList.json`, change `tile/container` to `tile/card`. Run the dry run again.
   - Expected error: *"Something's not right with the definition name tile/card."*
   - Change it back.

### What to take away

- Only use the component names listed in the HXL reference.
- Badge variants must be real values. `secondary` is valid. `default` is not.

---

## Part 3: Apex tools and tests (20 min)

The widgets need data. Apex tools provide it.

### Steps

1. Open `force-app/main/default/classes/SoftDrinkOrderStatus.cls`.
   - Find `@InvocableMethod`. It makes the method callable by the MCP server.
   - Find `WITH USER_MODE`. Explain: this applies the running user's permissions.
   - Find the `Not found` path. Explain: a list query is safer than a single-row query.
2. Open `SoftDrinkOrdersByDrink.cls`. Find the `summaryLine` logic and the `No orders yet` message. Explain why the message is built in Apex, not in the widget.
3. Open `SoftDrinkOrderTest.cls`. Read the five test methods.
4. Run the tests with the deploy dry run:

   ```bash
   sf project deploy start --dry-run --manifest manifest/hxl-package.xml --target-org AIforce_practice_1 --test-level RunSpecifiedTests --tests SoftDrinkOrderTest --wait 15
   ```

   Expected result: 5 passing.

5. Your instructor runs a read-only check with anonymous Apex. Expected output:

   | Input | Output |
   |---|---|
   | Order 100 | `🕒 Open` |
   | Order 999 | `Not found` |
   | Empty list | `Not found` |
   | Pepsi | `2 orders found for Pepsi` |
   | Nope | `No orders yet for Nope` |

### Discussion

Why should a permission set grant read on the order fields? Because `WITH USER_MODE` checks them. An admin can see fields that a standard user cannot.

---

## Part 4: Named Query (15 min, demo)

### Why it exists

If all you need is data retrieval, you should not have to write an Apex REST class. A Named Query exposes a saved SOQL query as an API.

### Demo steps (instructor)

1. In Setup, confirm that the Named Query API is enabled. *(Check this before class. If it is not enabled, skip this part.)*
2. Create a Named Query called `OrdersByAccount` that returns orders for an account.
3. Add a bind variable for the account name, for example `:accountName`.
4. Validate the query, then activate it in the API Catalog.
5. Add it to an MCP server as a tool.
6. Ask: *"What soft-drink orders does Back Country Outpost have?"*

### Discussion

- Named Query is fastest for read-only retrieval.
- Use bind variables so the same query serves many customers.
- It has no business logic, so totals and rules need a different tool.

---

## Part 5: REST API and OpenAPI (20 min, demo)

### When to use it

When business logic is needed, such as totals, risk scores, or several objects combined, use an Apex REST service.

### Why OpenAPI matters

An OpenAPI file describes the endpoint: its inputs, outputs, and schema. Without it, an AI client cannot know how to call the service. Think of it as the API's resume.

### Demo steps (instructor)

1. Show a small Apex REST class, with `@RestResource`, a GET method, and a wrapper class for the response.
2. Show an example OpenAPI YAML for the same endpoint.
3. Discuss how the file could be generated: from a Salesforce extension, from Swagger, or with an AI prompt.
4. Compare the response to the Named Query result: the REST response can include totals and derived fields.

*There is no live REST endpoint in this org. Treat this part as a walkthrough.*

---

## Part 6: Agent as a tool (20 min, walkthrough)

### The idea

An Agentforce agent has instructions, actions, and reasoning. Exposed through MCP, it lets Claude use all of that together.

```
Claude → MCP tool → Agentforce agent → Actions → Salesforce
```

### Walkthrough

1. Open the agent **Soft Drink Agent** in Agent Builder.
2. Show the **Actions** on its subagent. Expected: `SoftDrinkOrderStatus` and `SoftDrinkOrdersByDrink`, from the HXL MCP server.
3. Show the **Agent user**, and explain why it needs permissions.
4. Ask a question in preview: *"What is the status of order 100?"*
   - If the actions are attached and the agent is active, the answer should be "🕒 Open".
   - If not, the instructor explains the setup gap and shows the expected answer.

*Note: the agent can only answer once its actions are attached. The org's Einstein Agent User licence may limit this.*

### Discussion

- A Flow exposes one automation.
- A REST service exposes one business service.
- An Agent exposes a complete experience, because it bundles instructions, actions, and reasoning.

---

## Part 7: Choosing the right tool (10 min)

For each request, choose the tool and say why:

| Request | Best tool | Why |
|---|---|---|
| "List all orders for Back Country Outpost" | Named Query | Read-only, reusable |
| "Give me this account's total spend and risk score" | Apex REST | Business logic needed |
| "Create a follow-up task for an open order" | Flow or Invocable Apex | Changes data |
| "Explain this customer's situation and next steps" | Agent | Needs reasoning and several actions |

### Closing message

"Headless Salesforce is not about exposing data. It is about exposing Salesforce capabilities. A Named Query exposes data, a Flow exposes automation, a REST API exposes business services, and an Agent exposes a complete experience. Through MCP, all of these reach Claude, ChatGPT, Cursor, Copilot, or any AI client."

---

## Reference

| Item | Location |
|---|---|
| Widgets | `force-app/main/default/uiWidgets/` |
| Lightning types | `force-app/main/default/lightningTypes/` |
| Apex tools and tests | `force-app/main/default/classes/` |
| MCP server | `force-app/main/default/mcpServerDefinitions/HXL.mcpServerDefinition-meta.xml` |
| Deploy manifest | `manifest/hxl-package.xml` |
| Trainer's full guide | `docs/HXL-Development-Guide.md` |
| Training guide | `docs/HXL-Headless-Experience-Layer-Training.md` |

## Known limits

- The org has no `Customer__c` object, so the demo uses soft-drink orders and the sample accounts.
- The agent user needs a licence the org may not have, so the agent part may be a walkthrough.
- Named Query and REST API parts are demos. Confirm them before class.
