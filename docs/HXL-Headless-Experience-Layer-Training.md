# HXL (Headless Experience Layer): End-to-End Training Guide

HXL is Salesforce's Headless Experience Layer. You build a UI **once** as declarative JSON, and it renders in Agentforce, ChatGPT, Claude and Slackbot. This guide uses a working example: soft-drink orders, answered by an MCP server named **HXL**.

**Audience:** Salesforce developers. Basic Apex and metadata knowledge is enough.
**Time:** about 90 minutes, or 45 minutes without the exercises.
**Status:** HXL is a beta feature, available from API version 67.0. Use is governed by Salesforce's beta terms.

---

## Contents

1. [What HXL is](#1-what-hxl-is)
2. [The example in this project](#2-the-example-in-this-project)
3. [How a question becomes a card](#3-how-a-question-becomes-a-card)
4. [Step 1: Apex tools](#4-step-1-apex-tools)
5. [Step 2: MCP server definition](#5-step-2-mcp-server-definition)
6. [Step 3: Lightning types](#6-step-3-lightning-types)
7. [Step 4: Widgets](#7-step-4-widgets)
8. [Binding syntax](#8-binding-syntax)
9. [Tile components reference](#9-tile-components-reference)
10. [Set up and deploy](#10-set-up-and-deploy)
11. [Test in chat](#11-test-in-chat)
12. [Adding a new tool](#12-adding-a-new-tool)
13. [Known issues](#13-known-issues)
14. [Troubleshooting](#14-troubleshooting)
15. [Glossary](#15-glossary)
16. [Exercises](#16-exercises)

---

## 1. What HXL is

| Idea | Meaning |
|---|---|
| **Build once** | One widget definition renders in every supported channel |
| **Declarative** | A widget is JSON, not a web app. No JavaScript, LWC or build step |
| **Typed** | A schema describes the data a widget accepts, so errors appear at deploy time |
| **Bound to data** | `{!$attrs.x}` expressions fill the widget from tool output |

Sources: [Get Started](https://developer.salesforce.com/docs/platform/hxl/guide/get-started.html), [Prerequisites](https://developer.salesforce.com/docs/platform/hxl/guide/prerequisites.html), [Build Rich UI](https://developer.salesforce.com/docs/platform/hxl/guide/hxl-rich-ui.html), [HXL overview](https://www.headlessexperiencelayer.com/).

---

## 2. The example in this project

The soft-drink example is in the Salesforce project under `force-app/main/default/`.

| Folder | Files | Purpose |
|---|---|---|
| `classes/` | `SoftDrinkOrderStatus.cls`, `SoftDrinkOrdersByDrink.cls` (+ `-meta.xml`) | Apex tools the MCP server calls |
| `mcpServerDefinitions/` | `HXL.mcpServerDefinition-meta.xml` | Registers the server and its two tools |
| `lightningTypes/` | `orderStatusResult`, `orderStatusOutputValues`, `drinkOrdersResult`, `drinkOrdersOutputValues` | Output shapes, plus renderers that connect them to widgets |
| `uiWidgets/` | `orderStatusCard`, `drinkOrdersList` | The two widgets |

The manifest for deployment is `manifest/hxl-package.xml`.

The org data this example uses (read-only check on the practice org):

| Object | Records |
|---|---|
| `Soft_Drink__c` | Mirinda, Coca Cola, Pepsi |
| `Soft_Drink_Order__c` | One order: number **100**, Pepsi, status **Open**, quantity 20, price 25 |

---

## 3. How a question becomes a card

```
"What is the status of order 100?"
        │
        ▼
Agent matches the question to a tool  (descriptionOverride in the MCP definition)
        │
        ▼
Apex invocable method runs            SoftDrinkOrderStatus.getStatus(orderNumber)
        │
        ▼
Result envelope                        orderStatusResult
   └── outputValues                    orderStatusOutputValues  (orderNumber, status)
        │
        ▼
Renderer maps fields to attributes     orderStatusResult/renderer.json
        │
        ▼
Widget draws the card                  orderStatusCard (JSON layout + schema)
```

Teach the layers in this order. Each one has a single job.

---

## 4. Step 1: Apex tools

### `SoftDrinkOrderStatus`

- `@InvocableMethod` makes it callable by the MCP server.
- Input: `List<Integer> orderNumber`. Output: `OrderInfo` with `orderNumber` and `status`.
- Returns the stored `Status__c` for one order.

Sample output (from the class comment):

```json
{"actionName":"SoftDrinkOrderStatus","isSuccess":true,
 "outputValues":{"orderNumber":100.0,"status":"Open"}}
```

### `SoftDrinkOrdersByDrink`

- Input: one drink name, matched exactly against `Soft_Drink__c.Name`.
- Returns up to 10 orders, newest first.
- Formats the display values in Apex, so the widget only lays out text:
  - `status` with an icon: Processed ✅, Dispatched 🚚, Cancelled ❌, Open 🕒
  - `statusColor`: `success`, `info`, `error`, `warning` or `default`, used by badges
  - `price` as currency text, for example `$25.00`
  - `summaryLine`, for example "3 orders found for Cola"
- An unknown drink returns zero orders, not an error.

**Teaching points**

- `WITH USER_MODE` applies the signed-in user's permissions to the query.
- `@InvocableVariable` marks the fields the MCP layer can see.

---

## 5. Step 2: MCP server definition

`HXL.mcpServerDefinition-meta.xml` registers the server.

| Element | Purpose | Value in this example |
|---|---|---|
| `resources` | A renderable UI the server offers | `orderStatusWidget`, `drinkOrdersWidget` |
| `resourceUri` | Address of the resource | `ui://widget/lightningType/c__orderStatusResult` |
| `tools` | An action the agent can call | One per Apex method |
| `apiIdentifier` / `operation` | Ties the tool to Apex | `aa:apex-SoftDrinkOrderStatus` |
| `descriptionOverride` | Tells the agent when to use the tool | "Return Status of the Soft Drink Order..." |
| `uiResource` | Widget that shows the result | `orderStatusWidget` |

**Teaching point:** the agent chooses tools from `descriptionOverride`. Write it as the user would ask, with an example.

---

## 6. Step 3: Lightning types

Each result has a folder under `lightningTypes/`.

**`schema.json`** describes the data. The result is wrapped in an envelope:

```
orderStatusResult                 (envelope: actionName, isSuccess, outputValues)
   └── orderStatusOutputValues    (orderNumber: number, status: text)

drinkOrdersResult                 (envelope)
   └── drinkOrdersOutputValues    (drinkName, orderCount, summaryLine, orders[])
          └── @apexClassType c__SoftDrinkOrdersByDrink$OrderRow
```

Basic field types: `lightning__textType`, `lightning__numberType`, `lightning__booleanType`. Groups use `lightning__objectType`. `@apexClassType/c__Class$Inner` points to an Apex inner class.

**`renderer.json`** connects data to a widget:

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

Read it as: "Render with the `orderStatusCard` widget, and fill its `orderNumber` from the output's `orderNumber`."

Keys in `attributes` must exist in the widget's `schema.json`.

---

## 7. Step 4: Widgets

A widget bundle is a folder with three files:

```
uiWidgets/orderStatusCard/
  orderStatusCard.json            layout tree (what to draw)
  schema.json                     attributes the widget accepts (the contract)
  orderStatusCard.uiwidget-meta.xml   label, description, widgetType JSON
```

**Layout (`*.json`).** A tree of nodes. Each node has a `definition`, and optionally `attributes`, `children` and `meta`. The `orderStatusCard` root looks like this, abridged:

```json
{
  "type": "lightning__agentforceWidget",
  "contentBody": {
    "widgetBody": {
      "definition": "tile/widget",
      "children": [
        { "definition": "tile/column", "attributes": { "gap": "md" }, "children": [
          { "definition": "tile/text",
            "attributes": { "text": "Order #{!$attrs.orderNumber}", "variant": "h2", "weight": "semibold" } }
        ] }
      ]
    }
  }
}
```

**Schema (`schema.json`).** Flat attributes only. For MCP output, do not repeat the `outputValues` nesting here:

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

**Repeating a list.** `meta.forEach` repeats a node for each item. In `drinkOrdersList.json`, the container repeats once per order, and `{!$Item.orderNumber}` reads the current order.

---

## 8. Binding syntax

| Context | Syntax | Example |
|---|---|---|
| Direct output (Agentforce action) | `{!$attrs.field}` | `{!$attrs.orderNumber}` |
| Nested output (MCP tool) | `{!$attrs.outputValues.field}` | `{!$attrs.outputValues.orderNumber}` |
| Current item in `forEach` | `{!$Item.field}` | `{!$Item.status}` |
| Renderer reference to a widget | `@widget/c/<widget>` | `@widget/c/drinkOrdersList` |
| Apex inner class reference | `@apexClassType/c__Class$Inner` | `@apexClassType/c__SoftDrinkOrdersByDrink$OrderRow` |
| Built-in type | `lightning__<type>` | `lightning__textType` |

Use the `c` prefix for widgets and types, even if the org has its own namespace.

---

## 9. Tile components reference

Components documented by Salesforce (names exactly as written):

| Component | Use |
|---|---|
| `tile/widget` | Root of every widget |
| `tile/column`, `tile/row` | Vertical and horizontal stacks, with `gap`, `align`, `justify` |
| `tile/container` | Bordered box for grouping. Use this where a card is needed |
| `tile/text` | Text, with `variant`, `weight`, `color`, `italic`, `strikethrough` |
| `tile/badge` | Small status label |
| `tile/separator` | Horizontal or vertical divider |
| `tile/spacer` | Fixed or flexible space |
| `tile/list`, `tile/listItem` | List rows (`listItem` holds text, link or icon) |
| `tile/table` | Column definitions and rows |
| `tile/button`, `tile/link`, `tile/icon`, `tile/image`, `tile/avatar` | Interactive and media elements |
| `tile/callout`, `tile/code`, `tile/markdown`, `tile/progress`, `tile/spinner` | Messages, code, rich text, progress |
| `tile/accordion`, `tile/accordionItem` | Expandable sections |

**Not valid:** `tile/card`. Deploying a widget that uses it fails with "Something's not right with the definition name tile/card". This is why the example uses `tile/container`.

Exact attribute values (for example allowed `variant` values for text and badges) are not listed on the public references page. Confirm them in the HXL Playground before you rely on them.

---

## 10. Set up and deploy

### Prerequisites

1. **API version 67.0 or later** for the project and the org.
2. **Enable HXL.** In Setup, search for **Headless Experience Layer Settings**, review the beta terms, and turn the feature on.
3. **Salesforce CLI** installed and an org authorised (`sf org login web --alias <alias>`).
4. The soft-drink objects (`Soft_Drink__c`, `Soft_Drink_Order__c`) in the target org. Without them, the Apex classes will not compile.

### Deploy the example

```bash
# From the SalesforceProject root

# 1. Check only. Makes no changes to the org
sf project deploy start --dry-run --manifest manifest/hxl-package.xml --target-org <alias> --wait 15

# 2. Deploy (only after the dry run passes and you have approved it)
sf project deploy start --manifest manifest/hxl-package.xml --target-org <alias> --wait 15
```

**Result of the check on the practice org (`AIforce_practice_1`):** all 17 components passed after one fix. The first run failed on `tile/card` in `drinkOrdersList.json`, and it was changed to `tile/container`. Nothing has been deployed yet.

Dependencies are handled within one package. If you deploy separately, deploy the Apex classes first, then the `UiWidgetBundle` components, then the `LightningTypeBundle`, then the MCP server definition.

Deleting: deploy a `destructiveChanges.xml` that lists the components to remove.

---

## 11. Test in chat

Ask these questions in the Agentforce chat, using the org data from section 2:

| Question | Expected card |
|---|---|
| "What is the status of my soft drink order 100?" | `orderStatusCard`: Order #100, status Open |
| "Show me all orders for Pepsi" | `drinkOrdersList`: "1 order found for Pepsi", then one card for order 100 |
| "Show me all orders for Cola" | Summary "0 orders found for Cola" and no cards. Use the exact name "Coca Cola" to see results |

If the drink name does not match exactly, the agent gets zero results. That is expected: the Apex match is exact.

---

## 12. Adding a new tool

1. **Apex:** write a class with `@InvocableMethod` and `@InvocableVariable` fields. Use `WITH USER_MODE` in queries.
2. **Lightning types:** add `lightningTypes/<name>OutputValues/schema.json` and `lightningTypes/<name>Result/` (envelope `schema.json` and `renderer.json`).
3. **Widget:** add `uiWidgets/<name>/` with the layout JSON, `schema.json` and `.uiwidget-meta.xml`. Use only the components in section 9.
4. **MCP server definition:** add a `resources` entry for the widget and a `tools` entry for the Apex method.
5. **Manifest:** add the new members to `manifest/hxl-package.xml`.
6. **Check:** run the dry-run, then test in chat.

---

## 13. Known issues

All issues found in the reference example are now fixed in the project and deployed to `AIforce_practice_1`. The reference files in `HXL reference folder materails/` are unchanged.

| # | Where | Issue | Fix applied | Verified |
|---|---|---|---|---|
| 1 | `drinkOrdersList.json` | `tile/card` is not a valid component | Changed to `tile/container` | Dry run and deploy |
| 2 | `SoftDrinkOrderStatus.cls` | Unknown order number threw `System.QueryException` | Lookup returns "Not found" for unknown or missing input | Anonymous Apex and test class |
| 3 | `SoftDrinkOrderStatus.cls` | Raw status with no icon | Same status formatting as the drink list (for example "🕒 Open") | Anonymous Apex |
| 4 | `HXL.mcpServerDefinition-meta.xml` | `readOnly` was `false` for both tools | Set to `true` | Deploy only. Not yet tested in chat, so confirm the agent behaves as expected |
| 5 | `SoftDrinkOrdersByDrink.cls` | Zero orders gave "0 orders found" | Summary reads "No orders yet for <drink>". The widget shows only the summary line, so no widget branch was needed | Anonymous Apex |
| 6 | `SoftDrinkOrdersByDrink.cls` | `statusColor` used `default`, which is not a badge variant | Changed to `secondary`. The badge reference lists `success`, `info`, `warning`, `error`, `primary`, `outline` and `secondary` (default) | Badge reference page; the other values are valid |
| 7 | MCP definition | Typo in `descriptionOverride` | Reworded with an example question | Deploy |

**Not done:** the widget has no conditional branch. The docs do not describe a conditional syntax, so the empty state is handled in Apex. The `orderCount` field remains in the schema for reference.

**New:** `SoftDrinkOrderTest` (five tests, all passing) covers the fixes above.

## 14. Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| "Something's not right with the definition name tile/card" | Invalid component name | Use a name from section 9 |
| Deploy fails on `renderer.json` | Attribute in the renderer is missing from `schema.json` | Make the two match |
| Widget renders but fields are blank | Wrong binding path | Use `outputValues.` for MCP output and check spelling |
| Agent never calls the tool | `descriptionOverride` does not match how users ask | Reword it with an example question |
| Tool returns an error for an unknown ID | Older deploy | Redeploy the current `SoftDrinkOrderStatus` |
| Dry run passes but widget looks wrong in chat | Layout or variant values | Compare with the Playground preview |
| `sf data query` fails with `'C:\Program' is not recognized` on Windows | The CLI launcher path contains spaces | Use `sf api request rest` with a SOQL URL, as in this project |

---

## 15. Glossary

| Term | Meaning |
|---|---|
| **HXL** | Headless Experience Layer. Build a UI once and render it in many channels |
| **Widget** | A declarative UI, defined as JSON, that renders in a channel |
| **Widget bundle** | The `uiWidgets/<name>` folder: layout, schema and configuration |
| **Composition file** | The layout JSON |
| **Schema file** | The list of attributes a widget accepts |
| **Renderer** | `renderer.json`. Connects a Lightning type to a widget and maps its fields |
| **Lightning type** | A typed description of data. Used for tool output and renderers |
| **MCP server** | A server that exposes tools to an AI agent, using the Model Context Protocol |
| **MCP server definition** | The metadata file that registers the server, its tools and its resources |
| **Invocable method** | An Apex method marked `@InvocableMethod`, callable by the agent |
| **`$attrs`** | The data passed into a widget |
| **`$Item`** | The current item inside a `forEach` loop |
| **Beta** | HXL is a pilot. Its use is governed by beta terms |

---

## 16. Exercises

1. **Read a card.** Open `orderStatusCard.json` and list every node, from root to leaf, with its `definition`.
2. **Trace a question.** Follow "status of order 100" through every file in section 3, in order. Write the file name for each step.
3. **Review the not-found fix.** Read `SoftDrinkOrderStatus` and `SoftDrinkOrderTest.statusReturnsNotFoundForUnknownOrder`. Explain why the list query is safer than a single-row query.
4. **Empty state.** Find where the "No orders yet" message is produced, and explain why it is in Apex rather than the widget.
5. **Add a field.** Add the order quantity to `orderStatusCard`. Update the Apex output, the `orderStatusOutputValues` schema, the renderer and the widget schema, in that order.
6. **Break it on purpose.** Use `tile/card` again and run the dry run. Read the error and fix it.

---

## Notes for the trainer

- Show the dry run before the deploy. It is the fastest way to teach the "definition name" and "renderer attribute" rules.
- Use the practice org only with the Pepsi order (number 100). Creating more orders changes the org.
- The beta terms apply. Do not present HXL as generally available.
