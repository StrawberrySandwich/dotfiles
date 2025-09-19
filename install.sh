#!/bin/bash

# Cross-platform dotfiles installer
# Detects OS and runs appropriate installation script

set -e

echo "🔧 Detecting operating system..."

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ -n "$WSL_DISTRO_NAME" ]]; then
    OS="windows"
else
    echo "❌ Unsupported OS: $OSTYPE"
    exit 1
fi

echo "Operating system detected: $OS"

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Run OS-specific installer
case $OS in
    "macos")
        echo "🍎 Running macOS installer..."
        bash "$SCRIPT_DIR/install-macos.sh"
        ;;
    "linux")
        echo "🐧 Running Linux installer..."
        bash "$SCRIPT_DIR/install-linux.sh"
        ;;
    "windows")
        echo "🪟 Running Windows installer..."
        bash "$SCRIPT_DIR/install-windows.sh"
        ;;
    *)
        echo "❌ No installer found for OS: $OS"
        exit 1
        ;;
esac

echo "✅ Installation complete!"