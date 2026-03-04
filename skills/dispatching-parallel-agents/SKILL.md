---
name: dispatching-parallel-agents
description: Use when facing 2+ independent tasks that can be researched or implemented by agents without shared state or sequential dependencies
tags: [process, parallel, agents, orchestration]
triggers: [multiple independent tasks, parallel research, concurrent investigation, fan-out work]
chains_to: [verification-before-completion]
priority: core
gate: false
---

# Dispatching Parallel Agents

## Quick Reference

When you have 2+ truly independent tasks, launch them as parallel agents in a single message. You orchestrate the fan-out and fan-in. Keep the main context clean.

## When to Use

- 2+ research questions that don't depend on each other
- Independent code investigations across different parts of the codebase
- Multiple review tasks (security, performance, patterns) on the same diff
- During plan execution when independent steps are identified

## When NOT to Use

- Tasks have dependencies (agent B needs agent A's result)
- Single task that's just large (use one focused agent instead)
- Tasks that need conversational context (agents start fresh)
- The overhead of dispatching exceeds just doing it sequentially

## Core Process

### Step 1: Identify Independent Work

Tasks are independent when:
- Agent A's result doesn't change agent B's task
- They don't modify the same files
- They don't need to coordinate
- Order doesn't matter

### Step 2: Write Agent Briefs

Each agent gets a self-contained prompt:

```
You are tasked with [specific goal].

Context:
- [Relevant background]
- [Files to look at]

Task:
- [Concrete steps]

Output:
- [What to return — findings, code, recommendations]

Constraints:
- [What NOT to do]
- [Read-only? Implementation? Research only?]
```

Be explicit about whether the agent should:
- **Research only**: Read, search, analyze — return findings
- **Implement**: Write code, create files — return what was changed
- **Review**: Analyze code quality — return findings

### Step 3: Dispatch in Parallel

Launch ALL independent agents in a **single message** using multiple Agent tool calls:

```
[Agent 1: Research authentication patterns]
[Agent 2: Research database migration options]
[Agent 3: Review existing API structure]
```

Use appropriate agent types:
- `Explore` — for codebase exploration and research
- `general-purpose` — for implementation or complex multi-step tasks
- Specialized types — for domain-specific reviews

### Step 4: Fan-In

After all agents return:
1. Summarize each agent's findings
2. Look for conflicts or contradictions between agents
3. Synthesize a unified recommendation or proceed with implementation

### Step 5: Decide Next Action

Based on agent results:
- All research complete → proceed with plan/implementation
- Implementation complete → chain to verification
- Contradictions found → resolve, potentially re-dispatch

## Dispatch Patterns

### Research Fan-Out
```
Agent 1: "How does auth work in this codebase?"
Agent 2: "What database patterns are used?"
Agent 3: "What test patterns exist?"
→ Synthesize into a plan
```

### Review Fan-Out
```
Agent 1: "Security review of this diff"
Agent 2: "Performance review of this diff"
Agent 3: "Pattern compliance review of this diff"
→ Merge findings, prioritize by severity
```

### Implementation Fan-Out
```
Agent 1: "Implement component A in worktree"
Agent 2: "Implement component B in worktree"
→ Merge worktrees, integration test
```

## Anti-Patterns

| Anti-Pattern | Why It's Wrong |
|--------------|----------------|
| Dispatching dependent tasks in parallel | Agent B will miss Agent A's output |
| Launching agents sequentially when they could be parallel | Wastes time. Use one message, multiple tool calls. |
| Duplicating work between main context and agents | If you delegate, don't also do it yourself |
| Too many agents at once (>5) | Diminishing returns, harder to synthesize |
| Vague prompts | Agents need concrete, self-contained tasks |
| Not synthesizing results | Raw agent output isn't useful. Summarize and decide. |

## Chaining

OPTIONAL: syntaxninja-dojo:verification-before-completion (after implementation agents complete)
OPTIONAL: syntaxninja-dojo:subagent-driven-development (for implementation-focused parallel work)
