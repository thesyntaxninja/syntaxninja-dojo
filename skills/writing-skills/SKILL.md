---
name: writing-skills
description: Use when creating a new skill or pattern for the dojo — guides the SKILL.md and PATTERN.md format, CSO lint rules, and index registration
tags: [meta, authoring, skills]
triggers: [create skill, new skill, write skill, add skill, create pattern, new pattern, write pattern]
chains_to: []
priority: core
gate: false
---

# Writing Skills

## Quick Reference

Create new skills or patterns following the exact format. Run the linter. Register in the index. Every skill must pass CSO lint before it ships.

## When to Use

- Creating a new skill from scratch
- Creating a new pattern from observed usage
- Converting a learning into a formalized skill or pattern
- User asks to add a new skill or pattern

## When NOT to Use

- Updating an existing skill (use `propose-skill-update` for ratchet additions)
- The proposed skill overlaps significantly with an existing one

## Creating a Skill

### Step 1: Choose the Name

- Lowercase letters, numbers, hyphens only: `my-skill-name`
- Descriptive: a developer should guess what it does from the name
- No generic names: `helper`, `utility`, `misc`

### Step 2: Write SKILL.md

```markdown
---
name: my-skill-name
description: Use when [triggering conditions only — never workflow summaries]
tags: [relevant, tags]
triggers: [trigger1, trigger2, trigger3]
chains_to: [next-skill, optional-skill]
priority: core
gate: false
---

# Skill Name

## Quick Reference
[1-2 sentences: what to do first]

## When to Use
[Detailed trigger conditions]

## When NOT to Use
[Explicit exclusions — prevent false matches]

## Core Process
[Step-by-step process — this is what gets followed]

## Anti-Patterns
[Table of what NOT to do and why]

## Chaining
REQUIRED: syntaxninja-dojo:next-skill (always after this skill)
OPTIONAL: syntaxninja-dojo:conditional-skill (when X)
```

### Step 3: CSO Lint Rules

The description field has strict rules:
- **Must** start with "Use when"
- **Must** describe triggering conditions only
- **Must not** summarize the workflow
- **Max** 1024 characters in frontmatter

The name field:
- Letters, numbers, hyphens only
- Must be unique across all skills

### Step 4: Place the File

```
skills/<skill-name>/SKILL.md
```

Optional supporting files:
```
skills/<skill-name>/
├── SKILL.md              # Entry point (under 500 lines)
├── references/           # Detailed docs loaded on demand
├── scripts/              # Executable helpers
└── templates/            # Output templates
```

### Step 5: Register in Index

Run the index builder:
```bash
npx tsx scripts/build-index.ts
# or
bash scripts/build-index.sh
```

If lint fails, fix the errors. The index won't build with lint errors.

## Creating a Pattern

### Step 1: Choose the Type

| Type | Use When |
|------|----------|
| `library` | How to use a specific library (zustand, react-query) |
| `structure` | How to organize code (folder structure, naming) |

### Step 2: Write PATTERN.md

```markdown
---
name: pattern-name
type: library
library: package-name
severity: p2
file-globs: ["*.ts", "*.tsx"]
detect: ["from 'package'", "import { thing }"]
signatures: ["apiCall(", "useHook("]
tags: [relevant, tags]
autofix: ""
---

# Pattern Name

## Preferred Pattern
[Concrete code example of the RIGHT way]

## Rules
[Bullet list of rules]

## Anti-Patterns
[Concrete code examples of the WRONG way]

## When to Apply
[When this pattern should be checked]
```

### Step 3: 3-Signal Detection

Library patterns need at least 2 of 3 signals:
- **detect**: Import/require strings that indicate the library is used
- **file-globs**: File patterns where the library is typically used
- **signatures**: API usage patterns (function calls, method names)

Structure patterns typically have empty `detect` and `signatures` (they rely on file-globs only) and are checked only during file creation/moves.

### Step 4: Severity

| Severity | When | Default Action |
|----------|------|---------------|
| `p1` | Correctness or safety issue | Blocks merge |
| `p2` | Maintainability issue | Should fix |
| `p3` | Style/taste preference | Nice to have |

### Step 5: Register

Same as skills — run `build-index.ts`.

## Anti-Patterns

| Anti-Pattern | Why It's Wrong |
|--------------|----------------|
| Skills without "When NOT to Use" | False matches waste time |
| Vague descriptions ("Use for code stuff") | CSO lint will reject it. Be specific. |
| Skills over 500 lines | Split into SKILL.md + references/ |
| Patterns without code examples | Patterns must show the preferred way, concretely |
| All P1 severity | Only correctness/safety issues are P1. Most patterns are P2-P3. |

## Chaining

None — this is a terminal skill.
