# 10. Connect Claude to Claudeforce: plugin, connector, and skills setup

## Three pieces, three owners

Setting up Claudeforce involves three things that people often mix up:

1. **The connector.** This links Claude to your Salesforce org through MCP. The admin sets it up once for the organization.
2. **The plugin.** This is the package of skills and settings. Each user adds it from their own Settings.
3. **The skills.** These are the playbooks Claude follows for tasks like pipeline review. They arrive with the plugin.

If something is missing, work out which of the three it belongs to before you start clicking. A user cannot fix a missing connector, and an admin cannot add a plugin for someone else.

## Admin steps

1. Confirm the org is eligible and request beta access through AgentExchange.
2. When the acceptance email arrives, follow the linked Salesforce help article.
3. In Claude, choose the installation preference for your organization.
4. Connect the Salesforce MCP connector using an account with owner-level access.

## User steps

1. In Claude, go to Settings, then Plugins.
2. Open the Salesforce plugin and choose **Add to Claude**.
3. Sign in with your own Salesforce account when asked.
4. Open the plugin for the first time. A setup skill runs by itself. It asks about your role and book of business, then tunes the other skills to match.

Take the setup skill seriously. If you say you own enterprise accounts but the skills assume SMB, every later summary will be off.

## Checks after setup

- Ask for a short summary of your own open opportunities. You should see only your records.
- Ask a question about an account you do not own. The answer should reflect what you can see in Salesforce, not what your manager can see.
- Confirm the skill list includes the sales skills before you move on.

## Troubleshooting

- **Plugin shows but returns nothing.** Usually the Salesforce sign-in was skipped or used the wrong user.
- **Skills missing after an update.** Remove and re-add the plugin, then start a new chat.
- **Admin steps stall.** The help article is the source of truth. Check it before escalating.

## Try it

Set up the plugin for yourself, then take a screenshot of the skill list. Compare it with the list in the help article. Note any difference and the date you checked.
