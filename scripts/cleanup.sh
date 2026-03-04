#!/bin/bash
# cleanup.sh — Clean up SyntaxNinja Dojo runtime state from the current project
#
# Removes .claude/plugin/, stale agent symlinks, and worktrees.
# Does NOT remove .claude/agents/ if it contains non-symlink files.
# Does NOT remove docs/learnings/ (those are committed).
#
# Usage:
#   bash /path/to/syntaxninja-dojo/scripts/cleanup.sh [--force]

set -euo pipefail

FORCE="${1:-}"
PROJECT_ROOT="$(pwd)"

echo "SyntaxNinja Dojo — Cleanup"
echo "  Project: $PROJECT_ROOT"
echo ""

# ---------------------------------------------------------------------------
# 1. Remove runtime state
# ---------------------------------------------------------------------------

PLUGIN_DIR="$PROJECT_ROOT/.claude/plugin"

if [ -d "$PLUGIN_DIR" ]; then
  # Check for active worktrees
  WORKTREES_DIR="$PLUGIN_DIR/worktrees"
  if [ -d "$WORKTREES_DIR" ] && [ "$(ls -A "$WORKTREES_DIR" 2>/dev/null)" ]; then
    echo "  WARNING: Active worktrees found in $WORKTREES_DIR"
    if [ "$FORCE" != "--force" ]; then
      echo "  Run 'git worktree list' to see them."
      echo "  Use --force to remove anyway, or clean up worktrees manually first."
      echo ""
    else
      echo "  Removing worktrees (--force)..."
      for wt in "$WORKTREES_DIR"/*/; do
        if [ -d "$wt" ]; then
          wt_name="$(basename "$wt")"
          git worktree remove --force "$wt" 2>/dev/null || true
          echo "    Removed worktree: $wt_name"
        fi
      done
    fi
  fi

  rm -rf "$PLUGIN_DIR"
  echo "  Removed .claude/plugin/"
else
  echo "  No .claude/plugin/ found"
fi

# ---------------------------------------------------------------------------
# 2. Remove agent symlinks (keep non-symlink files)
# ---------------------------------------------------------------------------

AGENTS_DIR="$PROJECT_ROOT/.claude/agents"

if [ -d "$AGENTS_DIR" ]; then
  stale=0
  for link in "$AGENTS_DIR/review/"*.md "$AGENTS_DIR/research/"*.md; do
    if [ -L "$link" ]; then
      rm "$link"
      stale=$((stale + 1))
    fi
  done

  # Remove empty directories
  rmdir "$AGENTS_DIR/review" 2>/dev/null || true
  rmdir "$AGENTS_DIR/research" 2>/dev/null || true
  rmdir "$AGENTS_DIR" 2>/dev/null || true

  if [ $stale -gt 0 ]; then
    echo "  Removed $stale agent symlinks"
  else
    echo "  No agent symlinks found"
  fi
else
  echo "  No .claude/agents/ found"
fi

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------

echo ""
echo "  Cleanup complete."
echo "  Note: docs/learnings/ was NOT removed (committed content)."
