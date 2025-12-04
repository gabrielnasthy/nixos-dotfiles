#!/usr/bin/env bash
set -euo pipefail

ok() { echo -e "\033[32m[OK]\033[0m $*"; }
warn() { echo -e "\033[33m[WARN]\033[0m $*"; }
err() { echo -e "\033[31m[ERR]\033[0m $*"; }

missing=0
if ! command -v glxinfo >/dev/null; then
  warn "glxinfo não encontrado (instale mesa-demos)"
  missing=1
fi
if ! command -v vulkaninfo >/dev/null; then
  warn "vulkaninfo não encontrado (pacote vulkan-tools)"
  missing=1
fi

if [[ $missing -eq 1 ]]; then
  warn "Algumas ferramentas de teste não estão instaladas."
fi

if command -v glxinfo >/dev/null; then
  echo "--- OpenGL ---"
  glxinfo | grep -i 'opengl renderer' || true
fi

if command -v vulkaninfo >/dev/null; then
  echo "--- Vulkan ---"
  vulkaninfo | grep -n "GPU id" || true
fi
