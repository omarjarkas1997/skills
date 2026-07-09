#!/usr/bin/env bash
set -euo pipefail
# Install grill-to-plan skill into ~/.config/opencode/skills/ for opencode/Claude/pi discovery.
# Also installs into the repo's .skills/ if present, for project-local discovery.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

install_to() {
  local target_dir="$1"
  mkdir -p "$target_dir"
  cp "$SCRIPT_DIR/SKILL.md" "$target_dir/SKILL.md"
  cp "$SCRIPT_DIR/README.md" "$target_dir/README.md"
  echo "grill-to-plan installed to $target_dir"
}

# Primary opencode/Claude/pi location
install_to "${HOME}/.config/opencode/skills/grill-to-plan"

# Optional project-local location
if [[ -d "$REPO_ROOT/.skills" ]] || [[ "$REPO_ROOT" == "$PWD" ]]; then
  install_to "$REPO_ROOT/.skills/grill-to-plan"
fi
