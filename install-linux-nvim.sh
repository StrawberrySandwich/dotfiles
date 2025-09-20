#!/bin/bash

# Linux Neovim Installation Script
# Installs Neovim and applies personal configuration

set -e

echo "🚀 Starting Linux Neovim installation..."

# Check if running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo "❌ This script is designed for Linux only"
    exit 1
fi

# Function to detect package manager
detect_package_manager() {
    if command -v apt &> /dev/null; then
        echo "apt"
    elif command -v yum &> /dev/null; then
        echo "yum"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    elif command -v pacman &> /dev/null; then
        echo "pacman"
    elif command -v zypper &> /dev/null; then
        echo "zypper"
    else
        echo "unknown"
    fi
}

# Install Neovim based on package manager
install_neovim() {
    local pm=$(detect_package_manager)

    echo "📦 Installing Neovim using $pm..."

    case $pm in
        "apt")
            sudo apt update
            sudo apt install -y neovim
            ;;
        "yum")
            sudo yum install -y neovim
            ;;
        "dnf")
            sudo dnf install -y neovim
            ;;
        "pacman")
            sudo pacman -S --noconfirm neovim
            ;;
        "zypper")
            sudo zypper install -y neovim
            ;;
        "unknown")
            echo "❌ Package manager not detected. Please install Neovim manually."
            echo "Visit: https://github.com/neovim/neovim/wiki/Installing-Neovim"
            exit 1
            ;;
    esac
}

# Install additional dependencies
install_dependencies() {
    local pm=$(detect_package_manager)

    echo "📦 Installing additional dependencies..."

    case $pm in
        "apt")
            sudo apt install -y git curl build-essential
            ;;
        "yum")
            sudo yum groupinstall -y "Development Tools"
            sudo yum install -y git curl
            ;;
        "dnf")
            sudo dnf groupinstall -y "Development Tools"
            sudo dnf install -y git curl
            ;;
        "pacman")
            sudo pacman -S --noconfirm git curl base-devel
            ;;
        "zypper")
            sudo zypper install -y git curl gcc make
            ;;
    esac
}

# Install Node.js (required for many LSP servers)
install_nodejs() {
    if ! command -v node &> /dev/null; then
        echo "📦 Installing Node.js..."
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
        sudo apt-get install -y nodejs
    else
        echo "✅ Node.js already installed"
    fi
}

# Setup Neovim configuration
setup_nvim_config() {
    echo "⚙️  Setting up Neovim configuration..."

    # Get the directory where this script is located
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # Remove existing config if it exists
    if [ -d "$HOME/.config/nvim" ]; then
        echo "🗑️  Removing existing Neovim configuration..."
        rm -rf "$HOME/.config/nvim"
    fi

    # Create .config directory if it doesn't exist
    mkdir -p "$HOME/.config"

    # Copy Neovim configuration
    if [ -d "$SCRIPT_DIR/nvim" ]; then
        echo "📁 Copying Neovim configuration..."
        cp -r "$SCRIPT_DIR/nvim" "$HOME/.config/"
        echo "✅ Neovim configuration copied successfully"
    else
        echo "❌ nvim directory not found in $SCRIPT_DIR"
        exit 1
    fi
}

# Update Mason plugin references to use new organization
update_mason_config() {
    echo "🔧 Updating Mason plugin references..."

    find "$HOME/.config/nvim" -name "*.lua" -type f -exec sed -i 's/williamboman\/mason/mason-org\/mason/g' {} \;

    echo "✅ Mason plugin references updated"
}

# Main installation process
main() {
    echo "🐧 Linux Neovim Installation Script"
    echo "=================================="

    # Check if Neovim is already installed
    if command -v nvim &> /dev/null; then
        echo "✅ Neovim is already installed ($(nvim --version | head -n1))"
    else
        install_neovim
    fi

    # Install dependencies
    install_dependencies

    # Install Node.js if on Debian/Ubuntu
    if [[ $(detect_package_manager) == "apt" ]]; then
        install_nodejs
    fi

    # Setup configuration
    setup_nvim_config
    update_mason_config

    echo ""
    echo "🎉 Installation complete!"
    echo ""
    echo "Next steps:"
    echo "1. Run 'nvim' to start Neovim"
    echo "2. LazyVim will automatically install plugins on first run"
    echo "3. Use ':Mason' to install additional LSP servers"
    echo ""
    echo "Enjoy your Neovim setup! 🚀"
}

# Run the main function
main "$@"