# HXL (Headless Experience Layer) Development Guide: Start to Advanced

**Project:** SalesforceProject (`AIforce_Proj`)
**Target org:** `AIforce_practice_1` (Enterprise, `lumenindiapvtltd2`)
**Example used:** Soft-drink orders, answered by the MCP server named **HXL**
**Status as of 2026-10-11:** Metadata deployed and verified in the org. The Agentforce agent is **not yet created**, because of a licence constraint described in section 9.

This guide covers the full path: setup, building widgets, Apex tools, MCP registration, testing, deployment, and the agent. It records what was tested, what could not be tested, and why. It is written so a trainer can walk through it.

---

## Contents

1. [Concepts](#1-concepts)
2. [Prerequisites and environment](#2-prerequisites-and-environment)
3. [Project layout](#3-project-layout)
4. [Step 1: Apex tools](#4-step-1-apex-tools)
5. [Step 2: Lightning types and renderers](#5-step-2-lightning-types-and-renderers)
6. [Step 3: Widgets](#6-step-3-widgets)
7. [Step 4: MCP server definition](#7-step-4-mcp-server-definition)
8. [Step 5: Testing](#8-step-5-testing)
9. [Step 6: Deployment](#9-step-6-deployment)
10. [Step 7: Users, permissions and the agent](#10-step-7-users-permissions-and-the-agent)
11. [Testing summary: what passed and what did not](#11-testing-summary-what-passed-and-what-did-not)
12. [Known issues and fixes](#12-known-issues-and-fixes)
13. [Advanced topics](#13-advanced-topics)
14. [Troubleshooting](#14-troubleshooting)
15. [Command reference](#15-command-reference)
16. [Glossary](#16-glossary)
17. [Training exercises](#17-training-exercises)
18. [Open items and cleanup](#18-open-items-and-cleanup)

---

## 1. Concepts

HXL lets you build a UI **once** as declarative JSON. The same widget renders in Agentforce, ChatGPT, Claude and Slackbot.

The chain for one question:

```
User question
  → Agent or MCP client picks a tool            (MCP server definition: descriptionOverride)
  → Apex @InvocableMethod runs                   (SoftDrinkOrderStatus / SoftDrinkOrdersByDrink)
  → Result envelope                              (Lightning type: *Result)
  → Output values                                (Lightning type: *OutputValues)
  → Renderer maps fields to widget attributes    (renderer.json)
  → Widget draws the card or list                (uiWidgets/<name>: layout JSON + schema.json)
```

HXL is a **beta** feature from API version 67.0. Use is governed by Salesforce beta terms.

Sources: [Get Started](https://developer.salesforce.com/docs/platform/hxl/guide/get-started.html), [Prerequisites](https://developer.salesforce.com/docs/platform/hxl/guide/prerequisites.html), [Build Rich UI](https://developer.salesforce.com/docs/platform/hxl/guide/hxl-rich-ui.html), [Widget mapping to MCP](https://developer.salesforce.com/docs/platform/hxl/guide/hxl-widget-example-mapping-mcp.html), [Headless Experience Layer](https://www.headlessexperiencelayer.com/).

---

## 2. Prerequisites and environment

| Item | Requirement | Status here |
|---|---|---|
| API version | 67.0 or later | Project `sourceApiVersion` 67.0; org 68.0 |
| HXL enabled | Setup → Headless Experience Layer Settings → toggle on | Metadata types exist in the org, so it is enabled |
| Salesforce CLI | `sf` with `project` commands | `@salesforce/cli/2.150.6` |
| Authorised org | `AIforce_practice_1` | Connected |
| Soft-drink data | `Soft_Drink__c`, `Soft_Drink_Order__c` in the target org | Present: 3 drinks (Mirinda, Coca Cola, Pepsi), 1 order (100, Pepsi, Open, qty 20, price 25) |
| MCP server | HXL registered in API Catalog, active | Registered (ID `1g1dN0000005T4bQAE`); active as of your last update |
| Agent licence | Einstein Agent permission set licence | `EinsteinAgentPsl`: 10 total, 1 used |
| Agent user licence | Einstein Agent **user** licence | **Not present** in this org (see section 10) |

### Windows CLI notes (important for training)

The Salesforce CLI launcher on this machine breaks on some arguments. Use these patterns:

- Works: `sf project deploy start …`, `sf agent validate …`, `sf agent publish …`, `sf apex run --file …`, `sf org list`, `sf agent mcp list/get …`, `sf api request rest "<url>" -o <alias>` (GET only).
- Fails with `'C:\Program' is not recognised`: `sf data query --query "…"` with spaces, `sf api request rest … -m POST`, `sf data create record`, `sf api request rest … -f <file>`, and any argument containing a space, such as a `--name` with spaces. Redirects such as `< /dev/null` also fail.
- Workaround for queries: build a URL with Python's `urllib.parse.quote`, then call `sf api request rest "/services/data/v68.0/query?q=<encoded>" -o <alias>`.
- Workaround for writes: anonymous Apex via `sf apex run --file <script.apex>`.
- `sf org display --json` redacts the access token, so `curl` against the REST API cannot authenticate.

---

## 3. Project layout

```
SalesforceProject/
├── force-app/main/default/
│   ├── classes/
│   │   ├── SoftDrinkOrderStatus.cls            Apex tool 1
│   │   ├── SoftDrinkOrderStatus.cls-meta.xml
│   │   ├── SoftDrinkOrdersByDrink.cls          Apex tool 2
│   │   ├── SoftDrinkOrdersByDrink.cls-meta.xml
│   │   ├── SoftDrinkOrderTest.cls              Apex tests (5)
│   │   └── SoftDrinkOrderTest.cls-meta.xml
│   ├── lightningTypes/
│   │   ├── orderStatusOutputValues/schema.json
│   │   ├── orderStatusResult/schema.json
│   │   ├── orderStatusResult/renderer.json
│   │   ├── drinkOrdersOutputValues/schema.json
│   │   ├── drinkOrdersResult/schema.json
│   │   └── drinkOrdersResult/renderer.json
│   ├── mcpServerDefinitions/
│   │   └── HXL.mcpServerDefinition-meta.xml    MCP server + tools
│   └── uiWidgets/
│       ├── orderStatusCard/   (.json, schema.json, .uiwidget-meta.xml)
│       └── drinkOrdersList/   (.json, schema.json, .uiwidget-meta.xml)
├── manifest/
│   └── hxl-package.xml                         Deployment manifest (10 members)
├── agent-drafts/
│   └── aiAuthoringBundles/SoftDrinkOrderAgent/ Agent Script draft (not deployed)
├── HXL reference folder materails/             Original reference copy (unchanged)
└── docs/
    ├── HXL-Headless-Experience-Layer-Training.md  Training guide
    └── HXL-Development-Guide.md                   This document
```

`HXL reference folder materails/` is the source the project was built from. It was **not** edited. All fixes live in `force-app/`.

---

## 4. Step 1: Apex tools

Each tool is an `@InvocableMethod`. The MCP server calls it.

### 4.1 `SoftDrinkOrderStatus`

- Input: `List<Integer> orderNumber`. Output: `OrderInfo { orderNumber, status }`.
- Single query, `LIMIT 1`, `WITH USER_MODE`.
- Returns `Not found` for an unknown order, a missing number, or an empty list.
- Status is formatted with an icon: Processed ✅, Dispatched 🚚, Cancelled ❌, Open 🕒.

Behaviour (verified):

| Input | Output `status` |
|---|---|
| `100` | `🕒 Open` |
| `999` | `Not found` |
| empty list | `Not found` |

### 4.2 `SoftDrinkOrdersByDrink`

- Input: `List<String> drinkName`, matched exactly against `Soft_Drink__c.Name`.
- Returns up to 10 orders, newest first, with display fields prepared in Apex:
  - `status` with icon, `statusColor` (`success`, `info`, `error`, `warning`, `secondary`), `price` as `$25.00`, `quantity` and `orderNumber` as text.
- `summaryLine`: `1 order found for Pepsi`, or `No orders yet for <name>` when zero.

Behaviour (verified):

| Input | Output |
|---|---|
| `Pepsi` | `summaryLine` = `1 order found for Pepsi`; row status `🕒 Open`, `statusColor` = `warning`, price `$25.00` |
| `Nope` | `summaryLine` = `No orders yet for Nope`, no rows |

**Teaching points**
- `WITH USER_MODE` applies the running user's permissions. This is why the agent user needs field access (section 10).
- `@InvocableVariable` marks the fields the MCP layer can see.
- Put display logic in Apex, so widgets only lay out text.

---

## 5. Step 2: Lightning types and renderers

Lightning types describe the shape of the output. Each tool has an **envelope** (`*Result`) and an **output values** type.

```
orderStatusResult                 (actionName, isSuccess, outputValues)
  └── orderStatusOutputValues     (orderNumber: number, status: text)

drinkOrdersResult                 (actionName, isSuccess, outputValues)
  └── drinkOrdersOutputValues     (drinkName, orderCount, summaryLine, orders[])
        └── @apexClassType c__SoftDrinkOrdersByDrink$OrderRow
```

Renderers connect a result to a widget:

```json
{
  "renderer": {
    "componentOverrides": {
      "$": {
        "definition": "@widget/c/orderStatusCard",
        "attributes": {
          "orderNumber": "{!$attrs.outputValues.orderNumber}",
          "status": "{!$attrs.outputValues.status}"
        }
      }
    }
  }
}
```

Rules (from the HXL docs and the deploy results):
- Renderer attribute keys must exist in the widget's `schema.json`.
- Use the `c` prefix for widgets and types: `@widget/c/<name>`, `c__<type>`.
- MCP output uses nested bindings: `{!$attrs.outputValues.field}`. Agentforce action output uses `{!$attrs.field}`.
- Keep the widget `schema.json` flat. Do not repeat the `outputValues` nesting in it.

---

## 6. Step 3: Widgets

Each widget is a folder with three files:

```
uiWidgets/<name>/
  <name>.json                 layout tree
  schema.json                 accepted attributes (the contract)
  <name>.uiwidget-meta.xml    label, description, widgetType JSON
```

### 6.1 Layout rules

- The root is `tile/widget`. Children are nested `definition` nodes with optional `attributes`, `children` and `meta`.
- `meta.forEach` repeats a node for each item. `{!$Item.field}` reads the current item.
- `{!$attrs.x}` reads a value passed in from the renderer.

### 6.2 Valid components

From the HXL reference (names exact):

`tile/widget`, `tile/column`, `tile/row`, `tile/container`, `tile/text`, `tile/badge`, `tile/separator`, `tile/spacer`, `tile/list`, `tile/listItem`, `tile/table`, `tile/button`, `tile/link`, `tile/icon`, `tile/image`, `tile/avatar`, `tile/callout`, `tile/code`, `tile/markdown`, `tile/progress`, `tile/spinner`, `tile/accordion`, `tile/accordionItem`.

**Not valid: `tile/card`.** The reference example used it, and the deployment failed with: *"Something's not right with the definition name tile/card."* The project uses `tile/container` instead.

### 6.3 Badge variants

Verified from the HXL badge reference: `error`, `info`, `outline`, `primary`, `secondary` (default), `success`, `warning`.

`default` is **not** valid. The project uses `secondary` for neutral statuses.

### 6.4 The two widgets

| Widget | Purpose | Key bindings |
|---|---|---|
| `orderStatusCard` | One order: number and status | `{!$attrs.orderNumber}`, `{!$attrs.status}` |
| `drinkOrdersList` | Summary line, then one container per order | `{!$attrs.summaryLine}`, `{!$attrs.orders}` with `forEach`; `{!$Item.orderNumber}`, `{!$Item.status}`, `{!$Item.statusColor}`, `{!$Item.quantity}`, `{!$Item.price}` |

The empty state is handled in Apex (`No orders yet for <drink>`). The widget has no conditional branch, because the docs I could reach don't describe one.

### 6.5 Widget schema example

```json
{
  "properties": {
    "attributes": {
      "lightning:type": "lightning__objectType",
      "properties": {
        "orderNumber": { "title": "Order Number", "lightning:type": "lightning__textType" },
        "status":      { "title": "Status",       "lightning:type": "lightning__textType" }
      }
    }
  }
}
```

---

## 7. Step 4: MCP server definition

`mcpServerDefinitions/HXL.mcpServerDefinition-meta.xml` registers the server.

| Element | Value |
|---|---|
| Server name | `HXL` (label "HXL", description "HXL Server") |
| Resources | `orderStatusWidget` → `ui://widget/lightningType/c__orderStatusResult`; `drinkOrdersWidget` → `ui://widget/lightningType/c__drinkOrdersResult` |
| Tool 1 | `SoftDrinkOrderStatus` → `aa:apex-SoftDrinkOrderStatus`, `uiResource` `orderStatusWidget`, `readOnly` true |
| Tool 2 | `SoftDrinkOrdersByDrink` → `aa:apex-SoftDrinkOrdersByDrink`, `uiResource` `drinkOrdersWidget`, `readOnly` true |

`descriptionOverride` tells the agent when to use each tool. Write it as the user would ask, with an example:
- Tool 1: "Return the status of a soft drink order when the user asks for it, for example "What is the status of my soft drink order 100?""
- Tool 2: "Return recent orders for a soft drink given its exact name, for example "show me all orders for Cola""

**Registration in API Catalog** (verified with `sf agent mcp list`):

| ID | Name | URL | Type |
|---|---|---|---|
| `1g1dN0000005T4bQAE` | HXL | `https://api.salesforce.com/platform/mcp/v1/custom/HXL` | PLATFORM |

`sf agent mcp fetch` does not work for custom servers (it only supports external MCP servers). Use `sf agent mcp get` to read the record. It returns the `active` flag, which is `true` as of your last update.

---

## 8. Step 5: Testing

Testing covers four layers. Each layer lists the evidence.

### 8.1 Apex unit tests (automated)

`SoftDrinkOrderTest` has five tests:

| Test | Checks |
|---|---|
| `statusReturnsFormattedStatusForExistingOrder` | Order 100 → `🕒 Open`, order number 100 |
| `statusReturnsNotFoundForUnknownOrder` | Order 999 → `Not found` |
| `statusHandlesMissingInput` | Empty list → `Not found`, null order number |
| `ordersForDrinkReturnsSummaryAndRows` | Pepsi → summary, `warning` badge, `$25.00` |
| `ordersForUnknownDrinkGivesFriendlyMessage` | Nope → `No orders yet for Nope`, no rows |

Result: **5 passing, 0 failing** (dry run and deploy).

Run it:

```bash
sf project deploy start --dry-run --manifest manifest/hxl-package.xml \
  --target-org AIforce_practice_1 --test-level RunSpecifiedTests --tests SoftDrinkOrderTest --wait 15
```

### 8.2 Anonymous Apex checks (live org, read-only)

Run against the org as the admin user:

```apex
System.debug('STATUS 100 -> ' + SoftDrinkOrderStatus.getStatus(new List<Integer>{100})[0].status);
System.debug('STATUS 999 -> ' + SoftDrinkOrderStatus.getStatus(new List<Integer>{999})[0].status);
System.debug('STATUS none -> ' + SoftDrinkOrderStatus.getStatus(new List<Integer>())[0].status);
SoftDrinkOrdersByDrink.Result p = SoftDrinkOrdersByDrink.getOrders(new List<String>{'Pepsi'})[0];
System.debug('PEPSI -> ' + p.summaryLine + ' | badge=' + p.orders[0].statusColor + ' | ' + p.orders[0].status);
SoftDrinkOrdersByDrink.Result n = SoftDrinkOrdersByDrink.getOrders(new List<String>{'Nope'})[0];
System.debug('NOPE -> ' + n.summaryLine);
```

Output (verified): `🕒 Open`, `Not found`, `Not found`, `1 order found for Pepsi | badge=warning | 🕒 Open`, `No orders yet for Nope`.

Note: the CLI shows `|` as `&#124;`. That is only escaping in the output.

### 8.3 Metadata validation (dry run)

Every deploy starts with a check-only run. It proves the metadata is valid for the org without changing it.

Evidence from this project:
- First run: 9 of 10 components passed. `drinkOrdersList` failed on `tile/card`.
- After the fix: 10 of 10 passed, and 5 of 5 tests passed.
- Final deploy: `Status: Succeeded`, 10 of 10 components, 5 of 5 tests.

### 8.4 Agent-level tests (not completed)

| Test | Result |
|---|---|
| Agent Script compiles | Passed with `flow://` targets and with `mcpTool://` targets |
| Agent publish with MCP tool targets | **Failed**: "The MCP action … has an invalid target ID value" |
| Agent preview (`sf agent preview`) with live actions | **Not run**: no published agent |
| Chat question "status of order 100" | **Not run**: no agent |
| Agent user can read the tools' data | **Not verified**: `System.runAs` works only in test methods |

### 8.5 Test-data reference

| Record | Value |
|---|---|
| Soft drink | Pepsi (`a05dN00000EJncrQAD`) |
| Order | 100, Pepsi, Open, quantity 20, price 25 |
| Other drinks | Mirinda, Coca Cola (no orders) |

**Do not** create more orders in the practice org without agreement, because they change the shared data.

---

## 9. Step 6: Deployment

### 9.1 Manifest

`manifest/hxl-package.xml` (API 67.0):

| Type | Members |
|---|---|
| `ApexClass` | `SoftDrinkOrderStatus`, `SoftDrinkOrdersByDrink`, `SoftDrinkOrderTest` |
| `UiWidgetBundle` | `drinkOrdersList`, `orderStatusCard` |
| `LightningTypeBundle` | `drinkOrdersOutputValues`, `drinkOrdersResult`, `orderStatusOutputValues`, `orderStatusResult` |
| `McpServerDefinition` | `HXL` |

### 9.2 Deploy sequence used

```bash
# 1. Check only
sf project deploy start --dry-run --manifest manifest/hxl-package.xml --target-org AIforce_practice_1 --wait 15

# 2. Check with tests
sf project deploy start --dry-run --manifest manifest/hxl-package.xml --target-org AIforce_practice_1 \
  --test-level RunSpecifiedTests --tests SoftDrinkOrderTest --wait 15

# 3. Deploy (after approval)
sf project deploy start --manifest manifest/hxl-package.xml --target-org AIforce_practice_1 \
  --test-level RunSpecifiedTests --tests SoftDrinkOrderTest --wait 15
```

Deploy results:

| Deploy | Result |
|---|---|
| First (initial copy) | Succeeded, 9 of 9 (no tests) |
| Dry run after the `tile/container` fix | Succeeded (all components validated) |
| Fixes deploy (status code, MCP settings, tests) | Succeeded, 10 of 10, 5 of 5 tests |

### 9.3 Rollback

Metadata is not deleted by a failed deploy. To remove the HXL metadata, use a `destructiveChanges.xml` listing the same members, deployed with a manifest of the same version. Delete the agent before the MCP server, and the MCP server before the widgets and Lightning types.

---

## 10. Step 7: Users, permissions and the agent

### 10.1 Agent user

| Item | Value |
|---|---|
| Username | `softdrink.agent@example.com` |
| Record ID | `005dN00000ELmeLQAT` |
| Profile | Standard User (user licence: Salesforce) |
| Permission sets | `EinsteinAgent` (uses `EinsteinAgentPsl`), `AgentPlatformBuilder` (uses `AgentPlatformBuilderPsl`), `Soft_Drink_Agent_Access` |

Created by anonymous Apex, after your approval. The Standard User profile is a stand-in, because the org has no Einstein Agent User licence.

### 10.2 `Soft_Drink_Agent_Access` permission set

| Area | Granted |
|---|---|
| Object settings | Read and View All on `Soft_Drink_Order__c` and `Soft_Drink__c` |
| Apex class access | `SoftDrinkOrderStatus`, `SoftDrinkOrdersByDrink` (2 entries, verified) |
| Field access on `Soft_Drink_Order__c` | `Order_Number__c`, `Status__c`, `Price__c`, `Quantity__c` (verified) |
| Field access on `Soft_Drink__c` | Extra fields (not needed for the tools) |

Field permissions are required because the Apex runs `WITH USER_MODE`. Without them, the query fails for the agent user even though the admin can run it.

### 10.3 Agent Script draft

Location: `agent-drafts/aiAuthoringBundles/SoftDrinkOrderAgent/SoftDrinkOrderAgent.agent`

Key facts learned from the compiler:

| Compiler message | Fix |
|---|---|
| `'actions' is only allowed for GoalBasedAgent` | Put `actions:` inside the subagent, not at top level |
| `'start_agent' is not allowed in a GoalBasedAgent script` | Use `agent_type` not set (default `AgentforceServiceAgent`) |
| `'default_agent_user' is required for AgentforceServiceAgent` | Add an `access:` block with `default_agent_user` |
| `'number' is not a defined value` (in inputs) | Use `string` for action inputs and outputs |
| `agentType must be either "customer" or "internal"` (spec route) | Use `customer` in the spec file |
| `Unrecognized field "actions"` (spec route) | The spec format does not accept actions |

Publish result (verified, repeated after the server was activated):

```
Validation failed for action(s) 'SoftDrinkOrderStatus' … The MCP action 'HXL/<name>' has an invalid target ID value.
```

Tested target IDs, all rejected: `HXL/SoftDrinkOrderStatus`, `HXL/SoftDrinkOrderStatusapex_SoftDrinkOrderStatus`, `HXL/aa:apex-SoftDrinkOrderStatus`.

The probable cause is that the platform issues target IDs for MCP tools when they are added in **Agent Builder**. Typing them is not reliable.

### 10.4 Agent Builder

Attempted by you. Results:

| Attempt | Error |
|---|---|
| Create agent, agent user = admin or other existing user | "We couldn't assign the agent user. Check to see if you reached the user limit for your org or select a different existing user and try again." |

Findings from Setup (screenshot and queries):
- User licences: no Einstein or Agentforce user licence. Salesforce has 10 of 15 remaining.
- Permission set licences: `EinsteinAgentPsl` (10 total, 1 used) and `AgentPlatformBuilderPsl` (10,000 total, 0 used) exist.
- The agent user already has `AgentPlatformBuilder` (duplicate-assignment error on the attempted re-assignment).

The builder message is therefore not explained by seats. The root cause is still unconfirmed. The likely cause is that the builder requires an Einstein Agent **user** licence, which this org does not have.

---

## 11. Testing summary: what passed and what did not

| Area | Test | Result | Evidence |
|---|---|---|---|
| Apex logic | Unit tests (5) | Passed | Deploy with RunSpecifiedTests |
| Apex behaviour | Anonymous Apex (admin) | Passed | Output in section 8.2 |
| Metadata | Dry-run validation | Passed (after fixing `tile/card`) | 10 of 10 |
| Deployment | Deploy to practice org | Succeeded | 10 of 10, 5 of 5 tests |
| MCP registration | `sf agent mcp list/get` | Registered, active | `active: true` |
| Agent Script | Compile | Passed | `Status: COMPLETED`, 0 errors |
| Agent publish | Tool target IDs | **Failed** | Invalid target ID |
| Agent user | Creation and permission sets | Done | Section 10.1 |
| Field access | Permission set | Done | Section 10.2 |
| Agent Builder | Create agent | **Failed** | Agent-user assignment error |
| Chat / preview | Order 100 question | **Not run** | No agent |
| Agent user runtime | Tools run as agent user | **Not verified** | `runAs` unavailable outside tests |
| Widget rendering | Cards in chat | **Not verified** | No agent |

**Why the chat tests could not run:** the agent cannot be saved, because the agent user cannot be assigned in Agent Builder. The org lacks the Einstein Agent User licence.

---

## 12. Known issues and fixes

| # | Area | Issue | Fix | Status |
|---|---|---|---|---|
| 1 | Widget | `tile/card` is not a valid component | Use `tile/container` | Fixed, deployed |
| 2 | Apex | Unknown order number threw `System.QueryException` | Returns `Not found` | Fixed, tested |
| 3 | Apex | Status shown without icon in the single-order tool | Same icon formatting as the drink list | Fixed, tested |
| 4 | MCP | Both tools had `readOnly` false | Set to `true` | Fixed, deployed. Behaviour in chat not yet checked |
| 5 | Apex | Zero orders gave "0 orders found" | Message reads `No orders yet for <drink>` | Fixed, tested |
| 6 | Apex | `statusColor` `default` is not a badge variant | Changed to `secondary` | Fixed, tested |
| 7 | MCP | Typo in `descriptionOverride` | Reworded with an example | Fixed, deployed |
| 8 | Agent | Publish rejects MCP target IDs | Create the agent in Agent Builder, then check the saved target | **Open** |
| 9 | Agent user | No Einstein Agent User licence | Enable the licence in Setup | **Open** (licence) |
| 10 | Widget | No empty-state branch in the layout | Handled in Apex | Accepted |

---

## 13. Advanced topics

### 13.1 Adding a new MCP tool

1. Write an Apex class with `@InvocableMethod`, `@InvocableVariable` fields and `WITH USER_MODE` queries.
2. Write a test class with at least one positive and one negative test. Use `@TestSetup` for data.
3. Add `lightningTypes/<name>OutputValues/schema.json`, and an envelope `<name>Result/schema.json` plus `renderer.json`.
4. Add `uiWidgets/<name>/` with the layout JSON, `schema.json` and `.uiwidget-meta.xml`. Use only the components in section 6.2.
5. Add a `resources` entry and a `tools` entry to `HXL.mcpServerDefinition-meta.xml`.
6. Add the new members to `manifest/hxl-package.xml`.
7. Run the dry run with `RunSpecifiedTests`, then deploy.
8. Grant the agent user class and field access in its permission set.

### 13.2 Channel reuse

The same widget renders in Agentforce, ChatGPT, Claude and Slackbot. Test each channel separately, because each has its own MCP client. Check the layout in each one.

### 13.3 Packaging and deployment across orgs

- Keep metadata in source control, and deploy by manifest, not by whole-folder copy.
- Keep the agent draft outside `force-app`, until it is published. Otherwise a full-source deploy can fail on it.
- Use a sandbox before production. Do not run anonymous Apex that inserts data in shared orgs.

### 13.4 Performance and limits

- Apex queries are capped at 10 rows (`LIMIT :MAX_ORDERS`). Keep the cap, so widgets stay small.
- Keep summary strings short. Widgets lay them out in one text line.

### 13.5 Security

- `without sharing` on the tool classes means record sharing is bypassed. `WITH USER_MODE` restores object and field checks. Keep both, and test with the agent user.
- Never put credentials or tokens in metadata or documentation. The CLI redacts tokens by design.

### 13.6 Governance

- Record each change in this guide with the date, the change, and the test that proves it.
- Re-run the dry run before every deploy, and keep the test results with the change.

---

## 14. Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `Something's not right with the definition name tile/card` | Invalid component | Use a name from section 6.2 |
| Deploy fails on a renderer | Attribute in `renderer.json` missing from `schema.json` | Make the two match |
| Widget renders blank fields | Wrong binding path | Use `outputValues.` for MCP output |
| Query fails for the agent user but works for admin | Missing object or field access | Check `Soft_Drink_Agent_Access` field permissions |
| `System.QueryException` for an order number | Old version of `SoftDrinkOrderStatus` | Redeploy the current class |
| Publish: "invalid target ID value" | Tool target not issued by the platform | Add the tools in Agent Builder |
| Agent Builder: "couldn't assign the agent user" | No Einstein Agent User licence | Enable the licence (Setup) |
| `'C:\Program' is not recognised` | CLI launcher and spaces in arguments | Use the workarounds in section 2 |
| `sf org display` shows `[REDACTED]` for the token | CLI redaction | Use `sf api request rest` (GET) or Apex |

---

## 15. Command reference

| Purpose | Command |
|---|---|
| List orgs | `sf org list` |
| Dry run with tests | `sf project deploy start --dry-run --manifest manifest/hxl-package.xml --target-org AIforce_practice_1 --test-level RunSpecifiedTests --tests SoftDrinkOrderTest --wait 15` |
| Deploy | `sf project deploy start --manifest manifest/hxl-package.xml --target-org AIforce_practice_1 --test-level RunSpecifiedTests --tests SoftDrinkOrderTest --wait 15` |
| Run anonymous Apex | `sf apex run --file <file>.apex --target-org AIforce_practice_1` |
| Read-only REST query | `sf api request rest "/services/data/v68.0/query?q=<url-encoded SOQL>" -o AIforce_practice_1` |
| Tooling query | `sf api request rest "/services/data/v68.0/tooling/query?q=<encoded>" -o AIforce_practice_1` |
| List MCP servers | `sf agent mcp list -o AIforce_practice_1` |
| Get MCP server | `sf agent mcp get -o AIforce_practice_1 -i 1g1dN0000005T4bQAE --json` |
| Validate agent | `sf agent validate authoring-bundle -n SoftDrinkOrderAgent -o AIforce_practice_1` |
| Publish agent | `sf agent publish authoring-bundle -n SoftDrinkOrderAgent -o AIforce_practice_1` |
| Preview agent (after publish) | `sf agent preview -n <AgentApiName> -o AIforce_practice_1 --use-live-actions` |

---

## 16. Glossary

| Term | Meaning |
|---|---|
| HXL | Headless Experience Layer. Build a UI once; render in many channels |
| Widget | Declarative UI defined as JSON, under `uiWidgets/` |
| Widget bundle | Folder holding the layout, schema and meta XML |
| Composition | The layout JSON (`tile/…` tree) |
| Schema | The attributes a widget accepts |
| Renderer | `renderer.json`. Connects a Lightning type to a widget |
| Lightning type | A typed description of data, under `lightningTypes/` |
| MCP | Model Context Protocol. How an agent calls tools |
| MCP server definition | Metadata that registers the server, tools and resources |
| API Catalog | Salesforce registry of MCP servers and their tools |
| Invocable method | Apex method marked `@InvocableMethod` |
| `WITH USER_MODE` | Query clause that enforces the running user's permissions |
| Agent Script | Text language for authoring agents, in an authoring bundle |
| Authoring bundle | Folder with the `.agent` file and its meta XML |
| Permission set licence (PSL) | Licence that gates a permission set |
| Einstein Agent User licence | User licence an agent user normally needs. Not present in this org |

---

## 17. Training exercises

1. **Read a card.** Open `orderStatusCard.json` and list each node from root to leaf with its `definition`.
2. **Trace a question.** Follow "status of order 100" through each file in section 1, in order.
3. **Explain the not-found fix.** Read `SoftDrinkOrderStatus.cls` and `statusReturnsNotFoundForUnknownOrder`. Explain why the list query is safer than a single-row query.
4. **Explain the empty state.** Find where `No orders yet` is produced, and say why it is in Apex.
5. **Break it.** Put `tile/card` back in `drinkOrdersList.json`, run the dry run, and read the error.
6. **Permissions.** Remove one field grant on `Soft_Drink_Agent_Access` and explain what the agent would see.
7. **Add a field.** Add `Quantity` to `orderStatusCard`. Update the Apex output, `orderStatusOutputValues`, the renderer and the widget schema, in that order. Then run the dry run.

---

## 18. Open items and cleanup

### 18.1 Open items

| # | Item | Owner | Next step |
|---|---|---|---|
| 1 | Einstein Agent User licence for the org | Salesforce admin | Enable in Setup, or confirm it is unavailable |
| 2 | Create the agent in Agent Builder | You (or admin with licence) | Add the two HXL actions; agent user `softdrink.agent@example.com` |
| 3 | Confirm MCP tool target IDs | Me, after step 2 | Check the saved agent's targets, then publish |
| 4 | Test order 100 and Pepsi in chat | You | Use the test questions in section 11 of `docs/HXL-Headless-Experience-Layer-Training.md` |
| 5 | Decide on the known-issue status of agent-user licence | Team | Record the decision |

### 18.2 Cleanup

| Item | Status |
|---|---|
| `hxl-build-ui/` (humanitarian hashtag builder) | Deleted, as requested |
| `force-app/main/default/lwc/hxlTagBuilder/` | Deleted, as requested |
| `agent-drafts/aiAuthoringBundles/SoftDrinkOrderAgent/` | Kept outside `force-app`, unpublished |
| Root `node_modules/` and `package-lock.json` | Added by the Jest install; can be removed if not needed |
| `HXL reference folder materails/` | Unchanged |
| Test user `softdrink.agent@example.com` | Active; keep for testing, or deactivate after the test |

### 18.3 Sign-off checklist

- [x] Apex classes and tests deployed and passing
- [x] Widgets, Lightning types and MCP server deployed
- [x] MCP server registered and active
- [x] Agent user created, with permission sets
- [x] Field and class access for the tools
- [ ] Agent created and published
- [ ] Chat test of order 100 passed
- [ ] Chat test of Pepsi passed
- [ ] Einstein Agent User licence confirmed
