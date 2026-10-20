# Named Query and Custom MCP Tools: Customer 360 Build Steps

**Org:** `rkm_agentOrg` (username `rkmishra2703152@agentforce.com`, Developer Edition)
**Purpose:** Build two Named Queries, expose them as tools on a custom MCP server, and call them from Claude.
**Status (2026-10-13):** Built and active in Setup. Endpoints tested and working. The MCP tool list does not yet show the Active flag (see section 9).

---

## 1. Concepts

- **Named Query:** a saved, parameterised SOQL query. It is exposed as a REST endpoint, with no Apex code.
- **Bind variable:** a placeholder such as `:customerName`. The caller supplies the value, so one query serves every customer.
- **API Catalog:** where Named Queries are activated for use outside Salesforce.
- **Custom MCP server:** groups tools (here, Named Queries) into one server that an AI client connects to.
- **Customer 360:** combining several queries about one customer, in one answer.

When to use a Named Query: read-only retrieval, reusable, no business logic. For totals, scores or rules, use Apex REST or an Agent instead.

---

## 2. Data in the org

| Object | Relevant fields | Records |
|---|---|---|
| `ASR_Hotel_Booking__c` | `Name`, `Customer_Name__c`, `Hotel__c` (lookup), `City__c`, `Check_In__c`, `Check_Out__c` | 2 |
| `ASR_Hotel__c` | `Name`, `City__c`, `Location__c` | (hotels for bookings) |
| `ASR_Order__c` | `Name`, `AccountId__c` (lookup to Account), `Status__c`, `TotalAmount__c`, `EffectiveDate__c` | 2 |
| `Account` | `Name` | 54 |

Test data:

| Input | Expected |
|---|---|
| Bookings for `Jane Doe` | HB-0000, Grand Plaza, San Francisco, 2024-12-01 to 2024-12-05 |
| Bookings for `John Smith` | HB-0001, Seaside Resort, Miami, 2024-12-10 to 2024-12-15 |
| Orders for `Pinnacle Solutions Inc` | O-0000 (Shipped, 500), O-0001 (Delivered, 750) |
| Bookings for `Nobody` | No rows |

---

## 3. Create the Named Queries (Setup)

Path: **Setup → Quick Find → Named Query API → New Named Query API**.

### 3.1 Query 1: CustomerBookings

| Field | Value |
|---|---|
| Label | Customer Bookings |
| API Name | `CustomerBookings` |
| Description | Hotel bookings for a customer, matched by exact customer name. |

SOQL:

```sql
SELECT Name, Customer_Name__c, Hotel__r.Name, City__c, Check_In__c, Check_Out__c
FROM ASR_Hotel_Booking__c
WHERE Customer_Name__c = :customerName
ORDER BY Check_In__c DESC
```

Steps:
1. Paste the SOQL.
2. Click **Validate**. The bind variable `customerName` should be detected.
3. Set its type to **String** and mark it **required**.
4. **Save**, then **Activate** (see section 4).

### 3.2 Query 2: AccountOrders

| Field | Value |
|---|---|
| Label | Account Orders |
| API Name | `AccountOrders` |
| Description | Orders for an account, matched by exact account name. |

SOQL:

```sql
SELECT Name, Status__c, TotalAmount__c, EffectiveDate__c
FROM ASR_Order__c
WHERE AccountId__r.Name = :accountName
ORDER BY EffectiveDate__c DESC
```

Steps are the same as 3.1, with `accountName` as the bind variable.

**Note:** the Setup page shows the parameter name in lower case (`accountname`) and builds the endpoint from it. Use the name the page shows when calling the endpoint.

---

## 4. Activate the queries (API Catalog)

A query can be visible in Setup without being usable. Activation is what makes it available outside Salesforce.

1. Open the query in **Setup → Named Query API**.
2. Click **View in API Catalog** (top right).
3. Find the query and turn activation on.
4. Return to **Named Query API**. The **API Catalog Activation** column should show **Active**.

Status at the time of writing: both queries show **Active** in the Named Query API list.

---

## 5. Permission set for the query user

Named Queries run as the signed-in user. That user needs read access to every object and field the query uses.

1. **Setup → Permission Sets → New.** Label `Customer 360 Query Access`, API name `Customer360_Query_Access`.
2. **Object Settings**, read access on:
   - `ASR Hotel Booking`: fields `Customer Name`, `City`, `Check In`, `Check Out`, `Hotel`, and standard `Name`
   - `ASR Hotel`: `Name`, `City`
   - `ASR Order`: `Status`, `Total Amount`, `Effective Date`, `Account`, and standard `Name`
   - `Account`: `Account Name`
3. **Manage Assignments:** assign the set to the user who will connect Claude.

**Lesson:** a missing field fails the query even if the SOQL is valid.

---

## 6. Create the custom MCP server

Path: **Setup → Quick Find → MCP Servers → New**.

| Field | Value |
|---|---|
| Name | `CustomerDataMCP` |
| Label | Customer Data MCP |
| Description | Customer bookings and orders for Customer 360 demos. |

Save. The server ID in this org is `1g1fj0000001KzBAAU`, and its URL is `https://api.salesforce.com/platform/mcp/v1/custom/CustomerDataMCP`.

Keep it separate from the existing `MCPAppForClaude` server.

---

## 7. Add the queries as tools

1. Open **Customer Data MCP**, then its **Tools** or **Assets** section.
2. Add **Customer Bookings** and **Account Orders**.
3. Set a description for each:
   - Customer Bookings: *Return hotel bookings for a customer, given the exact customer name, for example "Jane Doe".*
   - Account Orders: *Return orders for a company account, given its exact name, for example "Pinnacle Solutions Inc".*
4. Make sure the server is **active**.

---

## 8. Check the setup (CLI, read-only)

```bash
sf agent mcp list -o rkm_agentOrg
sf agent mcp get -o rkm_agentOrg -i 1g1fj0000001KzBAAU --json
sf agent mcp asset list -o rkm_agentOrg -i 1g1fj0000001KzBAAU
```

Expected:
- `CustomerDataMCP` listed, active.
- Two assets: `AccountOrdersAccountOrders_nquery` and `CustomerBookingsCustomerBookings_nquery`, both `MCP_TOOL`.

Test the endpoints directly (read-only, admin user). Both returned the expected data:

```bash
sf api request rest "/services/data/v68.0/named/query/AccountOrders?accountname=Pinnacle%20Solutions%20Inc" -o rkm_agentOrg
sf api request rest "/services/data/v68.0/named/query/CustomerBookings?customername=Jane%20Doe" -o rkm_agentOrg
```

Note: the `sf api request rest` command works for GET requests on Windows. For POST requests, use the Setup or Apex routes.

---

## 9. Connect Claude and test

1. Copy the server URL from the **Customer Data MCP** page.
2. In Claude, add it as an MCP server, following the client's steps.
3. Sign in as `rkmishra2703152@agentforce.com` (or the user with the permission set from section 5).
4. Confirm that both tools appear in Claude's tool list.

### Test prompts

| Prompt | Expected |
|---|---|
| "Show all hotel bookings for Jane Doe" | HB-0000, Grand Plaza, San Francisco |
| "What orders does Pinnacle Solutions Inc have?" | O-0000 (500, Shipped), O-0001 (750, Delivered) |
| "Show bookings for Nobody" | No bookings |
| "Give me a 360 view of Jane Doe and Pinnacle Solutions" | Both results combined in one answer |

### Open item: Active flag on MCP tools

The CLI asset list still shows a blank **Active** column for both tools, even though the queries are active in Setup. If Claude does not list the tools, try:
1. Open **Customer Data MCP** in Setup, remove the two tools, and add them again.
2. Run the asset list command again.
3. Reconnect Claude.

---

## 10. Troubleshooting

| Symptom | Fix |
|---|---|
| Bind variable not detected | Check the colon in `:customerName`, and that the bind name matches |
| Query shows Inactive | Activate it in the API Catalog (section 4) |
| Tool missing in Claude | Check the server is active, re-add the tools (section 9), reconnect |
| "Insufficient access" | Add the object or field to the permission set (section 5) |
| Empty result | Use the exact name, for example `Jane Doe`, with the same capitalisation |
| Endpoint returns not found | Check the endpoint name matches the API name, and the query is active |

---

## 11. Teaching notes

- **Why a Named Query:** read-only retrieval, no code, reusable.
- **Why bind variables:** one query serves every customer.
- **Why not for totals or rules:** use Apex REST or an Agent. Ask students for a "VIP score" example, and discuss where it belongs.
- **Customer 360:** two Named Queries, combined by the AI client in one answer.

---

## 12. Status checklist

- [x] Named Query `CustomerBookings` created
- [x] Named Query `AccountOrders` created
- [x] Both queries active (Named Query API list)
- [x] Endpoints tested with read-only GET calls
- [x] MCP server `CustomerDataMCP` created and active
- [x] Both queries listed as MCP assets
- [ ] MCP tools show as Active in the CLI asset list
- [ ] Permission set `Customer360_Query_Access` created and assigned
- [ ] Claude lists both tools
- [ ] Test prompts pass in Claude
