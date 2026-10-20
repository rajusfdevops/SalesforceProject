# 20. Building an HXL widget to display multiple order records using "for each"

## From one record to a list

A widget for a single order is simple. Real use is usually a list: all open orders for an account, for example. The widget needs a way to repeat its layout once for each record, and that is the "for each" element in the composition.

## How the repetition works

The composition declares a collection to loop over. Inside the loop, you refer to the fields of the current item, not the whole list. The layout is written once, and the loop stamps it out per record.

Keep the loop body small. Put one card-like row inside it, with the same three or four fields you used for the single record.

## Common problems

- **Only one item shows.** The loop is pointing at a single record field instead of the collection.
- **Fields show the wrong order.** The data came back sorted differently. Sort in the action, not in the widget.
- **Empty list shows nothing.** Add an empty-state message so the user knows the result is empty, not broken.

## Keep the list short

A chat window is not a full data grid. Limit the number of records returned, and say so in the widget, such as "Showing 10 of 27". Users can ask for more.

## Example (illustrative)

An account has 27 open orders. The action returns 10, sorted by close date, with a total count. The widget loops over the 10, and shows "Showing 10 of 27" at the bottom. The user asks for the next page in chat and the action returns the next 10.

## Try it

Build the loop with two orders first. Confirm both show and the order is right. Then increase to ten and check the layout still reads well.
