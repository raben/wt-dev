#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="${1:-$HOME/.local/bin}"

echo "Uninstalling wt-dev from $INSTALL_DIR ..."

for name in wt-create wt-remove wt-list wt-port-registry; do
  target="$INSTALL_DIR/$name"
  if [ -L "$target" ] || [ -e "$target" ]; then
    rm "$target"
    echo "  Removed $name"
  fi
done

echo "Uninstalled. State directory (~/.wt-dev/) was kept."
