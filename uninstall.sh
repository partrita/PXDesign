#!/usr/bin/env bash
set -euo pipefail

############################################################
# PXDesign Pixi-based Environment Clean/Uninstall Script
#
# Removes:
#   - Pixi environment (.pixi directory)
#   - Pixi lockfile (pixi.lock, optional prompt or flag)
#   - Build artifacts / cache (*.egg-info, __pycache__)
#   - Optionally prompts to remove CUTLASS ($CUTLASS_PATH)
############################################################

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${DIR}"

echo "=================================================="
echo " PXDesign Environment Cleanup / Uninstall"
echo " Directory: ${DIR}"
echo "=================================================="

# 1. Clean Pixi environment using pixi clean or manual deletion
if [ -d "${DIR}/.pixi" ]; then
  echo ">>> Removing Pixi environment (.pixi/)..."
  if command -v pixi >/dev/null 2>&1; then
    pixi clean -y || true
  fi
  rm -rf "${DIR}/.pixi"
  echo "    .pixi removed."
else
  echo ">>> No .pixi environment directory found."
fi

# 2. Remove lockfile if requested or present
if [ -f "${DIR}/pixi.lock" ]; then
  read -r -p ">>> Remove pixi.lock as well? [y/N]: " remove_lock || remove_lock="n"
  if [[ "${remove_lock}" =~ ^[Yy]$ ]]; then
    rm -f "${DIR}/pixi.lock"
    echo "    pixi.lock removed."
  fi
fi

# 3. Clean python build artifacts
echo ">>> Cleaning build artifacts (*.egg-info, __pycache__)..."
find "${DIR}" -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
find "${DIR}" -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find "${DIR}" -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true

# 4. Optional CUTLASS cleanup
CUTLASS_PATH="${CUTLASS_PATH:-$HOME/cutlass}"
if [ -d "${CUTLASS_PATH}" ]; then
  echo ">>> Found CUTLASS at: ${CUTLASS_PATH}"
  read -r -p ">>> Do you also want to remove CUTLASS repository? [y/N]: " remove_cutlass || remove_cutlass="n"
  if [[ "${remove_cutlass}" =~ ^[Yy]$ ]]; then
    rm -rf "${CUTLASS_PATH}"
    echo "    ${CUTLASS_PATH} removed."
  else
    echo "    Preserving CUTLASS."
  fi
fi

echo "=================================================="
echo " PXDesign uninstall/cleanup finished!"
echo "=================================================="
