#!/usr/bin/env bash
set -euo pipefail

############################################################
# PXDesign Pixi-based Installation & Setup Script
#
# Features:
#   - Fast & reproducible package management via Pixi
#   - Automatic CUDA/cuDNN + PyTorch + JAX environment sync
#   - Clones CUTLASS v3.5.1 if not present
#   - Runs sanity checks
############################################################

SECONDS=0
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${DIR}"

echo "=================================================="
echo " PXDesign Setup with Pixi"
echo " Directory: ${DIR}"
echo "=================================================="

# 1. Check if pixi is installed
if ! command -v pixi >/dev/null 2>&1; then
  echo ">>> Pixi is not found in PATH."
  echo "    Attempting to locate brew-installed or local pixi..."
  if [ -x "/home/linuxbrew/.linuxbrew/bin/pixi" ]; then
    export PATH="/home/linuxbrew/.linuxbrew/bin:${PATH}"
  elif [ -x "$HOME/.pixi/bin/pixi" ]; then
    export PATH="$HOME/.pixi/bin:${PATH}"
  else
    echo "Error: Pixi is not installed. Install via: curl -fsSL https://pixi.sh/install.sh | bash"
    exit 1
  fi
fi

echo "Using Pixi: $(which pixi) ($(pixi --version))"

# 2. Clone CUTLASS (required for DeepSpeed Evo attention)
export CUTLASS_PATH="${CUTLASS_PATH:-$HOME/cutlass}"
echo ">>> [CUTLASS] Path: ${CUTLASS_PATH}"
if [ ! -d "${CUTLASS_PATH}" ]; then
  echo ">>> Cloning NVIDIA/cutlass v3.5.1 into ${CUTLASS_PATH}..."
  git clone --depth 1 -b v3.5.1 https://github.com/NVIDIA/cutlass.git "${CUTLASS_PATH}"
else
  echo ">>> CUTLASS repository already exists, skipping clone."
fi

# 3. Pixi environment install / sync
echo ">>> Installing dependencies with Pixi..."
pixi install

# 4. Run sanity checks
echo ">>> Running sanity checks..."
pixi run test

echo ">>> Checking PXDesign CLI..."
pixi run run

t=${SECONDS}
echo "=================================================="
echo " PXDesign setup completed successfully!"
echo " Duration: $((t / 3600))h $(((t / 60) % 60))m $((t % 60))s"
echo
echo " Usage examples:"
echo "   pixi run pxdesign --help"
echo "   pixi run bash   (or: pixi shell)"
echo "=================================================="
