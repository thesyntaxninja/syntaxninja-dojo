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
2. `dojo.config.md` — project plugin settings (repo root, discoverable in PRs)
3. `~/.claude/plugins/syntaxninja-dojo/config.md` — global defaults
4. Plugin `config/defaults.md` — shipped defaults

## Adding Skills

Drop-in: create `skills/<name>/SKILL.md`, run `npx tsx scripts/build-index.ts`.

The index rebuilds automatically on install and lazily on session-start if missing.

## Adding Patterns

Three ways:

**Drop-in**: Create `patterns/<name>/PATTERN.md` + run `npx tsx scripts/build-index.ts`.

**From example**: Tell Claude your preferred style. It writes the PATTERN.md.

**Auto-detected**: Write consistently. The Sensei proposes a pattern after 3 occurrences.

## Project Layout

```
syntaxninja-dojo/
├── .claude-plugin/          # Plugin manifests
├── hooks/                   # Session-start + prompt-submit hooks
├── scripts/                 # Index builder, ralph loop runner
├── skills/                  # Skill definitions (SKILL.md per skill)
│   ├── _charter/            # Bootstrap skill (the Dojo Charter)
│   ├── verification-*/      # Gate skills (always active, invisible)
│   ├── self-review/
│   ├── systematic-debugging/
│   ├── scope-control/
│   └── ...                  # Core, planning, execution skills
├── agents/                  # Review & research agent definitions
│   └── review/sensei.md     # The Sensei (fresh-context critic)
├── patterns/                # Code pattern definitions (PATTERN.md)
└── config/defaults.md       # Default configuration
```

## License

MIT
