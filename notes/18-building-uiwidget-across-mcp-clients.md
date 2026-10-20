# 18. Building a UiWidget to display data across any MCP client

## The goal

The point of this lesson is that one widget works in more than one client. You should not need to build a Claude version and a separate ChatGPT version. Build it once, then check it renders in each client you care about.

## What "supports MCP Apps" means in practice

Not every MCP client renders UI. Some show only text. A client that supports MCP Apps can display a widget that the server supplies. Before you test, confirm the client you are using is on that list. A widget that renders in one client and shows nothing in another is usually a client limitation, not a widget bug.

## Build the simplest widget that works

1. Display one record with two or three fields.
2. Keep the layout flat. No nested sections yet.
3. Test in one client until it renders correctly.
4. Then test in a second client.

If it works in the first and not the second, compare the two clients' supported features before you change the widget.

## Keep the data separate from the layout

Your widget should only describe how to show data, not where the data comes from. This makes it easier to reuse the same widget with a different action later.

## Example (illustrative)

A "Case Summary" widget shows the case number, status, and owner. It renders in Claude. In a second client that does not support widgets, the same tool returns plain text with the same three values. The data is consistent, and only the presentation differs. That is the outcome you want.

## Try it

Take the widget from lesson 17 and test it in two clients. Note which one renders it, and what the other shows instead. Keep both notes.
