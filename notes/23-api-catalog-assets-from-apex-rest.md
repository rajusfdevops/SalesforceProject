# 23. Building API catalog assets from Apex REST services

## What an API catalog asset is

The API catalog is a list of REST endpoints that admins can publish as MCP tools without writing code. Salesforce curates the list, so you pick from what is offered. A catalog asset is your configured version of one endpoint: its name, its description, and the parameters you have fixed or left open.

Your own Apex REST services are a separate route. To get them into the catalog as an asset, you first have to expose them as a REST resource.

## Writing the Apex REST class

A REST class uses the `@RestResource` annotation and one or more methods for HTTP verbs. Keep the first version read-only.

```apex
@RestResource(urlMapping='/renewals/*')
global with sharing class RenewalService {

    @HttpGet
    global static List<Opportunity> getOpen() {
        String region = RestContext.request.params.get('region');
        return [
            SELECT Id, Name, Amount, CloseDate
            FROM Opportunity
            WHERE IsClosed = false AND Region__c = :region
            LIMIT 50
        ];
    }
}
```

Points to notice:

- `with sharing` keeps the caller's record access in force.
- The `LIMIT` is there on purpose. An unbounded REST query is a problem waiting to happen.
- `Region__c` is a custom field used as an example. Replace it with a field from your org.

## Turning it into an asset

1. Confirm the class is deployed and the endpoint responds in a sandbox.
2. Check the endpoint is available in the API catalog for your org. Not every endpoint is.
3. Create the asset, fix any parameter that should not change, and leave the rest open.
4. Give it a description the agent can understand.

## Limits to remember

- One endpoint maps to one tool. If a task needs several calls in order, use a Flow or an Invocable method instead.
- Calls run as the signed-in user, so test with a user who has narrower access too.

## Try it

Deploy the read-only class above to a sandbox. Call it with a test user from a browser or a REST client. Then check that the same call returns the same rows as a list view with the same filter.
