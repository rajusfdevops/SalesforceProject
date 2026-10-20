# 8. Building custom MCP tools with Apex for business-specific actions

## When Apex is the better choice

Use Apex when the Flow version would be hard to read or slow to run. Typical cases:

- Logic with loops over many records, or bulk handling that a Flow would struggle with.
- Calculations that are easier to test in code, such as pricing rules or scoring.
- Calls to other systems where you need precise control over errors and retries.

If a Flow can do the job cleanly, prefer it. Apex means more code to maintain.

## A small example

This is a simple invocable method. It is the same pattern Flow uses to call Apex, so it is a good starting point before you wire it to MCP. Check the current docs for how custom MCP tools register Apex methods, since that mechanism can change.

```apex
public with sharing class RenewalScorer {

    public class Request {
        @InvocableVariable(label='Account Id' required=true)
        public Id accountId;
    }

    public class Result {
        @InvocableVariable(label='Health Score')
        public Integer score;
    }

    @InvocableMethod(label='Score Account Renewal Health')
    public static List<Result> score(List<Request> requests) {
        List<Result> results = new List<Result>();
        for (Request req : requests) {
            Integer openCases = [
                SELECT COUNT() FROM Case
                WHERE AccountId = :req.accountId AND IsClosed = false
            ];
            Result r = new Result();
            r.score = Math.max(0, 100 - (openCases * 10));
            results.add(r);
        }
        return results;
    }
}
```

Notes on the code:

- `with sharing` keeps the user's record access in force. Leave it in place.
- The query is outside the loop body's per-record work, but it still runs once per request. For large batches, query all accounts at once and map the results.
- The scoring rule is made up for this example. Replace it with your own business rule.

## Making it a tool

Once the Apex works, add it to the custom MCP server the same way you add a Flow. Write a description that says what the score means and what it does not mean. The model will repeat your wording to users, so be precise.

## Testing

- Write Apex tests with at least one account that has no cases, one with many, and one that the running user cannot see. The last one should fail safely.
- Run the tool through the MCP client and compare the result with the same calculation done by hand in a report.
- Watch governor limits. A tool that works for one account can hit limits when a user asks about a whole territory.

## Try it

Write the scoring method above in a sandbox, add two test classes, and run them. Then change the scoring rule and confirm the tests still pass, or fail in the way you expect.
