#!/usr/bin/env bash
set -euo pipefail

# install.sh: Install wt-dev scripts to ~/.local/bin/

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_DIR="${1:-$HOME/.local/bin}"

echo "Installing wt-dev to $INSTALL_DIR ..."

mkdir -p "$INSTALL_DIR"

for script in "$SCRIPT_DIR"/bin/wt-*; do
  name=$(basename "$script")
  target="$INSTALL_DIR/$name"

  if [ -L "$target" ] || [ -e "$target" ]; then
    rm "$target"
  fi

  ln -s "$script" "$target"
  echo "  $name -> $script"
done

# Ensure scripts are executable
chmod +x "$SCRIPT_DIR"/bin/wt-*

# Check PATH
if ! echo "$PATH" | tr ':' '\n' | grep -q "^${INSTALL_DIR}$"; then
  echo ""
  echo "WARNING: $INSTALL_DIR is not in your PATH."
  echo "Add this to your shell profile (~/.zshrc or ~/.bashrc):"
  echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
fi

# Check dependencies
echo ""
echo "Checking dependencies..."
for dep in jq docker git; do
  if command -v "$dep" &>/dev/null; then
    echo "  $dep: OK"
  else
    echo "  $dep: MISSING (required)"
  fi
done

for dep in devcontainer; do
  if command -v "$dep" &>/dev/null; then
    echo "  $dep: OK"
  else
    echo "  $dep: MISSING (install with: npm install -g @devcontainers/cli)"
  fi
done

echo ""
echo "Installation complete."
echo ""
echo "Setup Claude Code hooks (optional):"
echo "  Add WorktreeCreate/WorktreeRemove hooks to ~/.claude/settings.json"
echo "  See: https://docs.anthropic.com/en/docs/claude-code/hooks"
