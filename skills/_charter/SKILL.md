---
name: dojo-charter
description: Use when starting any session — establishes how to find and use skills, requiring Skill tool invocation before ANY response
---

<EXTREMELY-IMPORTANT>
You have the SyntaxNinja Dojo plugin. It makes you a better engineer automatically.

IF A SKILL APPLIES TO YOUR TASK, YOU MUST USE IT. THIS IS NOT OPTIONAL.
</EXTREMELY-IMPORTANT>

# Dojo Charter

## The Rule

**Before every response, consult `skills/index.json`. Load the 1-3 best-matching skills via the Skill tool. Follow them.**

If no skills match with confidence, gate skills influence your behavior silently — respond normally.

## How to Find Skills

1. Read `skills/index.json` — match the current task against skill `triggers` and `description` fields
2. If 1+ skills match clearly → load them via the Skill tool and follow them
3. If 0 skills match → gate skills influence behavior silently, respond normally
4. If ambiguous (multiple plausible matches, not weak matches) → gate skills only, mention which skills *might* apply

**Do NOT load skills speculatively.** Only load skills that clearly match the current task.

## Gate Skills (Invisible Unless Triggered)

Four skills influence EVERY task, but they are **silent unless their trigger fires**. Do NOT explain or announce gate skills on every turn.

| Gate Skill | Surfaces When | Silent Otherwise |
|-----------|---------------|------------------|
| `verification-before-completion` | About to claim work is done | Yes — no mention needed |
| `self-review` | After implementation, dispatches the sensei | Yes — no mention needed |
| `systematic-debugging` | Error, bug, or unexpected behavior occurs | Yes — no mention needed |
| `scope-control` | Always silent — prefer smallest viable change set | Always silent |

**Gate skills influence behavior, not output.** They don't need to be announced or explained unless their specific trigger fires.

## Decision Flowchart

```
Task received
│
├─ Is this a greeting / question about the plugin? → Respond directly
│
├─ Is this a bug / error / unexpected behavior?
│   └─ YES → invoke: systematic-debugging
│       └─ Fix found → invoke: test-driven-development (if available)
│           └─ Fix verified → invoke: verification-before-completion
│               └─ self-review (sensei)
│                   └─ Done → propose: compound-docs (lesson learned)
│
├─ Is this a new feature or significant change?
│   ├─ Requirements clear?
│   │   ├─ NO → invoke: brainstorming
│   │   └─ YES ↓
│   ├─ invoke: writing-plans
│   ├─ Scope assessment:
│   │   ├─ Fits in one session → invoke: executing-plans
│   │   │   └─ (uses subagent-driven-development if parallelizable)
│   │   └─ Too large for one context window
│   │       AND decomposes into pass/fail stories
│   │       AND has clean iteration boundaries
│   │       → invoke: ralph-loop (training loop escalation)
│   └─ Implementation complete
│       → invoke: verification-before-completion
│       → invoke: self-review (sensei)
│       → invoke: finishing-a-development-branch
│
├─ Is this a code review request?
│   ├─ Giving review → invoke: requesting-code-review
│   │   └─ (dispatches parallel review agents)
│   └─ Received feedback → invoke: receiving-code-review
│
├─ Is implementation complete / claiming "done"?
│   └─ invoke: verification-before-completion
│       → invoke: self-review (sensei)
│
└─ Did we just solve a hard problem?
    └─ propose: compound-docs (lesson learned)
```

## Patterns (Forms)

In addition to skills, check `patterns/index.json` for code pattern matches:

### Library Patterns
1. **During implementation**: If you're about to write code that matches a pattern's `detect` or `signatures` fields, load the PATTERN.md and follow it
2. **During self-review**: The sensei checks patterns automatically

Pattern matching uses 3 signals: `detect` (import strings), `file-globs`, `signatures` (API usage). Match on 2 of 3.

### Structure Patterns

Structure patterns (`type: "structure"`) have broad file-globs and no import signals. To prevent constant noise, apply them **only** during:
- New file creation or directory changes
- Moving/renaming files
- Sensei review when the diff includes path changes

Do NOT apply structure patterns during routine edits to existing files.

## Skill Priority

When multiple skills could apply:

1. **Gate skills first** — always active (silently), never skipped
2. **Process skills second** — debugging, TDD, verification
3. **Planning skills third** — brainstorming, writing-plans
4. **Execution skills last** — executing-plans, ralph-loop

## Red Flags

These thoughts mean STOP — you're rationalizing skipping skills:

| Thought | Reality |
|---------|---------|
| "This is just a simple question" | Check the index first. It takes 1 second. |
| "I need more context first" | Skills tell you HOW to gather context. |
| "Let me just do this quick thing" | Gate skills still apply to quick things. |
| "The skill is overkill for this" | Simple things become complex. Skills prevent that. |
| "I'll check skills after" | Before. Always before. |
| "I know what to do" | Knowing ≠ following the discipline. Check anyway. |

## Plugin Identity

**Fingerprints** (emitted as both for interop with other routers):
```
PLUGIN_ROUTER: syntaxninja-dojo@<version>
DOJO_ROUTER: syntaxninja-dojo@<version>
```

If you see **another** `DOJO_ROUTER:` or `PLUGIN_ROUTER:` fingerprint from a different plugin:
1. Switch to **compat mode**: enforce gate skills only (verify, self-review, debug, scope)
2. Do NOT take over planning/execution unless the user explicitly invokes a syntaxninja-dojo skill
3. Log once: "Multiple routers detected. SyntaxNinja Dojo running in compat mode — gate skills only."

## Project Configuration

Config file is `dojo.config.md` at the repo root (discoverable in PRs). Falls back to `.claude/dojo-config.md` for backwards compatibility.

## How to Access Skills

Use the `Skill` tool. When you invoke a skill, its content is loaded — follow it directly.

**Never use the Read tool on skill files.** Always use the Skill tool.

Cross-references between skills use the `syntaxninja-dojo:skill-name` namespace.
