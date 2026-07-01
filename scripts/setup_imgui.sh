#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VENDOR="$ROOT/vendor/imgui"
mkdir -p "$ROOT/vendor"
if [ ! -d "$VENDOR/.git" ]; then
  git clone --depth 1 --branch v1.91.8 https://github.com/ocornut/imgui.git "$VENDOR"
fi
echo "ImGui ready at $VENDOR"
