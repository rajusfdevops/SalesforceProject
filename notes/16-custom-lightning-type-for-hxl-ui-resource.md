# 16. Creating a custom Lightning type for an HXL UI resource

## What a Lightning type does here

A Lightning type tells HXL how to read your data and which widget to draw. Without it, the widget has nothing to bind to. Think of it as the adapter between the action's output and the widget's inputs.

## Parts you will touch

- **The type definition.** Declares the shape of the data.
- **renderer.json.** Points at the widget with `@widget/c/<widgetName>` and maps fields to the widget's attributes.

The name in the path must match the widget exactly. A typo here is one of the most common reasons a widget shows nothing, and the error is easy to miss.

## Steps

1. Look at what the action returns. Write down every field the widget needs.
2. Create the Lightning type with only those fields. Leave out anything extra for now.
3. Write renderer.json. Point it at the widget and map each field to an attribute.
4. Save, deploy to your sandbox, and confirm the type appears.

## Keep the mapping one-to-one at first

Map each field to exactly one attribute. Once that works, you can add formatting or calculated values. Starting with a clever mapping makes it hard to tell which part failed.

## Example (illustrative)

An order returns `Name`, `Status__c`, and `Amount__c`. The Lightning type declares those three. renderer.json maps `Name` to the card title, `Status__c` to the status badge, and `Amount__c` to the amount line. A missing mapping for `Amount__c` shows a blank line, which is a clue to check the mapping before the action.

## Try it

Pick two fields from a real object. Build the type with just those two, map them, and confirm the widget shows both values before you add anything else.
