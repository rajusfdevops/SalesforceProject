# 19. Adding an HXL UI resource to an MCP tool and testing end to end

## Connecting the pieces

So far you have an action, a Lightning type, and a widget. This lesson connects them to an MCP tool. The tool's definition gets a `uiResource` entry that points at the Lightning type. Now when the tool runs, the client knows which widget to draw with the result.

## Steps

1. Open the MCP tool definition for the action from earlier lessons.
2. Add the `uiResource` reference, pointing at your Lightning type.
3. Confirm the tool still returns the data the Lightning type expects.
4. Save and redeploy the server.

Redeploying matters. A change to the tool is not picked up by a client that connected before the change, so reconnect the client after each deployment.

## Testing end to end

Test in this order, and stop at the first failure:

1. The action returns the expected data when called alone.
2. The tool returns the same data through MCP.
3. The client shows the widget, not just text.
4. The widget shows every field, with the values you expect.

If step 3 fails, go back to the mapping in lesson 16 before changing anything else.

## Example (illustrative)

You call "Get Recent Orders" from Claude. The text result arrives, but no widget. You check the tool definition and find the `uiResource` line points at an old Lightning type name. You fix the name, redeploy, reconnect, and the card appears.

## Try it

Run the four test steps on your tool and record which one passed first. Write down the exact fix for any step that failed.
