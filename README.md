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
| **Sparring Partners** | 5 review agents + 2 research agents, dispatched in parallel |
| **Lessons Learned** | Hard problems get captured. Knowledge compounds across sessions. |

## How It Works

Install it. Forget about it. It works.

Two hooks, always active:
1. **Session start** — injects the Dojo Charter: a decision engine that routes tasks to the right skill
2. **Every message** — a lightweight reminder so Claude never drifts, even in long sessions

Claude consults the **index** before every response, loads the 1-3 most relevant skills,
and follows them. If nothing matches, the **gate skills** still influence behavior silently — verify before
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
claude plugin add thesyntaxninja/syntaxninja-dojo
```

## Quick Start

```bash
# Nothing to configure. Start working.

# Optional: set up agent symlinks and runtime directories
bash /path/to/syntaxninja-dojo/scripts/setup.sh

# Optional: project-specific settings
cat > dojo.config.md << 'EOF'
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
npx tsx scripts/build-index.ts
```

## Skills

### Gate Skills (always active, invisible)

| Skill | Surfaces When |
|-------|---------------|
| `verification-before-completion` | About to claim work is done |
| `self-review` | After implementation (dispatches the sensei) |
| `systematic-debugging` | Error, bug, or unexpected behavior |
| `scope-control` | Always silent — prefer smallest viable change set |

### Core Skills

| Skill | Purpose |
|-------|---------|
| `brainstorming` | Explore unclear requirements, converge on an approach |
| `writing-plans` | Structured plans with acceptance criteria |
| `executing-plans` | Step-by-step execution with verification checkpoints |
| `test-driven-development` | RED/GREEN/REFACTOR cycle |
| `subagent-driven-development` | Delegate independent tasks to parallel agents |
| `dispatching-parallel-agents` | Fan-out/fan-in for 2+ independent tasks |

### Ralph Loop Skills

| Skill | Purpose |
|-------|---------|
| `ralph-loop` | Autonomous loop for tasks exceeding one context window |
| `story-decomposition` | Break large tasks into independent, verifiable stories |
| `prd-generator` | Generate PRD artifacts for the loop runner |

### Code Review Skills

| Skill | Purpose |
|-------|---------|
| `requesting-code-review` | Dispatch parallel review agents, merge findings |
| `receiving-code-review` | Verify feedback technically before implementing |

### Knowledge Capture Skills

| Skill | Purpose |
|-------|---------|
| `compound-docs` | Capture lessons learned after solving hard problems |
| `propose-skill-update` | 3-occurrence ratchet for skill improvements |
| `writing-skills` | Create new skills and patterns |

### Git & Workflow Skills

| Skill | Purpose |
|-------|---------|
| `using-git-worktrees` | Isolated work via git worktrees |
| `finishing-a-development-branch` | Merge, PR, or keep — user decides |

## Agents

### Review Agents (Sparring Partners)

| Agent | Focus |
|-------|-------|
| `sensei` | Fresh-context quality review of the git diff |
| `architecture-reviewer` | Module boundaries, coupling, abstraction levels |
| `security-reviewer` | OWASP top 10, auth/authz, injection, secrets |
| `performance-reviewer` | N+1 queries, re-renders, memory leaks, complexity |
| `simplicity-reviewer` | YAGNI, dead code, over-abstraction |
| `pattern-reviewer` | Pattern compliance via 3-signal detection |

### Research Agents

| Agent | Focus |
|-------|-------|
| `codebase-researcher` | Structure, conventions, pattern analysis |
| `docs-researcher` | External docs, APIs, best practices with citations |

## Patterns

### Shipped Patterns

| Pattern | Type | Severity |
|---------|------|----------|
| `zustand` | library | P2 |
| `tanstack-query` | library | P2 |
| `structure-domain-first` | structure | P3 |
| `structure-test-colocation` | structure | P3 |

### Adding Patterns

Three ways:

**Drop-in**: Create `patterns/<name>/PATTERN.md` + run `npx tsx scripts/build-index.ts`.

**From example**: Tell Claude your preferred style. It writes the PATTERN.md.

**Auto-detected**: Write consistently. The Sensei proposes a pattern after 3 occurrences.

### Pattern Detection

Library patterns use 3-signal detection (match 2 of 3):
1. **detect** — import/require strings
2. **file-globs** — file path patterns
3. **signatures** — API usage patterns

Structure patterns apply only during file creation, moves, or sensei review.

## Dojo Glossary

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
2. `dojo.config.md` — project plugin settings (repo root, discoverable in PRs)
3. `.claude/dojo-config.md` — fallback location
4. `~/.claude/plugins/syntaxninja-dojo/config.md` — global defaults
5. Plugin `config/defaults.md` — shipped defaults

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/build-index.ts` | Rebuild skill + pattern indexes with CSO lint |
| `scripts/build-index.sh` | Shell wrapper for build-index.ts |
| `scripts/ralph-loop.sh` | Autonomous loop runner |
| `scripts/setup.sh` | Set up plugin in a project (dirs, symlinks, index) |
| `scripts/cleanup.sh` | Remove runtime state from a project |

## Project Layout

```
syntaxninja-dojo/
├── .claude-plugin/          # Plugin manifests
├── hooks/                   # Session-start + prompt-submit hooks
├── scripts/                 # Index builder, ralph loop, setup, cleanup
├── skills/                  # 20 skill definitions (SKILL.md per skill)
│   ├── _charter/            # Bootstrap skill (the Dojo Charter)
│   ├── 4 gate skills        # Always active, invisible unless triggered
│   ├── 6 core skills        # Planning, execution, TDD, parallel agents
│   ├── 3 ralph loop skills  # Story decomposition, loop, PRD generator
│   ├── 2 code review skills # Request and receive reviews
│   ├── 3 knowledge skills   # Compound docs, skill updates, authoring
│   └── 2 git/workflow skills # Worktrees, branch finishing
├── agents/                  # 8 agent definitions
│   ├── review/              # 6 review agents (sensei + 5 specialists)
│   └── research/            # 2 research agents
├── patterns/                # 4 code patterns (2 library + 2 structure)
└── config/defaults.md       # Default configuration
```

## License

MIT
