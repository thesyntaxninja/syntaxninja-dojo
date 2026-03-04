#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Run the TypeScript index builder via npx tsx
npx tsx "$SCRIPT_DIR/build-index.ts" "$@"
