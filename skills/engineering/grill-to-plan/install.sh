#!/usr/bin/env bash
set -euo pipefail
# Install grill-to-plan skill into .skills/ for opencode/Claude/pi discovery.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
TARGET_DIR="$REPO_ROOT/.skills/grill-to-plan"

mkdir -p "$TARGET_DIR"
cp "$SCRIPT_DIR/SKILL.md" "$TARGET_DIR/SKILL.md"
cp "$SCRIPT_DIR/README.md" "$TARGET_DIR/README.md"

echo "grill-to-plan installed to $TARGET_DIR"
