# 25. Creating an Agentforce agent for headless AI experiences

## What this lesson adds

So far the tools you built answer single questions. An agent can chain them: look up an account, check its open cases, then draft a summary. An Agentforce agent is where that chaining happens. The agent decides which actions to run and in what order, based on the instructions you give it.

For headless use, the agent does not have to live in a Salesforce page. Its capabilities can be reached from outside, which is what the rest of this section depends on.

## Parts of an agent

- **Instructions.** What the agent is for, in plain language. Say what it should not do.
- **Actions.** The tools it can call, such as a Flow, an Apex action, or a prompt template.
- **Topics or scope.** The kinds of request it should handle. Keep this narrow.

A narrow agent with five well-described actions is easier to trust than a broad one with twenty.

## Build order

1. Write down one job for the agent in one sentence.
2. Pick the actions it needs. If an action is not needed for that job, leave it out.
3. Write the instructions. Include what to do when the data is missing.
4. Test each action alone before you give it to the agent.
5. Test the agent with a request that needs two actions in sequence.

## Instructions that work

Write them as if briefing a new colleague. Include the order of steps and the stop conditions. For example: "Look up the account first. If there is no match, ask the user to confirm the name before you go further."

## Example (illustrative)

An agent answers "Give me the status of Bluebird's open orders." Its instructions tell it to find the account, then fetch orders, then summarize. If two accounts match, it should ask which one. Without that instruction, it may pick the first match silently.

## Try it

Write a one-sentence job and three instructions for an agent that does one task in your org. Run it on a real request and note every point where it guessed.
