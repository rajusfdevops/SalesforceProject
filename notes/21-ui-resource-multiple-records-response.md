# 21. Adding the UI resource to an MCP tool and testing a multiple-records response

## Same wiring, bigger payload

This lesson repeats the wiring from lesson 19, but the tool now returns a list. The `uiResource` entry, the Lightning type, and the widget stay the same. What changes is the shape of the data, so the things to check change too.

## What to check with a list

1. The tool returns an array, not a single object, when several records match.
2. The array is the right length, including when it is empty.
3. The widget renders every item, not just the first.
4. The text fallback lists the same records, so clients without widgets still get the answer.

## Test cases to run

- Zero matches. The widget should show the empty state.
- One match. The list should still render as a list.
- Many matches. Check the count message and that the first and last items are correct.

The one-match case is the easiest to skip and the one that often breaks, because some loops expect an array and get a single object.

## Example (illustrative)

A tool returns one order as an object instead of a one-item array. The widget loop renders nothing, but the text answer is fine. The fix is to make the action always return a list, even for one result. The text answer hid the bug, which is why you test the widget path separately.

## Try it

Run the three test cases above on your tool. Record the result of each in a short table, with the record count and whether the widget rendered.
