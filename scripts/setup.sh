#!/bin/bash
# setup.sh — Set up SyntaxNinja Dojo in the current project
#
# Creates .claude/plugin/ directories, symlinks agents, and builds
# the index if missing. Idempotent — safe to run multiple times.
#
# Usage:
#   bash /path/to/syntaxninja-dojo/scripts/setup.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(pwd)"

echo "SyntaxNinja Dojo — Setup"
echo "  Plugin: $PLUGIN_ROOT"
echo "  Project: $PROJECT_ROOT"
echo ""

# ---------------------------------------------------------------------------
# 1. Create runtime directories
# ---------------------------------------------------------------------------

mkdir -p "$PROJECT_ROOT/.claude/plugin/ralph/notes"
mkdir -p "$PROJECT_ROOT/.claude/plugin/runs"
mkdir -p "$PROJECT_ROOT/.claude/plugin/cache"
mkdir -p "$PROJECT_ROOT/.claude/plugin/state"
mkdir -p "$PROJECT_ROOT/.claude/plugin/worktrees"
echo "  Created .claude/plugin/ directories"

# ---------------------------------------------------------------------------
# 2. Symlink agents
# ---------------------------------------------------------------------------

AGENTS_DIR="$PROJECT_ROOT/.claude/agents"
mkdir -p "$AGENTS_DIR/review"
mkdir -p "$AGENTS_DIR/research"

# Symlink review agents
for agent in "$PLUGIN_ROOT/agents/review/"*.md; do
  name="$(basename "$agent")"
  target="$AGENTS_DIR/review/$name"
  if [ -L "$target" ] || [ -f "$target" ]; then
    rm "$target"
  fi
  ln -s "$agent" "$target"
done

# Symlink research agents
for agent in "$PLUGIN_ROOT/agents/research/"*.md; do
  name="$(basename "$agent")"
  target="$AGENTS_DIR/research/$name"
  if [ -L "$target" ] || [ -f "$target" ]; then
    rm "$target"
  fi
  ln -s "$agent" "$target"
done

echo "  Symlinked agents → .claude/agents/"

# ---------------------------------------------------------------------------
# 3. Ensure .gitignore covers plugin runtime state
# ---------------------------------------------------------------------------

GITIGNORE="$PROJECT_ROOT/.gitignore"
IGNORE_RULE=".claude/plugin/**"

if [ -f "$GITIGNORE" ]; then
  if ! grep -qF "$IGNORE_RULE" "$GITIGNORE"; then
    echo "" >> "$GITIGNORE"
    echo "# SyntaxNinja Dojo runtime state" >> "$GITIGNORE"
    echo "$IGNORE_RULE" >> "$GITIGNORE"
    echo "  Added $IGNORE_RULE to .gitignore"
  else
    echo "  .gitignore already has $IGNORE_RULE"
  fi
else
  echo "# SyntaxNinja Dojo runtime state" > "$GITIGNORE"
  echo "$IGNORE_RULE" >> "$GITIGNORE"
  echo "  Created .gitignore with $IGNORE_RULE"
fi

# ---------------------------------------------------------------------------
# 4. Build index if missing
# ---------------------------------------------------------------------------

SKILL_INDEX="$PLUGIN_ROOT/skills/index.json"
PATTERN_INDEX="$PLUGIN_ROOT/patterns/index.json"

if [ ! -f "$SKILL_INDEX" ] || [ ! -f "$PATTERN_INDEX" ]; then
  echo "  Index missing — rebuilding..."
  if command -v npx &> /dev/null; then
    npx tsx "$PLUGIN_ROOT/scripts/build-index.ts"
  else
    echo "  WARNING: npx not found. Run 'npx tsx scripts/build-index.ts' manually."
  fi
else
  echo "  Indexes present (skills + patterns)"
fi

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------

echo ""
echo "  Setup complete. Start a new Claude Code session to activate."
