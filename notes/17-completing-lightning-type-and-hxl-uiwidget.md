# 17. Completing the Lightning type and creating an HXL UiWidget

## Two halves that must agree

A Lightning type and a UiWidget are built separately, but they only work together when their field names and attribute names match. Most failures here are naming mismatches, not logic errors.

## Building the UiWidget

A UiWidgetBundle holds three main files:

- The **composition** file lays out the elements, such as a title, a status badge, and an amount.
- The **configuration** file holds the widget's settings.
- The optional **schema.json** describes the expected data. It is worth adding, because it lets you catch a missing field before the widget renders.

Start with the simplest layout that shows the data. Add styling later.

## Steps to finish the Lightning type

1. Confirm every attribute in renderer.json exists in the widget's schema or composition.
2. Set the required fields so the widget fails loudly when data is missing.
3. Deploy the widget bundle and the Lightning type together, so they do not drift apart.

## Checking the match

Open the composition and list each binding name. Then open renderer.json and list each mapped attribute. The two lists should match one for one. Any name that appears in only one list is your bug.

## Example (illustrative)

The composition binds to `orderTitle`, but renderer.json maps to `title`. The widget renders with an empty title and no error. Renaming one side fixes it. This kind of mismatch does not throw an error, so check it by hand.

## Try it

Make a list of every binding name in your composition and every attribute in renderer.json. Compare them line by line and fix the mismatches before you deploy.
