---
date: 2026-03-03
topic: syntaxninja-dojo
type: architecture-design
status: draft-v5
---

# SyntaxNinja Dojo

**Train your AI to write disciplined code.**

A Claude Code plugin that combines auto-invoked workflow discipline (superpowers), multi-agent specialist review (compound engineering), and autonomous looping for large tasks (ralph) — all invisible to the user. No slash commands. No ceremony. Just clean, pattern-driven engineering.

---

## Dojo Glossary

The Dojo brand adds flavor in documentation and UX. The file system uses standard developer terminology.

| Standard Term | Dojo Flavor (docs only) | File/Code Name |
|---------------|------------------------|----------------|
| Skills | Katas | `skills/`, `SKILL.md` |
| Patterns | Forms | `patterns/`, `PATTERN.md` |
| Index | Scroll | `index.json` |
| Bootstrap skill | Dojo Charter | `skills/_charter/SKILL.md` |
| Critic agent | Sensei | `agents/review/sensei.md` |
| Ralph loop | Training Loop | `skills/ralph-loop/`, `scripts/ralph-loop.sh` |
| Compound docs | Lessons Learned | `skills/compound-docs/SKILL.md` |
| Review agents | Sparring Partners | `agents/review/*.md` |
| Always-on skills | Dojo Rules | `gate: true` in index |

**Rule**: If a developer opens the repo cold, every filename must be instantly clear without knowing the glossary.

---

## Design Principles

1. **Zero-friction.** No slash commands. Claude checks the index before every response.
2. **Right-sized.** Simple tasks stay simple. Complex tasks auto-escalate.
3. **Drop-in extensibility.** New skill = new folder + `SKILL.md`. Rebuild the index. Done. (Index rebuilds automatically on install and lazily on session-start if missing.)
4. **Composable.** Skills chain to each other via references, not hard coupling.
5. **Self-improving.** Claude proposes skill refinements and new patterns; human approves.
6. **No ceremony.** Plugin state stays under `.claude/plugin/`. Patterns default to warn. Scope control is silent.
7. **Gate skills are invisible unless triggered.** Four skills influence behavior, but only surface when relevant (claiming done, after implementation, on error, scope blowup).

---

## Architecture

### Directory Structure

```
syntaxninja-dojo/
├── .claude-plugin/
│   ├── plugin.json                    # Plugin manifest
│   └── marketplace.json               # Marketplace registration
│
├── hooks/
│   ├── hooks.json                     # SessionStart + UserPromptSubmit hooks
│   ├── run-hook.cmd                   # Cross-platform polyglot wrapper
│   ├── session-start                  # Injects full bootstrap (the "Dojo Charter")
│   └── prompt-submit                  # Lightweight per-message reminder
│
├── scripts/
│   ├── build-index.ts                 # Portable index builder + CSO linter (Node)
│   ├── ralph-loop.sh                  # Autonomous loop runner (bash)
│   └── build-index.sh                 # Shell wrapper for build-index.ts
│
├── skills/                            # Skills ("katas" in docs)
│   ├── index.json                     # Auto-generated skill index ("the scroll")
│   │
│   ├── _charter/                      # Bootstrap skill ("the Dojo Charter")
│   │   └── SKILL.md                   # Decision engine + invocation mandate
│   │
│   ├── # ── GATE SKILLS (always active — "Dojo Rules") ──
│   ├── verification-before-completion/SKILL.md
│   ├── self-review/SKILL.md           # Dispatches the sensei agent
│   ├── systematic-debugging/
│   │   ├── SKILL.md
│   │   └── references/
│   ├── scope-control/SKILL.md         # Silent: prefer smallest viable change set
│   │
│   ├── # ── CORE SKILLS ──
│   ├── brainstorming/SKILL.md
│   ├── writing-plans/SKILL.md
│   ├── executing-plans/SKILL.md
│   ├── test-driven-development/SKILL.md
│   │
│   ├── # ── RALPH LOOP SKILLS ──
│   ├── ralph-loop/SKILL.md            # Auto-escalation to autonomous loop
│   ├── prd-generator/SKILL.md
│   ├── story-decomposition/SKILL.md
│   │
│   ├── # ── CODE REVIEW SKILLS ──
│   ├── requesting-code-review/SKILL.md
│   ├── receiving-code-review/SKILL.md
│   │
│   ├── # ── MULTI-AGENT SKILLS ──
│   ├── dispatching-parallel-agents/SKILL.md
│   ├── subagent-driven-development/SKILL.md
│   │
│   ├── # ── GIT & WORKFLOW SKILLS ──
│   ├── using-git-worktrees/SKILL.md
│   ├── finishing-a-development-branch/SKILL.md
│   │
│   ├── # ── KNOWLEDGE CAPTURE ──
│   ├── compound-docs/SKILL.md         # Capture solved problems ("lessons learned")
│   ├── propose-skill-update/SKILL.md
│   │
│   ├── # ── META SKILLS ──
│   └── writing-skills/SKILL.md        # How to create new skills + patterns
│
├── agents/                            # Review & research agents ("sparring partners")
│   ├── review/
│   │   ├── architecture-reviewer.md
│   │   ├── security-reviewer.md
│   │   ├── performance-reviewer.md
│   │   ├── simplicity-reviewer.md
│   │   ├── pattern-reviewer.md
│   │   └── sensei.md                  # The sensei — fresh-context diff critic
│   └── research/
│       ├── codebase-researcher.md
│       └── docs-researcher.md
│
├── patterns/                          # Code patterns ("forms" in docs)
│   ├── index.json                     # Auto-generated pattern index
│   ├── # ── LIBRARY PATTERNS ──
│   ├── zustand/PATTERN.md
│   ├── tanstack-query/PATTERN.md
│   ├── ...
│   ├── # ── STRUCTURE PATTERNS ──
│   ├── structure-domain-first/PATTERN.md
│   ├── structure-test-colocation/PATTERN.md
│   └── ...
│
└── config/
    └── defaults.md                    # Default configuration
```

**Runtime artifacts** — all under `.claude/plugin/`:
```
<project>/
├── .claude/
│   ├── CLAUDE.md                      # Project conventions (not plugin-managed)
│   ├── agents/                        # Symlinked from plugin agents/
│   ├── plugin/                        # ALL plugin runtime state
│   │   ├── ralph/                     # Ralph loop state
│   │   │   ├── status.json
│   │   │   ├── prd.json
│   │   │   ├── progress.txt
│   │   │   ├── PROMPT.md
│   │   │   └── notes/
│   │   ├── runs/                      # Run history
│   │   ├── cache/                     # Index cache
│   │   └── state/                     # Router state
│   └── dojo-config.md                 # Fallback config (backwards compat)
├── dojo.config.md                       # Project plugin config (discoverable at root)
├── patterns/                          # Project-specific pattern overrides
│   └── <name>/PATTERN.md
└── docs/
    └── learnings/                     # Captured lessons (committed)
```

**Gitignore** — one rule (`.claude/agents/` is NOT ignored — symlinks are committed):
```gitignore
.claude/plugin/**
```

---

### Layer 1: Dual-Hook Bootstrap (The Dojo Charter)

Two hooks guarantee skill invocation across the entire session.

#### Hook 1: SessionStart (full bootstrap)

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|resume|clear",
        "hooks": [{
          "type": "command",
          "command": "'${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd' session-start",
          "async": false
        }]
      }
    ]
  }
}
```

**No `compact`.** Causes compaction feedback loops. UserPromptSubmit handles post-compaction drift.

**`session-start`** outputs:
- Full Dojo Charter content (`skills/_charter/SKILL.md`)
- Dual fingerprint: `PLUGIN_ROUTER: syntaxninja-dojo@<version>` + `DOJO_ROUTER: syntaxninja-dojo@<version>`
- Pointer to `skills/index.json` + `patterns/index.json`
- Pointer to `dojo.config.md` (repo root) or `.claude/dojo-config.md` (fallback)
- **Lazy setup**: creates `.claude/plugin/` dirs, symlinks agents, builds index if missing

#### Hook 2: UserPromptSubmit (per-message reminder)

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": [{
          "type": "command",
          "command": "'${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd' prompt-submit",
          "async": false
        }]
      }
    ]
  }
}
```

**`prompt-submit`** output (~200 tokens):
```
PLUGIN_ROUTER: syntaxninja-dojo@<version>
DOJO_ROUTER: syntaxninja-dojo@<version>
REMINDER: Consult skills/index.json. Load 1-3 matching skills. If no match, gate skills influence behavior silently.
GATES: verification-before-completion (on completion claims), self-review (after implementation), systematic-debugging (on error), scope-control (silent always)
SKILLS_HASH: <sha256>
PATTERNS_HASH: <sha256>
CONFIG: <path or "none">
```

#### Conflict Handshake

If the charter detects another `DOJO_ROUTER:` or `PLUGIN_ROUTER:` in context:
1. **Compat mode**: enforce gate skills only
2. Don't take over planning/execution unless explicitly invoked
3. One-time notice: "Multiple routers detected. Running in compat mode."

#### Router Confidence

- 1+ skills match clearly → load and invoke
- 0 match → gate skills only
- Ambiguous → gate skills only, mention which skills *might* apply

### Layer 2: Index & Discovery

**`scripts/build-index.ts`** generates `skills/index.json` and `patterns/index.json`.

#### Skill Index (`skills/index.json`)

```json
{
  "version": "1.0.0",
  "hash": "sha256:...",
  "updated": "2026-03-03T12:00:00Z",
  "skills": [
    {
      "name": "systematic-debugging",
      "description": "Use when encountering any bug, test failure, or unexpected behavior",
      "tags": ["process", "debugging"],
      "triggers": ["bug", "error", "unexpected", "failing test"],
      "chains_to": ["test-driven-development", "verification-before-completion", "compound-docs"],
      "priority": "gate",
      "gate": true
    },
    {
      "name": "ralph-loop",
      "description": "Use when task scope exceeds one context window and decomposes into pass/fail stories",
      "tags": ["process", "execution", "autonomous"],
      "triggers": ["large scope", "multiple stories", "too big for one session"],
      "chains_to": ["story-decomposition", "prd-generator"],
      "priority": "escalation"
    }
  ]
}
```

#### Pattern Index (`patterns/index.json`)

```json
{
  "version": "1.0.0",
  "hash": "sha256:...",
  "patterns": [
    {
      "name": "zustand",
      "type": "library",
      "library": "zustand",
      "severity": "p2",
      "detect": ["from 'zustand'", "import { create }"],
      "signatures": ["create<", "set(("],
      "file_globs": ["*.ts", "*.tsx"],
      "tags": ["state-management", "react"]
    },
    {
      "name": "structure-domain-first",
      "type": "structure",
      "severity": "p3",
      "detect": [],
      "signatures": [],
      "file_globs": ["**/*"],
      "tags": ["organization", "architecture"]
    }
  ]
}
```

#### CSO Lint (built into build-index.ts)

Every SKILL.md description:
- Must start with "Use when"
- Trigger conditions only — never workflow summaries
- Max 1024 characters frontmatter
- Name: letters, numbers, hyphens only

#### Why Node

Cross-platform. YAML/JSON native. Bash wrapper (`build-index.sh`) for convenience.

### Layer 3: Skill Format

```markdown
---
name: skill-name-with-hyphens
description: Use when [triggering conditions only]
tags: [optional tags]
---

# Skill Name

## Quick Reference
[What to do first]

## When to Use
[Detailed triggers]

## When NOT to Use
[Explicit exclusions]

## Core Process
[Step-by-step — must be loaded via Skill tool, never from description]

## Anti-Patterns
[What NOT to do]

## Chaining
REQUIRED: syntaxninja-dojo:next-skill
OPTIONAL: syntaxninja-dojo:conditional-skill (when X)
```

Supporting files:
```
skill-name/
├── SKILL.md              # Entry point (under 500 lines)
├── references/           # Detailed docs loaded on demand
├── scripts/              # Executable helpers
└── templates/            # Output templates
```

#### Scope-Control: Silent

Three rules. No essays.

1. **Prefer smallest viable change set.**
2. **If task is large** → propose: split | ralph loop | worktree.
3. **If scope grows during work** → pause, re-scope with user.

### Layer 4: Ralph Loop (Training Loop)

Auto-detected escalation for tasks too large for one context window.

#### Detection

Triggers when ALL of:
- Scope exceeds one context window
- Work decomposes into independent, verifiable stories
- Each story has pass/fail acceptance criteria
- Clean iteration boundaries exist

#### Escalation Flow

1. Claude detects ralph-loop conditions during `writing-plans`
2. Invokes `story-decomposition` to break work into stories
3. Generates `.claude/plugin/ralph/prd.json` + `progress.txt` + `PROMPT.md`
4. Proposes: "This task would benefit from a training loop. Here's the decomposition. Approve?"
5. On approval, creates a worktree (default) and provides the command

#### Loop Runner (`scripts/ralph-loop.sh`)

```bash
#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RALPH_DIR="${RALPH_DIR:-.claude/plugin/ralph}"
MAX_ITERATIONS="${1:-20}"
CHECKPOINT="${CHECKPOINT:-per-story}"
CHECKPOINT_STYLE="${CHECKPOINT_STYLE:-squash}"
ITERATION=0
CHECKPOINT_BRANCH=""

mkdir -p "$RALPH_DIR/notes"
echo '{"status": "running", "iteration": 0, "completed_stories": []}' > "$RALPH_DIR/status.json"

if [ "$CHECKPOINT_STYLE" = "squash" ]; then
    CHECKPOINT_BRANCH=$(git rev-parse HEAD)
fi

checkpoint() {
    local msg="$1"
    if git diff --quiet && git diff --cached --quiet; then return 0; fi
    case "$CHECKPOINT" in
        none) return 0 ;;
        per-iteration|per-story)
            git add -A
            if [ "$CHECKPOINT_STYLE" = "squash" ]; then
                git commit -m "wip: $msg" 2>/dev/null || true
            else
                git commit -m "dojo: $msg" 2>/dev/null || true
            fi ;;
        end-only) return 0 ;;
    esac
}

finalize() {
    if [ "$CHECKPOINT" = "end-only" ]; then
        git add -A && git commit -m "dojo: training complete" 2>/dev/null || true
    fi
    if [ "$CHECKPOINT_STYLE" = "squash" ] && [ -n "$CHECKPOINT_BRANCH" ]; then
        local count=$(jq -r '.completed_stories | length' "$RALPH_DIR/status.json")
        git reset --soft "$CHECKPOINT_BRANCH"
        git commit -m "dojo: $count stories completed"
    fi
}

while [ $ITERATION -lt $MAX_ITERATIONS ]; do
    ITERATION=$((ITERATION + 1))
    echo "=== Training Loop: Round $ITERATION / $MAX_ITERATIONS ==="

    jq --argjson iter "$ITERATION" '.iteration = $iter' \
        "$RALPH_DIR/status.json" > tmp.json && mv tmp.json "$RALPH_DIR/status.json"

    # --dangerously-skip-permissions is opt-in via SKIP_PERMISSIONS=true
    CLAUDE_FLAGS="--print"
    if [ "${SKIP_PERMISSIONS:-false}" = "true" ]; then
        CLAUDE_FLAGS="--dangerously-skip-permissions --print"
    fi
    claude $CLAUDE_FLAGS \
        < "$RALPH_DIR/PROMPT.md" > "$RALPH_DIR/last_output.txt" 2>&1

    [ "$CHECKPOINT" = "per-iteration" ] && checkpoint "round $ITERATION"

    if jq -e '.status == "complete"' "$RALPH_DIR/status.json" > /dev/null 2>&1; then
        echo "=== Training Loop: COMPLETE after $ITERATION rounds ==="
        finalize; exit 0
    fi

    if jq -e '[.userStories[].passes] | all' "$RALPH_DIR/prd.json" > /dev/null 2>&1; then
        jq '.status = "complete"' "$RALPH_DIR/status.json" > tmp.json \
            && mv tmp.json "$RALPH_DIR/status.json"
        echo "=== Training Loop: All stories pass after $ITERATION rounds ==="
        finalize; exit 0
    fi

    sleep 2
done

echo "=== Training Loop: Max rounds ($MAX_ITERATIONS) reached ==="
jq '.status = "max_iterations"' "$RALPH_DIR/status.json" > tmp.json \
    && mv tmp.json "$RALPH_DIR/status.json"
exit 1
```

#### Configuration

```markdown
## Training Loop
- Max rounds: 20
- Checkpoint: per-story           # none | per-iteration | per-story | end-only
- Checkpoint style: squash        # normal | squash
- Run in worktree: true           # isolate by default
- Worktree path: .claude/plugin/worktrees/<task-slug>/   # deterministic, easy cleanup
- Skip permissions: false         # opt-in: set true for full automation
```

### Layer 5: Agents (Sparring Partners)

Agent definitions in `agents/`. Symlinked to `.claude/agents/` per project.

```markdown
---
name: security-reviewer
type: review
tools: Read, Grep, Glob, WebSearch
description: Checks for OWASP top 10, auth/authz, input validation, secrets
---

# Security Reviewer

## Focus Areas
[...]

## Output Format
- P1 (blocks merge): [finding with file:line]
- P2 (should fix): [finding]
- P3 (nice-to-have): [finding]

## Constraints
- NEVER edit files. Return text only.
- NEVER run destructive commands.
```

Agents return TEXT DATA ONLY. The orchestrating skill merges and writes.

### Layer 6: Knowledge Capture (Lessons Learned)

After solving a hard problem, Claude proposes a learning:
- Written to `docs/learnings/<category>/<filename>.md`
- Trigger detection: "that worked", "figured it out", "the issue was"
- Claude proposes; user approves

#### Skill Update Ratchet

**Allowed** (must cite 3+ distinct occurrences):
1. New trigger condition
2. New anti-pattern
3. New verification step

**Never allowed**: Rewriting core process. Removing steps. Adding project-specific details.

### Layer 7: Configuration

#### Hierarchy

1. **Project CLAUDE.md** — project conventions (never duplicated)
2. **`.claude/dojo-config.md`** — project plugin overrides
3. **`~/.claude/plugins/syntaxninja-dojo/config.md`** — user defaults
4. **`config/defaults.md`** — shipped defaults

### Layer 8: The Sensei (Quality Gates)

Two-stage post-implementation verification.

```
Implementation complete
│
├─ Stage 1: Functional Verification
│   └─ Tests pass? Lint clean? Format correct?
│
└─ Stage 2: Sensei Review
    ├─ < 20 lines → LOW (quick inline check)
    ├─ 20-100 lines → configured strictness
    └─ > 100 lines or 3+ files → at least MEDIUM
```

#### The Sensei (`agents/review/sensei.md`)

Fresh-context subagent. Reviews the **actual `git diff`**. No anchoring bias.

**Checks:**

| Check | Catches |
|-------|---------|
| "What would I delete?" | YAGNI, over-engineering |
| Single-use test | Inline it or justify it |
| Impossible error handling | Defensive code for impossible states |
| Framework duplication | Re-implementing framework guarantees |
| Pattern compliance | Library + structure patterns from the index |
| Leftover artifacts | TODOs, debug prints, commented-out code |
| Line budget | Additions justified? |

**Output:**
```
SENSEI REVIEW: <one-line summary>

REMOVE:
- file:line — [reason]

SIMPLIFY:
- file:line — [current] → [simpler]

PATTERN MISMATCH:
- P1: file:line — pattern:<name> — [correctness/safety]
- P2: file:line — pattern:<name> — [maintainability]
- P3: file:line — pattern:<name> — [taste]

VERDICT: PASS | PASS_WITH_NOTES | SIMPLIFY_FIRST | RETHINK
```

- **PASS**: Clean. No issues.
- **PASS_WITH_NOTES**: Ship it, but advisory items for awareness. No simplification loop.
- **SIMPLIFY_FIRST**: Has REMOVE/SIMPLIFY items. Triggers simplification loop.
- **RETHINK**: P1 issues, architectural concerns, or security problems.

#### Simplification Loop (max 2 rounds)

```
Implement → Sensei round 1 → Apply fixes → Sensei round 2 → Done
                                                  │
                                             (remaining items
                                              shown to user)
```

#### Configuration

```markdown
## Sensei
- Strictness: medium              # low | medium | high
- Max simplification rounds: 2
- Pattern enforcement: warn       # warn | enforce | off
```

Only P1 patterns block by default. P2/P3 are advisory.

### Layer 9: Patterns (Forms)

Two pattern types:

**Library patterns** — how to use a library:
```
patterns/zustand/PATTERN.md
patterns/tanstack-query/PATTERN.md
```

**Structure patterns** — how to organize code:
```
patterns/structure-domain-first/PATTERN.md
patterns/structure-test-colocation/PATTERN.md
```

#### 3-Signal Detection

1. **`detect`** — import/require strings
2. **`file-globs`** — file path patterns
3. **`signatures`** — API usage grep patterns

Match on **2 of 3 signals**. Handles barrels, re-exports, aliases.

**Structure pattern escape hatch**: Structure patterns (`type: "structure"`) have broad file-globs (`**/*`) that always match. Apply them ONLY during: new file creation, directory changes, file moves, and sensei review when the diff includes path changes. Not during routine edits.

#### PATTERN.md Format

```markdown
---
name: zustand
type: library                      # library | structure
library: zustand
severity: p2                       # p1 (must fix) | p2 (usually fix) | p3 (taste)
file-globs: ["*.ts", "*.tsx"]
detect: ["from 'zustand'", "import { create }"]
signatures: ["create<", "set(("]
tags: [state-management, react]
autofix: ""                        # optional: "pnpm lint --fix"
---

# Zustand Pattern

## Preferred Pattern

[Concrete code example]

## Rules
- One store per domain concept
- Export the hook directly
- Type the state interface explicitly

## Anti-Patterns

[Code examples of what NOT to do]

## When to Apply
- New zustand store files
- Refactoring existing stores
- Code review of PRs touching stores
```

#### Structure Pattern Example

```markdown
---
name: structure-domain-first
type: structure
severity: p3
file-globs: ["**/*"]
detect: []
signatures: []
tags: [organization, architecture]
---

# Domain-First Organization

## Preferred Structure

```
src/
├── <domain>/
│   ├── components/
│   ├── hooks/
│   ├── store.ts
│   ├── types.ts
│   ├── index.ts                   # Public API
│   └── __tests__/
├── shared/
└── app/
```

## Rules
- `src/<domain>/` over `src/components/` dumping ground
- Nesting <= 3 levels
- Co-locate tests with implementation
- Cross-domain imports only via `<domain>/index.ts`

## Anti-Patterns
- 50+ unrelated components in `src/components/`
- Global `src/hooks/` mixing every domain
- Importing domain internals from outside
```

#### Pattern Hierarchy + `extends`

1. **Project patterns** (`<project>/patterns/<name>/PATTERN.md`) — project overrides
2. **Plugin patterns** (`syntaxninja-dojo/patterns/<name>/PATTERN.md`) — personal defaults

Project patterns can extend plugin patterns:

```markdown
---
name: zustand
extends: plugin:zustand
---

## Additional Rules
- Selectors exported from `selectors.ts`
- Store files at `src/<domain>/store.ts`
```

Without `extends`, project pattern replaces plugin pattern entirely.

#### Three Ways to Add a Pattern

1. **Drop-in**: Create `patterns/<name>/PATTERN.md`. Run `build-index.sh`.
2. **From example**: Show Claude your preferred code. It generates the PATTERN.md.
3. **Auto-detected**: Sensei observes 3+ consistent usages → proposes a new pattern.

---

## Branding & README

### Repo

```
thesyntaxninja/syntaxninja-dojo
```

### README.md

```markdown
# SyntaxNinja Dojo

**Train your AI to write disciplined code.**

A Claude Code plugin that enforces clean engineering workflows automatically.
No slash commands. No configuration ceremony. Install it and your AI starts
following battle-tested development discipline.

---

## What It Does

| What | How |
|------|-----|
| **Dojo Rules** | Every task gets verified, reviewed, and scoped — automatically |
| **Skills** (katas) | Debugging, planning, TDD, code review — the right workflow fires for the right task |
| **Patterns** (forms) | Your preferred code style enforced. Zustand, React Query, folder structure — however you like it |
| **Training Loop** | Tasks too big for one session? Auto-decomposed into stories, run autonomously |

## How It Works

Install it. Forget about it. It works.

Two hooks, always active:
1. **Session start** — injects the Dojo Charter: a decision engine that routes tasks to the right skill
2. **Every message** — a lightweight reminder so Claude never drifts, even in long sessions

Claude consults the **index** before every response, loads the 1-3 most relevant skills,
and follows them. If nothing matches, the **gate skills** still apply — verify before
claiming done, review your diff, debug systematically.

### The Sensei

After implementation, the **Sensei** — a fresh-context agent with no memory of writing
the code — reviews your actual `git diff` and asks:

> *"What would I delete?"*

Most quality issues aren't about what's missing. They're about what shouldn't be there.

### Patterns (Forms)

Drop a `PATTERN.md` into `patterns/zustand/` and every zustand store Claude writes
follows your conventions. Show Claude an example and it generates the pattern for you.
After 3 consistent usages, the Sensei proposes a pattern automatically.

### Training Loop

When a task is too big for one context window, the Dojo decomposes it into pass/fail
stories and runs them in an autonomous loop — fresh context per story, persistent state
via files, git checkpoint between rounds. Worktree by default so your branch stays clean.

## Install

```bash
claude /plugin marketplace add thesyntaxninja/syntaxninja-dojo-marketplace
claude /plugin install syntaxninja-dojo
```

## Quick Start

```bash
# Nothing to configure. Start working.

# Optional: project-specific settings
cat > .claude/dojo-config.md << 'EOF'
## Sensei
- Strictness: high
- Pattern enforcement: enforce

## Training Loop
- Max rounds: 15
- Run in worktree: true
EOF

# Optional: add your own patterns
mkdir -p patterns/zustand
# Write patterns/zustand/PATTERN.md
npx syntaxninja-dojo build-index
```

## Dojo Glossary

In the Dojo, we use these names:

| Standard | Dojo |
|----------|------|
| Skills | Katas |
| Patterns | Forms |
| Critic agent | Sensei |
| Index | Scroll |
| Bootstrap | Dojo Charter |
| Ralph loop | Training Loop |
| Learnings | Lessons Learned |
| Review agents | Sparring Partners |

The file system uses standard terms. The glossary is for documentation and conversation.

## Configuration

Config hierarchy (highest precedence first):
1. Project `CLAUDE.md` — project conventions
2. `.claude/dojo-config.md` — project plugin settings
3. `~/.claude/plugins/syntaxninja-dojo/config.md` — global defaults
4. Plugin `config/defaults.md` — shipped defaults

## Adding Patterns

Three ways:

**Drop-in**: Create `patterns/<name>/PATTERN.md` + run `build-index`.

**From example**: Tell Claude your preferred style. It writes the PATTERN.md.

**Auto-detected**: Write consistently. The Sensei proposes a pattern after 3 occurrences.
```

### Logo Concept

Minimal shuriken made of code brackets:
```
    < >
   /   \
  {     }
   \   /
    [ ]
```

Color: Black background, electric green (#00FF41). Terminal/hacker aesthetic.

### Taglines

1. **Train your AI to write disciplined code.** (primary)
2. **A dojo for clean, pattern-driven engineering.**
3. **Install once. Forget about it. Code gets better.**
4. **Your taste, enforced. Your workflows, automatic.**

---

## Cleanup Strategy

### `.claude/plugin/`

All runtime state. One gitignore rule.

| When | Action |
|------|--------|
| Ralph loop completes | Keep for reference |
| Ralph loop fails | Keep for debugging |
| New ralph loop starts | Archive to `ralph/archive/<timestamp>/` |
| Cleanup command | Removes `.claude/plugin/`, stale symlinks |

### Agent Symlinks

Idempotent. Re-running setup refreshes. Cleaned on uninstall.

### `docs/learnings/`

Permanent. Committed to git.

---

## Implementation Plan

### Phase 1: Core Bootstrap (MVP)

1. **Plugin manifest** (`.claude-plugin/plugin.json`, `marketplace.json`)
2. **Dual hooks** (`hooks.json`, `run-hook.cmd`, `session-start`, `prompt-submit`)
3. **Dojo Charter** (`skills/_charter/SKILL.md`) — decision engine + fingerprint + compat
4. **Index builder** (`scripts/build-index.ts`) — skills + patterns indexes + CSO lint
5. **4 gate skills**:
   - `verification-before-completion`
   - `self-review` (dispatches sensei)
   - `systematic-debugging`
   - `scope-control` (silent)
6. **Sensei agent** (`agents/review/sensei.md`)

**Validation**: Install → charter injects → prompt-submit fires every message. Fix a bug → debugging + verification + sensei fires automatically.

### Phase 2: Planning & Execution

7. **Brainstorming**
8. **Writing-plans**
9. **Executing-plans**
10. **Test-driven-development**
11. **Subagent-driven-development**
12. **Dispatching-parallel-agents**

**Validation**: Feature request → brainstorm → plan → execute → sensei review. Automatic.

### Phase 3: Patterns

13. **PATTERN.md format** with severity + signatures + autofix
14. **2-3 library patterns** (zustand, tanstack-query)
15. **1-2 structure patterns** (domain-first, test-colocation)
16. **Pattern index** in `build-index.ts`
17. **`extends`** support
18. **3-signal detection** in charter
19. **Pattern generation** from examples
20. **Pattern proposals** from sensei (3-occurrence ratchet)

**Validation**: Write zustand → pattern loads → follows it. Write wrong → sensei flags PATTERN MISMATCH.

### Phase 4: Ralph Loop (Training Loop)

21. **Story-decomposition**
22. **Ralph-loop skill** (detection + escalation + PROMPT.md)
23. **ralph-loop.sh** (configurable checkpoints, worktree-first)
24. **PRD generator**

**Validation**: Large task → detected → proposed → runs in worktree.

### Phase 5: Review Agents (Sparring Partners)

25. **5 review agents** (read-only)
26. **Pattern-checker agent**
27. **2 research agents**
28. **Agent setup** (symlinks into `.claude/agents/`)
29. **Requesting-code-review**
30. **Receiving-code-review**

**Validation**: PR review → parallel agents → merged findings.

### Phase 6: Knowledge Capture

31. **Compound-docs** (propose learnings)
32. **Propose-skill-update** (ratchet rules)
33. **Writing-skills** (create new skills + patterns)

**Validation**: Solve bug → lesson proposed. 3+ lessons → skill update proposed.

### Phase 7: Polish

34. **Using-git-worktrees**
35. **Finishing-a-development-branch**
36. **Config layer**
37. **Setup command**
38. **Cleanup command**
39. **README + branding + glossary**

---

## Key Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Naming strategy | Standard terms in code, dojo flavor in docs | Developer familiarity + memorable branding |
| File conventions | `skills/SKILL.md`, `patterns/PATTERN.md`, `index.json` | CC compat, searchable, instantly clear |
| Dojo-themed names | `sensei.md`, `_charter/`, dojo-config.md | Where the metaphor adds clarity, not confusion |
| Hook strategy | SessionStart + UserPromptSubmit | Drift-proof |
| SessionStart matcher | `startup\|resume\|clear` (NO compact) | Avoids feedback loops |
| Hook async | `false` always | Async drops context silently |
| Skill discovery | Index-based (`index.json`) | Scales without noise |
| Router fingerprint | Dual: PLUGIN_ROUTER + DOJO_ROUTER | Interop with superpowers-style routers |
| Router confidence | Match / no-match / ambiguous (multiple plausible) | No numeric scores |
| Project config | `dojo.config.md` at repo root | Discoverable in PRs; `.claude/dojo-config.md` as fallback |
| Runtime state | `.claude/plugin/` | One location, one gitignore |
| Worktree location | `.claude/plugin/worktrees/<task-slug>/` | Deterministic, contained cleanup |
| Skip permissions | Opt-in per repo (`SKIP_PERMISSIONS=true`) | Don't bake dangerous defaults |
| Gate skill visibility | Invisible unless triggered | Don't explain 4 skills every turn |
| Sensei PASS_WITH_NOTES | Advisory items without simplify loop | Preserves feedback without blocking |
| Structure patterns | Only during file creation/moves/sensei review | Prevents constant noise from broad globs |
| Index builder | Node (`build-index.ts`) | Cross-platform |
| Sensei | Fresh-context subagent | No anchoring bias |
| Simplification | Max 2 rounds | Prevents infinite polish |
| Patterns: types | Library + structure | Code style AND code organization |
| Patterns: detection | 3-signal (imports + globs + signatures) | Handles barrels, re-exports |
| Patterns: severity | P1 / P2 / P3 | Taste informs; only correctness blocks |
| Patterns: default | `warn` | Patterns inform, not block |
| Patterns: overrides | `extends` support | Additive without duplication |
| Ralph loop | Worktree-first, configurable checkpoints | Isolated, clean |
| Checkpoints | per-story default, squash option | Meaningful boundaries |
| Scope-control | Silent 3-rule constraint | No ceremony |
| Self-improvement | 3-occurrence ratchet | Prevents drift |

## Resolved Questions

1. **Plugin name** — SyntaxNinja Dojo. Repo: `thesyntaxninja/syntaxninja-dojo`.
2. **Naming balance** — Standard terms in file system, dojo flavor in docs/UX only.
3. **Agent integration** — `.claude/agents/` symlinks.
4. **Plugin conflicts** — Fingerprint + compat mode.
5. **Ralph loop prompt** — Auto-generated `PROMPT.md` with charter + CLAUDE.md.
6. **Quality review** — Sensei agent (fresh context), configurable strictness.
7. **Code patterns** — Standard `patterns/PATTERN.md`. Library + structure types.
8. **Runtime state** — `.claude/plugin/`. One gitignore rule.
9. **Checkpointing** — Configurable per-story/squash. Worktree default.
10. **Pattern overrides** — `extends` for additive, full replace without.

## Remaining Open Questions

1. **Embedding-based routing** — Optional index field for semantic matching. v2 if needed.
2. **Ralph loop monitoring** — Structured logs vs. progress.txt + git history.
3. **npm package** — Publish `build-index.ts` as `syntaxninja-dojo` on npm for `npx`?

## Next Steps

1. ~~Decide on a name~~ — SyntaxNinja Dojo
2. ~~Naming strategy~~ — Standard code terms, dojo docs flavor
3. Create repo: `thesyntaxninja/syntaxninja-dojo`
4. Implement Phase 1 (charter + hooks + index builder + 4 gate skills + sensei)
5. Test in a real project
6. Ship to marketplace
