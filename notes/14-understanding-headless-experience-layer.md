# 14. Understanding the Headless Experience Layer (HXL)

## The problem HXL addresses

An agent can read and change Salesforce data through MCP tools, but it can only return text. When a user would be better served by a table, a card, or a form, text is a poor fit. HXL lets you describe a small piece of UI once and have it show up both in Agentforce and in any MCP client that supports MCP Apps.

## Core idea

You define a widget in declarative JSON. The widget describes what to show and which data fields feed it. The same definition then renders in different places, so you do not build a separate screen for each client.

## The pieces

- **UiWidgetBundle.** The metadata component that holds the widget. It lives in a `uiWidgets` folder.
- **Composition file.** The JSON that lays out the widget.
- **Configuration file.** Settings for the widget.
- **schema.json.** Optional. Describes the data the widget expects.
- **Lightning type.** The link between your data and the widget. Its `renderer.json` points at the widget and maps fields to attributes.
- **MCP tool and UI resource.** The tool the agent calls, and the pointer from that tool to the Lightning type that draws the result.

## A simple mental model

Think of it as three layers stacked on each other:

1. The Apex or Flow action returns data.
2. The Lightning type says how that data maps to a widget.
3. The widget draws it, wherever the client supports it.

When something breaks, figure out which layer it is in. A blank widget usually means a mapping problem in layer 2, not a bad action in layer 1.

## Limits to know

- HXL widgets do not render in Block Kit for Slackbot at this time.
- Packaging for partners is planned but has no date yet, so plan for org-level deployment.

## Example (illustrative)

A "Recent Orders" card with three fields per order. The action returns the orders. The Lightning type maps order name, status, and amount to the card. Claude and an Agentforce agent both show the same card for the same data.

## Try it

Sketch the three layers for a single record card you would want in a chat. Write down which field each layer needs. Anything you cannot name is a gap to fix before you build.
