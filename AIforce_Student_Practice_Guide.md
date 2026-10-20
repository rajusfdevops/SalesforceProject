# AIforce Workshop: Student Practice Guide

A step-by-step revision guide for the Salesforce AIforce workshop. It follows the official workshop at `developer.salesforce.com/workshops/aiforce-workshop` in the recommended order.

**Source:** https://developer.salesforce.com/workshops/aiforce-workshop/get-started/overview

---

## Before you begin

### What you need

| Requirement | Used in | Paid AI subscription? |
|---|---|---|
| Salesforce org link and login from your instructor | Everything | No |
| VS Code, Salesforce Extension Pack, Salesforce CLI, Git | Vibes, React, HXL | No |
| Windows only: Microsoft Visual C++ Redistributable | Agentforce Vibes | No |
| AIforce Playground access and login from your instructor | Module 1 (2b, 3), Module 5 (Ex 2) | No (per workshop page) |
| **Claude account** (claude.ai) | Module 1 (2a, 3), Module 5 (Ex 1) | **Yes** |
| Sales Cloud in Claude beta access (or Claude Enterprise) | Module 5 (Ex 1) | **Yes, per the workshop page** |

### Can I finish without a Claude subscription?

Yes. Use the AIforce Playground in place of Claude:

- **Module 1:** do Exercise 1, then 2b (Playground) and Exercise 3 (Playground). Skip 2a.
- **Module 2:** no Claude needed.
- **Module 3:** no Claude needed.
- **Module 4:** no Claude needed.
- **Module 5:** do Exercise 2 (Playground). Skip Exercise 1.

### Recommended order

1. Get Started (Exercises 1 and 2)
2. Explore Salesforce Hosted MCPs (Exercises 1, 2a/2b, 3)
3. Build with Agentforce Vibes (Exercises 1, 2, 3)
4. Build a Multi-Framework App with React (Exercises 1 to 4)
5. Give Agents UI with the Headless Experience Layer (HXL) (Exercises 1 to 4). This module is self-contained and can be done right after Get Started.
6. Get Started with Salesforce in Claude (Exercises 1 and 2). Requires Module 1.

> **Note for students:** Use a **test org**. Some steps create or change records, metadata and permission sets. Don't use this guide in a production org.

---

# Part 0: Get Started

## Exercise 1: Obtain an Org

1. Follow your instructor's instructions. They provision a Salesforce org for the workshop.
2. Check your email for the link to log in to your org.
3. Go to https://login.salesforce.com and log in.

**Tip:** The workshop org's default admin user appears as **EPIC, OrgFarm** (or **OrgFarm EPIC**) in Setup. You'll look this user up in Module 1.

**Done when:** you can log in to the org.

## Exercise 2: Explore Pronto

Pronto is the sample merchant app used throughout the workshop.

1. **Storefronts**
   1. In the **App Launcher**, open **Pronto Merchant Management**.
   2. Open the **Storefronts** tab. Note the **Average Review Score** and **Total Reviews** fields.
   3. Open **Urban Table Downtown**. Review its related **Orders** and **Reviews**.
2. **Customers**
   1. Use global search for the contact **Ethan Kim**.
   2. Open the record and review its **Orders** and **Reviews**.
   3. Note how this maps to behavior: Orders are meals the customer ordered. Reviews are feedback that rolls up into each storefront's Average Review Score.
3. **Orders**
   1. Open the **Customer Orders** tab, or search for an order.
   2. Check **Status**, **Total Amount** and the **Storefront** lookup.
   3. Open an **Order Items** record to see the menu item and quantity.
   4. Go back to Urban Table Downtown and find its related Orders.

**Done when:** you can explain how Storefronts, Orders, Order Items, Customers and Reviews connect.

---

# Module 1: Explore Salesforce Hosted MCPs

**Goal:** connect an AI client (Claude or the AIforce Playground) to live Salesforce data through Salesforce-hosted MCP servers.

**Key terms**
- **MCP (Model Context Protocol):** a standard that lets AI clients call tools.
- **External Client App (ECA):** the Salesforce app that handles OAuth login for your MCP client.
- **SObject All:** an MCP server that lets clients query and update Salesforce records.
- **Headless360 (H360):** an MCP server that lets clients query and update metadata and records.

## Exercise 1: Configure Salesforce MCP Servers

### Step 1: Set and verify your email
1. Setup → Quick Find **Users** → **Users**.
2. Click **Edit** next to **EPIC, OrgFarm**.
3. Replace the **Email** value with your own email. Click **Save**, then **OK**.
4. Open the email titled "Finish changing your Salesforce account's email address" and click the link.
5. Click **Verify Email Address**, then **Continue**.

> Required for the rest of the module. It also lets you reset your password.

### Step 2: Create an External Client App
1. Setup → Quick Find **External Client** → **External Client App Manager**.
2. Click **New External Client App**.
3. **Basic Information:**
   - App Name: `Workshop MCP Client`
   - API Name: `Workshop_MCP_Client` (auto-filled)
   - Contact Email: your email
   - Distribution State: `Local`
4. Expand **API (Enable OAuth Settings)**:
   1. Tick **Enable OAuth**.
   2. **Callback URL**, one per line:
      ```
      https://mcp-playground-360-lb-75bfc079c1f3.herokuapp.com/oauth/sf/callback
      https://claude.ai/api/mcp/auth_callback
      ```
   3. **Selected OAuth Scopes:**
      - Perform requests at any time (`refresh_token, offline_access`)
      - Access Salesforce hosted MCP servers (`mcp_api`)
5. Under **Security**, tick **Issue JSON Web Token (JWT)-based access tokens for named users**.
6. Click **Create**. It can take up to 30 minutes to become available.

> **Double-check these settings.** A mistake here blocks you in the next steps.

### Step 3: Create a Permission Set
1. Setup → Quick Find **Permission** → **Permission Sets** → **New**.
2. Label: `MCP Client User`. API Name fills in automatically.
3. Description: `Grants access to the Salesforce hosted MCP servers.`
4. Click **Save**.
5. Click **Manage Assignments** → **Add Assignment**. Tick **OrgFarm EPIC** → **Next** → **Assign**.

### Step 4: Secure access to the ECA
1. Setup → **External Client App Manager** → open **Workshop MCP Client**.
2. Click **Edit** on the **Policies** tab. Expand **OAuth Policies**.
3. Set **Permitted Users** to **Admin approved users are pre-authorized**. Click **OK**.
4. Under **Select Permission Sets**, move **MCP Client User** to **Selected Permission Sets**. Click **Save**.
5. Click **Settings** → **Consumer Key and Secret** under OAuth Settings.
6. Enter the verification code from your email.
7. **Copy and store** the **Consumer Key** and **Consumer Secret**. You need them for every client.

> You can't finish this step unless Step 1 is complete.

### Step 5: Activate the Salesforce hosted MCP servers
1. Setup → Quick Find **MCP Servers** → **MCP Servers** (under API Catalog).
2. Click **Salesforce Servers**.
3. Open **SObject All** → **Activate**.
4. Open **Headless360 (H360) MCP Server** → **Activate**.

**Done when:** both servers show as active, and you have the Consumer Key and Secret.

---

## Exercise 2a: Explore the MCP Servers with Claude
*Requires a Claude account. Students without one: go to Exercise 2b.*

### Step 1: Connect Claude to your org
1. In Claude, click **Customize** → **Connectors**.
2. Click **Discover** and search for `Salesforce`.
3. Connect **Salesforce - Beta**:
   1. Click it → **Connect to Claude**.
   2. Select **Yes, I have them** → **Continue**.
   3. **Server URL:** `https://api.salesforce.com/platform/mcp/v1/platform/headless-360`
   4. **OAuth client ID:** Consumer Key. **OAuth client secret:** Consumer Secret.
   5. Click **Connect**, log in, and approve.
4. Add **sobject-all** as a custom connector:
   1. **Add** → **Add custom connector**.
   2. **Name:** `sobject-all`
   3. **MCP server URL:** `https://api.salesforce.com/platform/mcp/v1/platform/sobject-all`
   4. Click **Continue**. Enter the Consumer Key and Secret. Click **Connect**, log in, and approve.

**Expected:** two active connectors, **Salesforce - Beta** and **sobject-all**.

**Troubleshooting:** `invalid_client_id` or a failed redirect usually means the ECA is missing Claude's callback URL, or it isn't active yet. Wait a few minutes and try again.

### Step 2: Inspect the Pronto data model
1. Click **New** to start a chat. Click **+** → **Connectors**, and turn on **Salesforce**.
2. Prompt:
   ```txt
   What Salesforce objects and fields are most relevant for understanding storefront and order activity in this org? Focus on Storefront__c, Order__c, Review__c, and Contact.
   ```
   Click **Always allow** if Claude asks for permission.
3. Ask Claude to describe the key fields on `Storefront__c`, `Order__c`, and `Review__c`, especially rating, review volume, order status and delivery timing.
4. Note the fields Claude picks, especially `Average_Review_Score__c` and `Total_Reviews__c` on `Storefront__c`, and `Status__c` on `Order__c`.

### Step 3: Find storefront and order signals
1. New chat. Click **+** → **Connectors**, and turn on **sobject-all**.
2. Prompts, one at a time:
   ```txt
   Show me a sample of Storefront__c records by name, cuisine, status, average review score, and total reviews.
   ```
   ```txt
   Which Storefront__c records have the highest number of Order__c records with a status of Canceled? Summarize why each storefront may need operational attention.
   ```
   ```txt
   Find storefronts with a low Average_Review_Score__c or fewer than 5 Total_Reviews__c. Pull a sample of their Review__c comments to explain your reasoning.
   ```
3. Notice how Claude combines metadata, record filters and business language.

### Step 4: Chain related records to update an order
1. New chat. Prompt:
   ```txt
   Cancel the most recent order placed by Leola Oliva at Urban Table Uptown. Set the cancellation reason to "Customer requested cancellation, item unavailable".
   ```
2. **Expected:** Claude queries Contact and Storefront__c to resolve the names, finds the order in Order__c, then updates `Status__c` and `Cancelation_Reason__c`.

> This changes data in your test org. Check the order in Pronto afterwards.

### Step 5 (optional): Turn data into outputs
Ask Claude for, one per chat:
- A bar chart of `Order__c` volume by order status, from live data.
- A pie chart of `Review__c` count by rating across all storefronts.
- A line chart or timeline of `Order__c` volume over time for Urban Table Downtown, with an explanation of any spike or drop.
- A one-page PDF executive summary for a Pronto operations lead: strongest and weakest storefronts by average review score, recent cancellations, review trends, and follow-up questions.

**Check:** the output cites live Salesforce records, not generic advice.

---

## Exercise 2b: Explore the MCP Servers with the AIforce Playground
*No Claude subscription needed. Use your instructor's login.*

### Step 1: Connect the Playground to your org
1. In your org, Setup → Quick Find **My Domain** → copy your **My Domain URL**, for example `https://your-domain.my.salesforce.com`.
2. Open the AIforce Playground: https://mcp-playground-360-lb-75bfc079c1f3.herokuapp.com/
3. Sign in with your instructor's credentials. Click **Connect**.
4. Fill in the form:
   - **Instance URL:** your My Domain URL
   - **Consumer Key** and **Consumer Secret:** from Module 1, Exercise 1
5. Click **Connect**, then authorize the app.

If you see `invalid_client_id`, wait a few minutes and try again.

### Step 2: Add the two MCP servers
1. On the **Servers** tab, click **Add server**, then **Add server** again.
2. Open the **Salesforce hosted** tab.
3. Click the **sobject-all** tile → **Test connection** → confirm the tools are found → **Add server**.
4. Repeat for the **headless-360** tile.

**Expected:** both **sobject-all** and **headless-360** show as active.

### Step 3: Inspect the Pronto data model
1. Open the **Chat** tab. Click **Tools** and check **HEADLESS-360**. If the tools are greyed out, turn off **Auto-select tools**.
2. Prompt:
   ```txt
   What Salesforce objects and fields are most relevant for understanding storefront and order activity in this org? Focus on Storefront__c, Order__c, Review__c, and Contact.
   ```
3. Prompt:
   ```txt
   Describe the key fields on Storefront__c, Order__c, and Review__c. Call out fields that help explain storefront rating and review volume, order status, and delivery timing.
   ```
4. Note `Average_Review_Score__c`, `Total_Reviews__c` and `Status__c`.

**Expected:** this server has no record tools, so the model builds REST calls itself from its describe results.

### Step 4: Find storefront and order signals
1. New chat. Click **Tools** and select **SOBJECT-ALL**.
2. Use the same three prompts from Module 1, Exercise 2a, Step 3.

### Step 5: Chain related records to update an order
1. New chat. Prompt:
   ```txt
   Cancel the most recent order placed by Leola Oliva at Urban Table Uptown. Set the cancellation reason to "Customer requested cancellation, item unavailable".
   ```
2. **Expected:** the model resolves the names in Contact and Storefront__c, finds the order in Order__c, then updates `Status__c` and `Cancelation_Reason__c`.

### Step 6 (optional): Charts and a PDF summary
Prompts, one per chat:
```txt
Create a bar chart that compares Order__c volume by order status. Use the live order data you can access through Salesforce MCP tools.
```
```txt
Create a pie chart that shows Review__c count by rating, across all storefronts.
```
```txt
Create a line chart or timeline that shows Order__c volume over time for Urban Table Downtown. Explain any spike or drop you see in the data.
```
```txt
Create a one-page PDF summary for a Pronto operations lead. Include the strongest and weakest performing storefronts by average review score, the most recently canceled orders, review trends, and the next questions an operations lead should ask.
```

---

## Exercise 3: Create a Custom MCP Server
*Use Claude (Step 7a) or the Playground (Step 7b).*

### Step 1: Review the Apex action
1. Setup → Quick Find **Apex Classes** → open **GetOrderStatusAction**.
2. Review it:
   - `@InvocableMethod` `getOrderStatus`, labelled **Get Order Status**. This makes it available as an action and an MCP tool.
   - Input: `orderId` (required, the `Order__c` ID) and optional `customerId`. If `customerId` is given, the class checks the customer can access the order.
   - Output: an `orderStatus` object with status, customer, storefront, total, order and delivery times, line items and a record link.
3. Close without changes.

### Step 2: Review the Flow
1. Setup → Quick Find **Flows** → open **Review Storefront Health** in Flow Builder.
2. Review it:
   - Input: `storefrontId`.
   - **Get Storefront** loads the storefront by ID.
   - `healthLabelFormula`: `Insufficient Data` for fewer than 5 reviews. Otherwise `Strong` (4.5+), `Healthy` (4+), `Needs Attention` (3+), or `At Risk`.
   - Outputs: `storefrontName`, `averageReviewScore`, `totalReviews`, `healthLabel`.
3. Confirm it's **Active**. Close without changes.

### Step 3: Create the custom MCP server
1. Setup → Quick Find **MCP Servers** → **MCP Servers** → **Add MCP Server** → **Salesforce Servers** tab.
2. Click **Create Salesforce MCP Server**.

| Field | Value |
|---|---|
| Label | `Pronto Order Tools` |
| Name | `ProntoOrderTools` (auto-filled) |
| Description | `A custom MCP server with storefront and order tools.` |

3. Click **Create**.

### Step 4: Add the custom tools
1. **Add Server Assets** → **Add Tools**.
2. Under **Apex actions**, search `Get Order Status`. Choose **Get Order Status** (not "Get Order Status Card") → **Add Tool**.
3. Change the type dropdown to **Flows**. Search `Review Storefront Health` → **Add Tool**.
4. Click **Save**.

**Expected:** the header shows **2 tools**.

### Step 5: Add the standard SObject tools
1. **Add Server Assets** → **Add from Server**. Search `sobject` → **SObject Reads**.
2. Click **Add Tool** on **Query Records (SOQL)** and on **Search Across Objects (SOSL)**.
3. Click **Done**.

**Expected:** 4 tools in total.

> `Get Order Status` needs an Order ID, not a name. The model uses SOQL to turn a storefront or customer name into an ID first.

### Step 6: Activate and copy the server URL
1. Click **Activate**.
2. Copy the **Server URL**.

### Step 7a: Add the server to Claude
1. Claude → **Customize** → **Connectors** → **Add** → **Add custom connector**.
2. **Name:** `ProntoOrderTools`
3. **MCP server URL:** `https://api.salesforce.com/platform/mcp/v1/custom/ProntoOrderTools`
4. Click **Continue**. Enter the Consumer Key as **OAuth client ID** and the Consumer Secret as **OAuth client secret**.
5. Click **Connect**, log in, and approve.

### Step 7b: Add the server to the Playground
1. Open the AIforce Playground → **Servers** tab → **Add server** → **Add server**.
2. Confirm you're on the **From URL** tab. Paste into **URL**:
   ```
   https://api.salesforce.com/platform/mcp/v1/custom/ProntoOrderTools
   ```
3. Click **Test connection**. **Expected:** four tools found. Click **Add server**.

### Step 8: Test the custom server
1. Open the **Chat** tab → **New chat**.
2. Click **Tools** and select **PRONTOORDERTOOLS**. If the tools are greyed out, turn off **Auto-select tools**.
3. Prompt 1:
   ```txt
   Find the Storefront__c named Urban Table Downtown and check its storefront health.
   ```
   **Expected:** the model runs SOQL to get the ID, then calls `Review_Storefront_Health`. It returns the average score, total reviews and a health label.
4. Prompt 2:
   ```txt
   Check the status of the most recent Order__c record for the Storefront__c named Urban Table Downtown.
   ```
   **Expected:** SOQL finds the latest order ID, then `Get Order Status` returns its live status.
5. In your org, open the **Storefronts** tab → **Urban Table Downtown**. Check that the Average Review Score, Total Reviews and related orders match the answers.

**Done when:** both prompts return live data that matches the org record.

---

# Module 2: Build with Agentforce Vibes

**Goal:** use Agentforce Vibes, an AI-assisted IDE, to build a Storefront Health component and a Merchant Performance Dashboard by describing what you want.

## Prerequisites
1. **Windows only:** install the **Microsoft Visual C++ Redistributable** before opening VS Code. Without it, the extension won't activate.
2. Install the latest **Salesforce CLI** and the **Salesforce Extension Pack** in VS Code.
3. Install **Git** (needed for Checkpoints).

## Exercise 1: Launch and Explore

1. **Activate the Salesforce hosted MCP servers.**
   1. Setup → Quick Find **MCP Servers** → **MCP Servers** → **Salesforce Servers**.
   2. Open **salesforce-api-context** → **Activate**.
   3. Open **metadata-experts** → **Activate**.
   *(The Headless360 server isn't used in this module.)*
2. **Launch Agentforce Vibes.** Setup Menu → **Agentforce Vibes** → accept the **Terms and Conditions**. Initialization takes a few minutes. It creates a Salesforce DX project and authorizes your Pronto org.
3. **Note the active project name** in the Status Bar. To reopen it later: **File → Open Folder**.
4. In the Agentforce Vibes Sidebar, click **I agree to the terms**, then **Enable Agentforce**.
5. **Explore the IDE:**
   - **Command Palette:** `Ctrl+Shift+P` (Windows) or `Cmd+Shift+P` (Mac). Vibes, SFDX and Lightning Preview commands.
   - **Explorer:** generated Apex, LWCs and metadata.
   - **Org Browser:** the cloud icon in the Activity Bar, or `Org Browser: Focus on Metadata View`. Browse Pronto metadata and download it into the project.
   - **Integrated Terminal:** `` Ctrl+` `` or **Terminal → New Terminal**.
   - **Status Bar:** shows the org, project, Lightning Preview and MCP status. Click **Open Default Org in Browser** to open the org.
6. **Set the agent's mode.** Click the **Settings** icon in the sidebar → **Default session mode** → **Bypass (trust all)** → **Back**. This lets the agent act without asking each time. Choose a stricter mode for your own projects.
7. **Check the Toolkit.** Click the **Toolkit** tab. Under **MCP Servers** you should see Salesforce API Context, Salesforce Metadata Experts, Salesforce Headless 360 and Salesforce DX. If one shows an error, toggle it off and on. Also check **Skills** (`sf-skills`) and **Rules**.
8. **Update the CLI.** In the terminal, run:
   ```bash
   sf update
   ```
   Wait for it to finish.

**Done when:** the sidebar is open, the project is loaded, and the org is authorized.

## Exercise 2: Vibe Code a Storefront Health Component

### Step 1: Create the formula field
1. In the Agentforce Vibes Sidebar, ask the agent to create a **Number** formula field on `Storefront__c`:
   - **Label:** Storefront Performance Score
   - **API name:** `Storefront_Performance_Score__c`
   - **Score (0 to 100):** start at 50.
     - +30 if `Average_Review_Score__c` > 4
     - +15 if it's > 3 and ≤ 4
     - −20 if it's < 3
     - +10 if `Total_Reviews__c` > 50
     - −10 if `Total_Reviews__c` < 5
     - cap the result between 0 and 100
   - **Type:** Number, 0 decimal places.
   - Grant field-level read access in the **Merchant Management App** permission set.
   - Limit changes to the field file and that permission set. No Apex, flows or other metadata.
2. Let the agent deploy. If it doesn't, ask it to deploy the field and permission set to your org.

**Expected:** a deployment confirmation.

### Step 2: Build the record page LWC
1. Ask the agent to create an LWC named `storefrontHealth` in `force-app/main/default/lwc/storefrontHealth/`, with four files:
   - `storefrontHealth.html`
   - `storefrontHealth.js`
   - `storefrontHealth.css`
   - `storefrontHealth.js-meta.xml`
2. Requirements:
   - Use the `getRecord` wire adapter from `lightning/uiRecordApi` with the page's `recordId`. **No Apex.**
   - Show Storefront Name, `Average_Review_Score__c`, `Total_Reviews__c` and `Storefront_Performance_Score__c`.
   - Health bands: 80–100 Strong, 60–79 Healthy, 40–59 Needs Attention, below 40 At Risk.
   - SLDS styling, a progress bar or large badge, and a short helper message.
   - If the score is blank: "No storefront performance score available."
   - In the meta XML, expose it to `lightning__RecordPage` for `Storefront__c` only.
3. Deploy `storefrontHealth` if the agent doesn't.

### Step 3: Preview it
1. Expand **Validate your changes** above the chat input → **Preview Locally** next to `storefrontHealth`. Press **Enter** if prompted.
   - Alternative: right-click the folder or `.html` file → **SFDX: Open in Lightning Preview**.
2. If the preview shows no data, ask the agent to make it preview-friendly:
   - Get a real storefront ID with:
     ```bash
     sf data query --query "SELECT Id, Name FROM Storefront__c LIMIT 1"
     ```
   - Use that ID **only** as a preview fallback, with a comment saying so. The real `recordId` should still be used when available.
   - Don't invent IDs. Limit edits to `storefrontHealth.js`.
3. Deploy the fix, then run Lightning Preview again.

**Expected:** a compact card showing the score, a status label and a helper message. Your design may differ.

### Step 4: Iterate
1. Check the card: does the score show clearly? Does the label match the score? Does the empty state explain what's missing?
2. Ask the agent to **recommend one small improvement and explain it before editing**. Limit changes to the `storefrontHealth` folder, with no Apex or new metadata.
3. If you like it, ask the agent to build it, deploy it, and preview again.

## Exercise 3: Vibe Code a Merchant Performance Dashboard

### Step 1: Explore and choose a design
1. Switch the **Send mode** to **Plan**.
2. Ask the agent to inspect the project and org before changing anything. It should find the relevant objects, fields, permission sets, LWCs, Apex classes and tabs. Ask for **2 or 3 first-version dashboard designs**, each with the question it answers, the data it uses, the first useful version, and its assumptions and risks. End with: **"Do not edit files yet."**
3. Review the designs. Optionally ask which gives the most useful first version with the least risk while still using live data.

**Expected:** design options. Your results may differ from classmates'.

### Step 2: Ask for a lightweight build plan
1. Still in Plan mode, ask for an implementation plan that:
   - uses existing `Storefront__c`, `Order__c` and `Review__c` metadata
   - creates no new custom fields or objects, and changes no existing LWCs, Apex classes or objects
   - plans four artifacts:
     - LWC `merchantPerformanceDashboard`
     - Apex class `MerchantPerformanceController` that reads the three objects
     - a custom tab
     - a permission set
2. Check the plan: it states its assumptions, starts simple, avoids unnecessary fields, and includes a deployable path. If it's too complex, ask for a simpler first release with **storefront KPIs and a storefront table** only.

### Step 3: Build the first version
1. Click **Approve Plan** to switch to Chat mode.
2. The build should create **only four new files**:
   - the LWC
   - the Apex controller, declared `with sharing`, with one `@AuraEnabled(cacheable=true)` method
   - a tab labelled **Merchant Performance**
   - a permission set named `Merchant_Performance_Dashboard_Access`

   It should not create custom fields, objects, flows or test classes, and should not change existing files.
3. Deploy if the agent hasn't.
4. Preview the component: **Validate your changes** → **Preview Locally**. Or right-click the `.html` file → **SFDX: Open in Lightning Preview**.

### Step 4: Open and test the app
1. Ask the agent to assign `Merchant_Performance_Dashboard_Access` to your user. It should change no metadata.
2. Click **Open Default Org in Browser** → **App Launcher** → search **Merchant Performance**.
3. Check:
   - Does it load without errors?
   - Do the KPIs and table use live data?
   - Does it show total orders, revenue and average review score per storefront?
   - Does it explain what the numbers mean?
   - What's one obvious next improvement?

If something is wrong, paste the error into the chat and ask for a fix.

### Step 5: Iterate
1. Pick one improvement: better empty and error states, an order volume or revenue trend chart, row-level follow-up actions, or a way to flag a storefront for review-score follow-up.
2. Ask for the smallest safe change and an explanation **before** any edits.
3. Build it, changing only `merchantPerformanceDashboard` and `MerchantPerformanceController`. Create no new fields or objects.
4. Deploy, refresh the dashboard, and verify.

---

# Module 3: Build a Multi-Framework App with React

**Goal:** build a React app called **Merchant Operations Center** with Agentforce Vibes. It starts with mock data, adds interactivity, connects to live Pronto data, and deploys into your org.

**Prerequisite:** Module 2, Exercise 1 (Vibes launched and set up).

## Exercise 1: Create the App Shell and Mock Data

### Step 1: Create the project
1. Open **Agentforce Vibes** from Setup. Open the sidebar.
2. Close any open chats. Click **New Project** → select **React App** → **Create a Project**.
3. Select **Internal User App**.
4. Project name: `merchant-operations-center`. Click **Create Project**.

The project contains:
```txt
force-app/main/default/
├── applications/
│   └── merchantoperationscenter.app-meta.xml
├── permissionsets/
│   └── merchantoperationscenter_Access.permissionset-meta.xml
└── uiBundles/
    └── merchantoperationscenter/
        ├── merchantoperationscenter.uibundle-meta.xml
        ├── package.json
        └── src/
```

Nothing is in your org yet. You deploy in Exercise 4.

### Step 2: Install and run the starter app
1. Accept the extension terms and click **Enable Agentforce**.
2. Open **Terminal → New Terminal** (it opens in the project root).
3. Run:
   ```bash
   npm install
   cd force-app/main/default/uiBundles/merchantoperationscenter
   npm install
   ```
   npm warnings about vulnerabilities and engines are normal. **Don't** run `npm audit fix --force`, because it can break the project.
4. Click the **Preview** button at the top of the Vibes extension. It starts the Vite dev server.
5. When asked to select a UI Bundle, choose **merchantoperationscenter**.

**Expected:** the starter app shows a **React App** header and a Home page.

### Step 3: Build the app shell
1. Switch to **Plan** mode. Ask Vibes to turn `merchant-operations-center` into the **Merchant Operations Center**. The first version should have:
   - the app title "Merchant Operations Center"
   - a header, page title and empty main area
   - clean, Salesforce-style design
2. Review the plan, approve it, and switch back to **Chat**.
3. Approve any setup, install or build commands Vibes asks for.

**Expected:** Live Preview shows the **Merchant Operations Center** header.

### Step 4: Add mock storefront data
Ask Vibes to show storefronts as a list or card grid. Each has `storefrontName`, `cuisine`, `city`, `ordersToday`, `revenue`, `avgRating` and `openOrders`.

Preview. If the layout is crowded, ask Vibes to simplify it.

### Step 5: Add summary cards
Ask for summary cards that calculate from the mock data: **Total Storefronts**, **Orders Today**, **Total Revenue**, **Average Rating**, **Open Orders**.

**Check:** the cards match the list. If a metric is wrong, ask for a fix.

### Step 6: Add status labels
Ask for a status label on each card, based on `avgRating`:

| Label | Rating |
|---|---|
| Strong | 4.5 or higher |
| Healthy | 4.0 to 4.4 |
| Needs Attention | 3.0 to 3.9 |
| At Risk | below 3.0 |

These cutoffs match the **Review Storefront Health** flow from Module 1. If a label doesn't match its rating, paste the example into Vibes and ask it to fix the calculation.

## Exercise 2: Add Interactivity

Use these prompts in order. Preview and test after each one.

1. **Cuisine filters**
   ```txt
   Add cuisine filters to Merchant Operations Center.

   Users should be able to filter storefronts by:
   - All
   - Italian
   - Mexican
   - Asian
   - American

   The summary cards should update based on the filtered storefronts.
   ```
   **Check:** the list and summary cards update together.

2. **Search**
   ```txt
   Add search to Merchant Operations Center.

   Users should be able to search storefronts by name.

   Search should work together with the cuisine filter.

   The summary cards should update based on the visible storefronts.
   ```
   **Check:** search works with a cuisine filter selected. If not, ask Vibes to fix the combined logic.

3. **Sorting**
   ```txt
   Add sorting to Merchant Operations Center.

   Users should be able to sort storefronts by:
   - Revenue
   - Orders Today
   - Average Rating

   Sort should work together with search and cuisine filtering.
   ```
   **Check:** each sort reorders the list and keeps the active search and filter.

4. **Pagination**
   ```txt
   Add pagination to Merchant Operations Center.

   Show 6 storefronts per page.

   Users should be able to move to the next page and previous page.

   Pagination should work together with cuisine filtering, search, and sorting.

   The summary cards should continue to calculate from all visible filtered results, not just the current page.
   ```
   **Check:** 6 per page, Prev/Next work, and the summary cards cover the full filtered set.

5. **Detail panel**
   ```txt
   Add a storefront detail panel.

   Extend the mock storefront data with these additional fields:
   - manager
   - phone
   - address
   - hoursToday
   - weeklyRevenueTrend (last 7 days of revenue)

   When a user selects a storefront, show a detail panel with the storefront name, cuisine, and the new fields above.

   Keep the list visible while the detail panel is open.
   ```
   **Check:** the panel opens beside the list and updates when you pick another storefront.

## Exercise 3: Connect to Salesforce and Add Workflow

### Step 1: Replace mock data with Salesforce data
Ask Vibes to connect the app to Salesforce. The prompt should:
- load `Storefront__c` records directly
- calculate, per storefront: name, cuisine, city, Orders Today, **Average Monthly Revenue** (total revenue divided by the number of distinct months with orders), Average Rating from `Average_Review_Score__c`, and Open Orders
- keep the filters, search, sorting, summary cards and detail panel
- add loading and error states
- avoid "today" or rolling date windows, because the sample `Order__c` data covers only April 2026 and July 2026

Review the approach Vibes picks. Approve metadata changes only after you've read them.

> **Data SDK notes:** data comes through GraphQL on UI API, so Salesforce sharing and field rules apply. Apex is reached only through Apex REST endpoints, not `@AuraEnabled` methods. Responses are cached for 5 minutes, and writes don't refresh the cache, so refresh it manually after saving.

### Step 2: Show related orders
Ask Vibes to add to the detail panel, regardless of order date:
- **Open Orders** and **Completed Orders** tabs
- for each order: order number, customer name, status, amount and order date

**Check:** the Artisan's Edge Plano panel shows the Open and Completed tabs.

### Step 3: Add recommended next actions
Ask for recommendations with these rules:
- Average rating 4.5 or higher → feature the storefront in the app.
- High open orders with low revenue → review order fulfillment.
- Average rating below 3.5 with low review count → flag for closer monitoring, not immediate action.
- Average rating below 3.5 with high review count → schedule a storefront performance review.

**Check:** the recommendation changes when you select storefronts at different performance levels.

### Step 4: Polish the UI
Ask for layout and styling improvements, with no new features:
- better spacing, card layout, typography, empty states and responsive behavior
- the detail view as a **centered modal** with a sticky header, scrollable body and sticky footer. The footer must sit outside the scrollable area: the container is `flex flex-col`, the body is `flex-1 overflow-y-auto`, and the footer is a sibling with `shrink-0`.

**Check:** preview on a wide and a narrow screen. Filters, search, sorting, the modal, orders and recommendations all still work.

### Step 5: Create a follow-up task from the modal
Ask Vibes to add a **Create Follow-Up Task** button to the modal footer. It should:
- open a form modal with the same flex layout
- have fields for Subject, Due date, Priority and Comments
- default the Subject from the recommended action
- create a Task in Salesforce linked to the selected `Storefront__c`
- show success and error states

**Check:** save a test task and confirm the success message. Then find the task on the storefront record in Pronto.

## Exercise 4: Deploy to Your Salesforce Org

1. **Review what will deploy.** Ask Vibes to summarize what must go to the org: the React app files, the required metadata, a permission set, the assignment command and the deploy command. **Tell it not to deploy yet.** If unrelated items show up, limit the scope to the React app and its required metadata.
2. **Deploy.** Ask Vibes to use the Salesforce Multi-Framework React deploy path. It should run the build and deploy, and diagnose and fix any failures before redeploying. Approve the commands it needs.
3. **If it errors,** read the explanation before approving a fix.
4. **Create app access metadata** (skip if Step 2 already did this). Ask Vibes to:
   - create or update the `CustomApplication` for the UI Bundle, linked through the `uiBundle` field, labelled **Merchant Operations Center**
   - create a matching permission set with only the object, field, Apex and tab access the app needs
   - deploy both and assign the permission set to your user

   **Expected:** the custom application and permission set deploy successfully.
5. **Open and test the app.**
   1. Click **Open Default Org in Browser**.
   2. Open the **App Launcher** and search **Merchant Operations Center**.
   3. Confirm storefront data loads.
   4. Test the workflow: filter, search, sort and paginate; open the detail modal; review Orders and recommended actions; create a follow-up task.
6. **Fix problems.** Paste the error into Vibes. Ask it to diagnose the likely cause, explain the smallest safe fix, update the project and redeploy. Then retest.

**Done when:** the Merchant Operations Center opens from the App Launcher and the full workflow works.

---

# Module 4: Give Agents UI with the Headless Experience Layer (HXL)

**Goal:** replace the plain-text answer from the **Employee Assistant** agent with a rich storefront profile card. The same JSON widget renders in Agentforce and through an MCP server.

**Key terms**
- **Widget (`UiWidgetBundle`):** a declarative tile tree with attribute placeholders. Built once, used everywhere.
- **Lightning Type:** describes an action's output and points to the widget through a renderer.
- **MCP server definition:** exposes the action as an MCP tool that renders the same widget.
- **Agentforce** needs one Lightning Type. **MCP** needs two nested Lightning Types, and only the outer one carries a renderer.

> **Beta:** HXL is a beta feature under the Beta Services Terms or a signed pilot agreement. Check with your instructor before running it.

## Exercise 1: Set Up and See the Baseline

### Step 1: Enable HXL
1. Setup → Quick Find **headless** → **Headless Experience Layer Settings** (Feature Settings).
2. Turn on **Headless Experience Layer (Beta)**.

### Step 2: Prepare Agentforce Vibes
If Vibes is already launched, its MCP servers are active and Bypass mode is set, skip to substep 5.
1. Setup → **MCP Servers** → **Salesforce Servers**. Activate each of these (skip any already active):
   - salesforce-api-context
   - metadata-experts
   - Headless360 (H360) MCP Server
2. Setup Menu → **Agentforce Vibes** → accept the terms. Initialization takes a few minutes.
3. In the sidebar, click **I agree to the terms**, then **Enable Agentforce**. Don't reload while it loads.
4. Click the **Settings** icon. Set **Default session mode** to **Bypass (trust all)** → **Back**. Check it at the start of each exercise, because Vibes can reset it on reload.
5. **Toolkit** tab → **Skills**. Check that `sf-skills` includes:
   - `platform-lightning-type-widget-coordinate`
   - `platform-mcp-tool-widget-coordinate`
   - `platform-widget-generate`
   - `agentforce-generate`

   They're in the collapsed **Platform** group. Expand it or search. Click **Back**.
6. Open the **Integrated Terminal** and run:
   ```bash
   sf update
   ```
   Then run the AgentScript SDK setup that the `agentforce-generate` skill uses. Your instructor will give you the exact command for your environment. It prints JSON that includes the installed SDK version.

### Step 3: Create an External Client App for the Playground
A new ECA can take up to 30 minutes to become available, so create it now. If `Workshop MCP Client` already exists, skip to Step 4.
1. **Verify your email:** Setup → Users → **EPIC, OrgFarm** → **Edit**. Replace the email with yours and **Save**. Click the verification link in the email.
2. **Permission set:** Setup → **Permission Sets** → **New**. Label `MCP Client User`, then **Save**. **Manage Assignments → Add Assignments**, select **EPIC, OrgFarm**, then **Assign**.
3. **ECA:** Setup → **External Client App Manager** → **New External Client App**:

   | Setting | Value |
   |---|---|
   | External Client App Name | `Workshop MCP Client` |
   | API Name | `Workshop_MCP_Client` |
   | Contact Email | your email |
   | Enable OAuth | ticked |
   | Callback URL (Playground) | `https://mcp-playground-360-lb-75bfc079c1f3.herokuapp.com/oauth/sf/callback` |
   | Callback URL (Claude) | `https://claude.ai/api/mcp/auth_callback` |
   | OAuth scopes | Perform requests at any time (`refresh_token, offline_access`); Access Salesforce hosted MCP servers (`mcp_api`) |
   | JWT access tokens for named users | ticked |

   Check the values, then **Create**.
4. **Restrict access:** the **Policies** tab → **Edit** → **OAuth Policies**. Set **Permitted Users** to **Admin approved users are pre-authorized** → **OK**. Move **MCP Client User** to **Selected Permission Sets** → **Save**.

You'll copy the Consumer Key and Secret in Exercise 4.

### Step 4: See the baseline
1. In your org, open the **Agentforce** panel (titled **Employee Assistant**). Dismiss any **Agentforce Memory** or **Got It** dialog.
2. Ask:
   ```txt
   Tell me about Artisan's Edge Uptown.
   ```
   **Expected:** a plain-text reply with the address and average review score. For example: "Artisan's Edge Uptown is located at 404 Uptown Way, Dallas, TX 75201. It has an average review score of 4.4 out of 5 from 5 reviews." The wording varies.
3. Ask:
   ```txt
   Tell me about Harvest Grill.
   ```
   **Expected:** another plain sentence. Harvest Grill is **Suspended**, and nothing visual or actionable appears.

## Exercise 2: Generate the Widget and Lightning Type

### Step 1: Plan the build
Timing with Bypass mode: about 1 minute to retrieve, 1–2 minutes to plan, about 5 minutes to build and deploy. Your only click is **Approve Plan**.

1. Open the Vibes sidebar. Start a **New chat** if needed. Reconfirm **Bypass (trust all)**.
2. In **Chat** mode, ask Vibes to create `manifest/package.xml` and run:
   ```
   sf project retrieve start --manifest manifest/package.xml && rm -r manifest
   ```
   The manifest includes the Apex classes `GetStorefrontFromNameAction` and `GetStorefrontFromNameActionTest`, and the `Employee_Assistant` agent (`AiAuthoringBundle`). The agent is included now, so you won't retrieve it again in Exercise 3.

   **Expected:** the components are retrieved.
3. Set **Send mode** to **Plan**. Ask for a plan using the `platform-lightning-type-widget-coordinate` skill. The goal:
   - an Apex-backed Lightning Type `storefrontProfileCardOutput`
   - an HXL widget `storefrontProfileCard`
   - Apex changes: a `StorefrontDetails` inner class with seven String fields and helper methods; the invocable signature unchanged
   - test changes, file specs and deploy order

   Ask for no more than 10 bullets.
4. Review the plan. It should include:
   - an explicit change to `GetStorefrontFromNameAction`
   - a Lightning Type whose `lightning:type` is `@apexClassType/c__GetStorefrontFromNameAction$StorefrontDetails`
   - three widget files under `uiWidgets/storefrontProfileCard/`, plus a `renderer.json`
   - validations `renderer-wires-widget` and `field-trace`
   - three deploys in order: Apex, widget, Lightning Type

   If something's wrong, reply with a correction.
5. Approve the plan. Vibes switches to Chat and builds. Click **Accept All** if prompted.
6. Read the summary. If any gate reports `fail`, ask Vibes to fix it.

### Step 2: Understand the generated files
| File | What to look for |
|---|---|
| `classes/GetStorefrontFromNameAction.cls` | The `StorefrontDetails` inner class and helpers for `statusVariant`, `ratingLabel` and `address`. Widgets have no JavaScript, so the computing happens here. |
| `uiWidgets/storefrontProfileCard/storefrontProfileCard.json` | The `tile/*` tree. Values are `{!$attrs.<name>}` placeholders. The badge `variant` binds to `statusVariant`. Buttons use `action/sendMessage`. |
| `uiWidgets/storefrontProfileCard/schema.json` | The type of each attribute. No values. |
| `uiWidgets/storefrontProfileCard/storefrontProfileCard.uiwidget-meta.xml` | `<widgetType>JSON</widgetType>`, a declarative widget. |
| `lightningTypes/storefrontProfileCardOutput/schema.json` | `lightning:type` points to the Apex `StorefrontDetails` class. Agentforce uses no envelope. |
| `lightningTypes/storefrontProfileCardOutput/renderer.json` | `componentOverrides.$.definition` set to `@widget/c/storefrontProfileCard`, with one `{!$attrs.<field>}` mapping per attribute. |

Two details that are easy to get wrong:
- The **`"$"` key** tells the platform to render with the widget rather than a default renderer.
- The **`@widget/` prefix** makes the platform look up a `UiWidgetBundle`. Without it, the platform looks for an LWC.

A mismatched attribute name doesn't raise an error. The field just renders blank. The `renderer-wires-widget` and `field-trace` gates catch this.

### Step 3: Preview in the HXL Playground (optional)
1. Ask Vibes for sample data: a JSON object with `$meta.env.orgUrl` and an `$attrs` entry for every attribute, using Artisan's Edge Uptown.
2. Open the HXL Playground: https://www.headlessexperiencelayer.com/. Paste `storefrontProfileCard.json` into **Structure** and the sample data into **Data**.

**Expected:** the card renders. To change the layout, describe the change to Vibes and paste the updated JSON back in. For example: "Make the rating row bold and move the phone row above the address row."

### Step 4: Confirm the deployment
Ask Vibes to confirm that `GetStorefrontFromNameAction`, the `storefrontProfileCard` widget and the `storefrontProfileCardOutput` Lightning Type are in your org. It should deploy anything missing, in this order: Apex classes, widget, Lightning Type.

**Expected:** all three are in the org. Retrieving them adds `id` fields to the local files, which is normal.

## Exercise 3: Render the Widget in the Agent

### Step 1: Update the agent script
1. Open the Vibes sidebar. Start a **New chat** if needed. Set **Default session mode** to **Bypass (trust all)** → **Back**.
2. Ask Vibes to make this change. The key instructions:
   - Use the `agentforce-generate` skill. Don't search for skills, run `sf update`, install anything or retrieve the agent again.
   - Work in `force-app/main/default/aiAuthoringBundles/Employee_Assistant/`.
   - If the retrieve created `Employee_Assistant_N`, copy its `.agent` file into `Employee_Assistant/`, with a `bundle-meta.xml` that has no `<target>`. If it created `Employee_Assistant`, delete the `<target>` line from its `bundle-meta.xml`. Leave any `Employee_Assistant_N` folder alone.
   - In the `browse_storefronts` subagent, update the `getStorefrontFromName` storefront output:
     - `complex_data_type_name: "c__storefrontProfileCardOutput"`
     - `is_displayable: True`
     - `filter_from_agent: False`
   - Change nothing else.
   - Run in order:
     1. validate the script with the skill's local compiler
     2. `sf project deploy start --metadata AiAuthoringBundle:Employee_Assistant`
     3. `sf agent publish authoring-bundle --api-name Employee_Assistant --skip-retrieve`
     4. `sf agent activate --api-name Employee_Assistant`
   - Don't send error output to `/dev/null` on any command.
3. Vibes applies the edit without asking. Click the `Employee_Assistant.agent` chip (+3 −1) to see the diff.

   **Expected:** the `storefront` output changes from `complex_data_type_name: "lightning__recordInfoType"` to the three settings above. Nothing else changes. The `bundle-meta.xml` chip shows the removed `<target>` line.
4. Click **Accept All**.

**Alternative: Agentforce Builder (no Vibes)**
1. Setup → **Agents** → open **Employee_Assistant**.
2. Open the **browse_storefronts** subagent → **Canvas** → **Script**.
3. Replace the `storefront` output of `getStorefrontFromName` with:
   ```txt
   storefront: object
       label: "Storefront"
       complex_data_type_name: "c__storefrontProfileCardOutput"
       filter_from_agent: False
       is_displayable: True
   ```
4. **Save**, then **Commit Version** (confirm), then **Activate**.

### Step 2: Verify in the Agentforce conversation
1. Open the **Agentforce** panel and select **Employee_Assistant** in the Agent Picker. Click **Got It** if you see the first-use screen.
2. Ask:
   ```txt
   Tell me about Artisan's Edge Uptown.
   ```
   **Expected:** a card replaces the plain-text answer. It shows a coloured status badge, cuisine, rating, address and phone, plus **View Menu** and **Check Hours** buttons. The **Customer Reviews** widget may also appear.

   The card isn't guaranteed. If you get text, click **Clear history** → **Clear History**, and ask again. It can take two or three tries.
3. Click **View Menu**.
   **Expected:** the card sends "Show me the menu for Artisan's Edge Uptown," and the agent replies with the menu.
4. Test **Check Hours**: click **Clear history**, ask about Artisan's Edge Uptown again, then click **Check Hours** on the new card.
   **Expected:** operating hours. Each card's buttons work only once.
5. Click **Clear history** before each of these:
   - `Tell me about Harvest Grill.` → **Suspended**, shown with the `error` badge.
   - Ask about **The Green Fork** → **Closed**, shown with the `secondary` badge.

## Exercise 4: Render the Same Widget Through MCP

### Step 1: Generate the MCP Lightning Types
1. Open the Vibes sidebar → **New chat** if needed. Set **Bypass (trust all)** in Settings → **Back**.
2. Set **Send mode** to **Plan**. Ask Vibes to use the `platform-mcp-tool-widget-coordinate` skill. It should:
   - reuse `storefrontProfileCard` without changes
   - create the response Lightning Type `lightningTypes/getStorefrontFromNameResponse/schema.json`
   - create the envelope Lightning Type `lightningTypes/getStorefrontFromName/schema.json`
   - create `lightningTypes/getStorefrontFromName/renderer.json`, which binds the attributes through `outputValues.storefront`
   - skip deployment for now

   **Expected:** a plan of no more than 10 bullets.
3. Check the plan:
   - response type `getStorefrontFromNameResponse`, typed to `@apexClassType/c__GetStorefrontFromNameAction$StorefrontDetails` for `storefront`
   - envelope `getStorefrontFromName`, whose `outputValues` points to `c__getStorefrontFromNameResponse`
   - a root-level `renderer.json` binding attributes such as `{!$attrs.outputValues.storefront.name}`
   - no new widget files
4. Click **Approve Plan**, then **Accept All** if prompted. Check that the validation gates pass. A `field-trace` warning about `storefrontId`, `message` and `isSuccess` is acceptable.

### Step 2: Create the MCP server definition
1. In the same chat, ask Vibes to create `force-app/main/default/mcpServerDefinitions/ProntoStorefrontTools.mcpServerDefinition-meta.xml` with these values:

   | Element | Value |
   |---|---|
   | `masterLabel` | Pronto Storefront Tools |
   | `apiIdentifier` | `aa:apex-GetStorefrontFromNameAction` |
   | `apiSource` | `API_CATALOG` |
   | `operation` | `GetStorefrontFromNameAction` |
   | `uiResource` | `getStorefrontFromName` |
   | `toolName` | `getStorefrontFromName` |
   | `toolTitle` | Get Storefront From Name |
   | `readOnly` | `true` |
   | `resourceUri` | `ui://widget/lightningType/c__getStorefrontFromName` |

   If a deploy rejects an element, stop and report it. Don't remove the element.
2. Open the file and confirm:
   - the `<resources>` entry publishes the envelope at `ui://widget/lightningType/c__getStorefrontFromName`
   - the tool's `uiResource` points to that resource

   The editor may show schema errors for `<McpServerDefinition>`. The deploy still accepts the file.

### Step 3: Deploy and activate
1. Ask Vibes to deploy three items in order, as separate deploys:
   1. the `getStorefrontFromNameResponse` Lightning Type
   2. the `getStorefrontFromName` Lightning Type
   3. the `ProntoStorefrontTools` MCP server definition

   Click **Accept All**. Confirm the server in Setup.
2. Setup → Quick Find **MCP Servers** → **Integrations → API Catalog → MCP Servers** → open **Pronto Storefront Tools**.
3. Check the header: **Tools 1**. If it shows **Tools 0**, check the `<apiDefinition>` element and redeploy.
4. If it isn't active, click **Activate**.
5. Copy the **Server URL**:
   `https://api.salesforce.com/platform/mcp/v1/custom/ProntoStorefrontTools`

### Step 4a: Connect Claude (skip if you're using only the Playground)
1. Setup → **External Client App Manager** → **Workshop MCP Client** → **Settings** → **Consumer Key and Secret**. Enter the verification code and copy both values.
2. Claude → **Customize** → **Connectors** → **Add** → **Add custom connector**.
3. **Name:** `ProntoStorefrontTools`. **MCP server URL:** the Server URL above.
4. **Continue**. Consumer Key as **OAuth client ID**, Consumer Secret as **OAuth client secret**.
5. **Connect**, log in and approve.

### Step 4b: Connect the Playground
1. Get the Consumer Key and Secret (as in 4a, step 1). Copy your **My Domain URL** from Setup → **My Domain**.
2. Open the Playground, sign in with your instructor's credentials, click **Connect**. Enter the My Domain URL, Consumer Key and Secret. Click **Connect** and authorize.

   If you see `invalid_client_id`, wait a few minutes and try again.
3. **Servers** tab → **Add server**:
   - **Name:** `ProntoStorefrontTools`
   - **MCP server URL:** the Server URL above
4. **Test connection**. Confirm `getStorefrontFromName` is in the list, then **Add server**.

### Step 5: See the card in Claude or the Playground
1. Start a new chat (Claude: **New**. Playground: **Chat** → **New chat**).
2. Enable the server: Claude: **+** → **Connectors** → turn on **ProntoStorefrontTools**. Playground: **Tools** → **PRONTOSTOREFRONTTOOLS**.
3. Send: `Tell me about Artisan's Edge Uptown.` Click **Always allow** if asked.

**Expected:** the same `storefrontProfileCard` as in Agentforce, with the same badge colours, rows and buttons.

---

# Module 5: Get Started with Salesforce in Claude

**Goal:** install the Sales Cloud plugin, and use Claude to explore accounts, deals and the pipeline.

**Requirement:** complete Module 1, Exercise 1, plus either 2a (Claude) or 2b (Playground).

> **Paid and beta:** the workshop page says Salesforce in Claude **requires a direct Anthropic subscription, such as Claude Enterprise**, and is in beta. Students without that can use Exercise 2 in the AIforce Playground.

## Exercise 1: Set Up Salesforce in Claude
*Requires beta access and Claude Enterprise or a personal Claude account.*

### Step 1: Request beta access
1. Fill in the Sales Cloud in Claude beta access form: https://agentexchange.salesforce.com/sales-cloud-in-claude-beta-access
2. When approved, you receive the plugin as a ZIP file (for example `salesforce-for-sales-1.0.0-beta.2.1.claude-plugin.zip`). Save it.

### Step 2: Upload the plugin
> On Claude Enterprise, your Claude admin sets up the plugin in organization settings. The steps below are for a personal account.

1. claude.ai → **Customize** → **Plugins** → **Add** → **Upload plugin**.
2. Under **Plugin file**, select the ZIP. Under **Preview**, confirm the plugin is `salesforce-for-sales`. Click **Upload**.
3. On the **Sales Cloud** plugin page, check that the toggle is **on** and **Salesforce** is listed under **Connectors & tools**.

### Step 3: Ask about your pipeline
1. On the **Sales Cloud** plugin page, click **Try in chat**.
2. Prompt:
   ```txt
   Can you tell me about my team's pipeline?
   ```
   Click **Always allow** if asked.
3. Watch Claude make several Salesforce calls to find your team and pipeline data.

   **Expected:** an interactive pipeline view with suggested next actions. It shows a Salesforce card with Q4 closed, commit and best-case totals, and a stacked bar chart by rep.
4. Prompts:
   ```txt
   Can you tell me about my record hygiene?
   ```
   ```txt
   Can you draft an account plan for Harvest Table Hospitality?
   ```

### Step 4 (optional): Explore more skills
The plugin includes 34 skills. Each prompt triggers a different one:

| Skill | Prompt | Expected |
|---|---|---|
| Account plan | `Draft an account plan for Harvest Table Hospitality.` | Account plan |
| Expansion whitespace | `Where's the whitespace across the Harvest Table Hospitality family?` | Points to the Southeast division |
| Stakeholders | `Map the stakeholders at Harvest Table Hospitality.` | Stakeholder map |
| Deal review and close plan | `Review the Harvest Table 180-location rollout and build a close plan.` | Deal review and close plan |
| Call prep | `Prep me for today's Coastal Burger Co. security review.` | Flags that the review is blocked and names the competitor |
| Renewals and health | `Which renewals are at risk?` or `How healthy is Metro Arena Concessions?` | Sunrise Bakery Cafe is at risk (escalated POS menu-sync case). Metro Arena Concessions is healthy, worth about $2.0M. |
| Daily briefing | `What's on my plate today?` | Today's priorities |
| Team quarter | `How is my team tracking this quarter?` | Diego ahead of target, Owen behind |
| Leads | `Triage my open leads.` | Lead triage |

## Exercise 2: Explore Sales Cloud in Claude in the AIforce Playground
*No Claude subscription needed.*

**Prerequisites:** Module 1, Exercise 1, and Exercise 2b. Log in so the Sales Cloud skills are available in each new chat.

1. Open https://mcp-playground-360-lb-75bfc079c1f3.herokuapp.com/plugins → the **Plugins** tab → open **Sales Cloud**.
2. Review the skills and what each does.
3. **Chat** tab → **New chat**. The skills are available automatically. Check the skills menu: it's on **Auto** by default, so the model picks the right skill.
4. Prompt:
   ```txt
   Can you tell me about my team's pipeline?
   ```
   **Expected:** the model picks the `team-pipeline` skill and pulls users and opportunities through the Headless 360 server. This can take about a minute. An interactive Team Pipeline card appears with closed revenue and a stacked bar chart by rep. The card is built with HXL.
5. Try these, noting which skill runs each time:
   ```txt
   Can you tell me about my record hygiene?
   ```
   ```txt
   Can you draft an account plan for Harvest Table Hospitality?
   ```
6. Optional: use the Module 5, Exercise 1 table above with the same prompts.

---

# Quick Checklist

Tick these off as you go.

- [ ] Logged in to the workshop org
- [ ] Explored Pronto (Storefronts, Ethan Kim, Orders)
- [ ] Module 1: ECA created, permission set assigned, Consumer Key and Secret saved, SObject All and H360 activated
- [ ] Module 1: connected to Claude **or** the Playground, and ran the data-model prompts
- [ ] Module 1: custom MCP server **ProntoOrderTools** created, with 4 tools, and both test prompts pass
- [ ] Module 2: Vibes launched, Storefront Performance Score field and Storefront Health LWC deployed
- [ ] Module 2: Merchant Performance Dashboard built and open in the App Launcher
- [ ] Module 3: Merchant Operations Center deployed, filters, search, sort, pagination, modal and follow-up task all work
- [ ] Module 4: HXL enabled, Employee Assistant shows the storefront card, MCP server **Pronto Storefront Tools** shows 1 tool
- [ ] Module 5: Sales Cloud skills run in Claude **or** the Playground

---

# Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `invalid_client_id` | ECA not active yet, or the callback URL is missing | Wait up to 30 minutes. Check both callback URLs are in the ECA. |
| Verification code email never arrives | Email not verified | Redo Module 1, Exercise 1, Step 1 |
| Vibes extension won't activate on Windows | Visual C++ Redistributable missing | Install it, then restart VS Code |
| Vibes resets to "Ask" mode | Vibes reloaded | Set **Bypass (trust all)** again |
| Tools greyed out in Claude or the Playground | "Auto-select tools" on | Turn it off in the Tools panel |
| Server shows **Tools 0** | Missing `<apiDefinition>` | Check the element and redeploy |
| HXL card doesn't appear | Agent answered in text | Clear history and ask again, up to three times |
| Widget fields are blank | Attribute name mismatch in `renderer.json` | Check the `renderer-wires-widget` and `field-trace` gates |
| App data looks stale | Data SDK caches responses for 5 minutes | Refresh manually after saving |

---

# Glossary

| Term | Meaning |
|---|---|
| **Pronto** | The sample merchant app in the workshop org |
| **Storefront__c** | A restaurant location |
| **Order__c** | An order placed at a storefront |
| **Review__c** | A customer review of a storefront |
| **ECA** | External Client App, which handles OAuth for MCP clients |
| **MCP** | Model Context Protocol, a standard for AI tools |
| **SObject All** | Hosted MCP server for record queries and updates |
| **Headless360 (H360)** | Hosted MCP server for metadata and records |
| **HXL** | Headless Experience Layer, which builds declarative UI widgets |
| **Lightning Type** | Describes an action's output and how to render it |
| **Bypass (trust all)** | Vibes mode in which the agent acts without asking |
