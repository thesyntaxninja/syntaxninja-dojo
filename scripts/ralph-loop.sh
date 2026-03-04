#!/bin/bash
# ralph-loop.sh — Autonomous loop runner for the SyntaxNinja Dojo training loop
#
# Reads PROMPT.md and feeds it to `claude --print` each iteration.
# Checks status.json and prd.json for completion between rounds.
# Configurable checkpoints via environment variables.
#
# Usage:
#   bash scripts/ralph-loop.sh [max_iterations]
#
# Environment:
#   RALPH_DIR          — State directory (default: .claude/plugin/ralph)
#   CHECKPOINT         — none | per-iteration | per-story | end-only (default: per-story)
#   CHECKPOINT_STYLE   — normal | squash (default: squash)
#   SKIP_PERMISSIONS   — true | false (default: false)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RALPH_DIR="${RALPH_DIR:-.claude/plugin/ralph}"
MAX_ITERATIONS="${1:-20}"
CHECKPOINT="${CHECKPOINT:-per-story}"
CHECKPOINT_STYLE="${CHECKPOINT_STYLE:-squash}"
ITERATION=0
CHECKPOINT_BRANCH=""

# Validate prerequisites
if [ ! -f "$RALPH_DIR/PROMPT.md" ]; then
    echo "ERROR: $RALPH_DIR/PROMPT.md not found."
    echo "Run the ralph-loop skill first to generate artifacts."
    exit 1
fi

if ! command -v claude &> /dev/null; then
    echo "ERROR: claude CLI not found in PATH."
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "ERROR: jq not found in PATH. Install it: brew install jq"
    exit 1
fi

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
        local count
        count=$(jq -r '.completed_stories | length' "$RALPH_DIR/status.json")
        git reset --soft "$CHECKPOINT_BRANCH"
        git commit -m "dojo: $count stories completed"
    fi
}

echo "=== SyntaxNinja Dojo: Training Loop ==="
echo "  Max iterations: $MAX_ITERATIONS"
echo "  Checkpoint: $CHECKPOINT ($CHECKPOINT_STYLE)"
echo "  State dir: $RALPH_DIR"
echo "  Skip permissions: ${SKIP_PERMISSIONS:-false}"
echo ""

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

    if jq -e '[.stories[].passes] | all' "$RALPH_DIR/prd.json" > /dev/null 2>&1; then
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
