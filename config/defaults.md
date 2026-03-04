# SyntaxNinja Dojo — Default Configuration
#
# Override these in your project:
#   1. dojo.config.md (repo root — discoverable in PRs)
#   2. .claude/dojo-config.md (fallback)
#   3. ~/.claude/plugins/syntaxninja-dojo/config.md (global defaults)

## Sensei
- Strictness: medium              # low | medium | high
- Max simplification rounds: 2
- Pattern enforcement: warn       # warn | enforce | off

## Training Loop
- Max rounds: 20
- Checkpoint: per-story           # none | per-iteration | per-story | end-only
- Checkpoint style: squash        # normal | squash
- Run in worktree: true
- Worktree path: .claude/plugin/worktrees/<task-slug>/
- Skip permissions: false         # opt-in: set true for full automation

## Code Review
- Auto-dispatch agents: true      # dispatch review agents after self-review
- Minimum agents: 1               # at least simplicity-reviewer
- Maximum agents: 5               # all review agents for large changes

## Knowledge Capture
- Auto-propose learnings: true    # propose compound-docs after hard problems
- Skill update threshold: 3       # occurrences before proposing skill updates

## Scope Control
- Max files per task: 20          # suggest decomposition above this
- Max lines per task: 500         # suggest decomposition above this
