#!/bin/bash

# Linux Neovim + Nushell + Starship Installation Script
# Installs Neovim, Nushell, Starship, and applies personal configurations

set -e

echo "🚀 Starting Linux Neovim + Nushell + Starship installation..."

# Check if running on Linux
if [ "$(uname)" != "Linux" ]; then
    echo "❌ This script is designed for Linux only"
    exit 1
fi

# Function to detect package manager
detect_package_manager() {
    if command -v apt >/dev/null 2>&1; then
        echo "apt"
    elif command -v yum >/dev/null 2>&1; then
        echo "yum"
    elif command -v dnf >/dev/null 2>&1; then
        echo "dnf"
    elif command -v pacman >/dev/null 2>&1; then
        echo "pacman"
    elif command -v zypper >/dev/null 2>&1; then
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
    if ! command -v node >/dev/null 2>&1; then
        echo "📦 Installing Node.js..."
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
        sudo apt-get install -y nodejs
    else
        echo "✅ Node.js already installed"
    fi
}

# Install Nushell
install_nushell() {
    if command -v nu >/dev/null 2>&1; then
        echo "✅ Nushell already installed ($(nu --version | head -n1))"
        return
    fi

    echo "🐚 Installing Nushell..."

    # Download and install the latest Nushell release
    local arch=$(uname -m)
    local os="unknown-linux-musl"

    # Map architecture names
    case $arch in
        "x86_64")
            arch="x86_64"
            ;;
        "aarch64"|"arm64")
            arch="aarch64"
            ;;
        "armv7l")
            arch="armv7"
            os="unknown-linux-gnueabihf"
            ;;
        *)
            echo "❌ Unsupported architecture: $arch"
            echo "Please install Nushell manually from: https://github.com/nushell/nushell/releases"
            return 1
            ;;
    esac

    # Get latest release URL
    local latest_url="https://api.github.com/repos/nushell/nushell/releases/latest"
    local download_url=$(curl -s "$latest_url" | grep -o "https://github.com/nushell/nushell/releases/download/[^\"]*nu-[^\"]*${arch}-${os}\.tar\.gz" | head -n1)

    if [ -z "$download_url" ]; then
        echo "❌ Could not find Nushell release for $arch-$os"
        echo "Trying package manager installation..."

        local pm=$(detect_package_manager)
        case $pm in
            "apt")
                # Nushell not in standard Ubuntu repos, try cargo
                install_nushell_via_cargo
                ;;
            "dnf")
                sudo dnf install -y nushell
                ;;
            "pacman")
                sudo pacman -S --noconfirm nushell
                ;;
            *)
                install_nushell_via_cargo
                ;;
        esac
        return
    fi

    echo "📦 Downloading Nushell from: $download_url"

    # Create temporary directory
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"

    # Download and extract
    curl -L "$download_url" -o nushell.tar.gz
    tar -xzf nushell.tar.gz

    # Find the extracted directory and install
    local extract_dir=$(find . -maxdepth 1 -type d -name "nu-*" | head -n1)
    if [ -n "$extract_dir" ]; then
        sudo cp "$extract_dir/nu" /usr/local/bin/
        sudo chmod +x /usr/local/bin/nu
        echo "✅ Nushell installed to /usr/local/bin/nu"
    else
        echo "❌ Failed to extract Nushell"
        install_nushell_via_cargo
    fi

    # Cleanup
    cd - >/dev/null
    rm -rf "$temp_dir"
}

# Install Nushell via Cargo (fallback method)
install_nushell_via_cargo() {
    echo "🦀 Installing Nushell via Cargo..."

    # Install Rust if not present
    if ! command -v cargo >/dev/null 2>&1; then
        echo "📦 Installing Rust toolchain..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
    fi

    # Install nushell via cargo
    cargo install nu --features=extra

    # Add cargo bin to PATH if not already there
    if ! echo "$PATH" | grep -q "$HOME/.cargo/bin"; then
        echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> "$HOME/.bashrc"
        echo "✅ Added cargo bin to PATH in .bashrc"
    fi
}


# Install Starship prompt
install_starship() {
    if command -v starship >/dev/null 2>&1; then
        echo "✅ Starship already installed ($(starship --version))"
        return
    fi

    echo "✨ Installing Starship prompt..."

    # Use the official Starship installer
    curl -sS https://starship.rs/install.sh | sh -s -- -y

    # Alternative method if the installer fails
    if ! command -v starship >/dev/null 2>&1; then
        echo "🔄 Trying alternative installation method..."

        local arch=$(uname -m)
        local os="unknown-linux-musl"

        # Map architecture names for Starship
        case $arch in
            "x86_64")
                arch="x86_64"
                ;;
            "aarch64"|"arm64")
                arch="aarch64"
                ;;
            "armv7l")
                arch="arm"
                os="unknown-linux-gnueabihf"
                ;;
            *)
                echo "❌ Unsupported architecture for Starship: $arch"
                echo "Trying cargo installation..."
                install_starship_via_cargo
                return
                ;;
        esac

        # Download latest release
        local latest_url="https://api.github.com/repos/starship/starship/releases/latest"
        local download_url=$(curl -s "$latest_url" | grep -o "https://github.com/starship/starship/releases/download/[^\"]*starship-${arch}-${os}\.tar\.gz" | head -n1)

        if [ -n "$download_url" ]; then
            echo "📦 Downloading Starship from: $download_url"
            local temp_dir=$(mktemp -d)
            cd "$temp_dir"

            curl -L "$download_url" -o starship.tar.gz
            tar -xzf starship.tar.gz

            if [ -f "starship" ]; then
                sudo mv starship /usr/local/bin/
                sudo chmod +x /usr/local/bin/starship
                echo "✅ Starship installed to /usr/local/bin/starship"
            else
                echo "❌ Failed to extract Starship binary"
                install_starship_via_cargo
            fi

            cd - >/dev/null
            rm -rf "$temp_dir"
        else
            echo "❌ Could not find Starship release for $arch-$os"
            install_starship_via_cargo
        fi
    fi
}

# Install Starship via Cargo (fallback method)
install_starship_via_cargo() {
    echo "🦀 Installing Starship via Cargo..."

    # Install Rust if not present
    if ! command -v cargo >/dev/null 2>&1; then
        echo "📦 Installing Rust toolchain for Starship..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
    fi

    # Install starship via cargo
    cargo install starship --locked

    # Add cargo bin to PATH if not already there
    if ! echo "$PATH" | grep -q "$HOME/.cargo/bin"; then
        echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> "$HOME/.bashrc"
        echo "✅ Added cargo bin to PATH in .bashrc"
    fi
}

# Setup Neovim configuration
setup_nvim_config() {
    echo "⚙️  Setting up Neovim configuration..."

    # Get the directory where this script is located
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

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

# Setup Nushell configuration
setup_nushell_config() {
    echo "🐚 Setting up Nushell configuration..."

    # Get the directory where this script is located
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

    # Create nushell config directory
    mkdir -p "$HOME/.config/nushell"

    # Copy nushell configuration files
    if [ -f "$SCRIPT_DIR/nushell/config.nu" ]; then
        echo "📁 Copying config.nu..."
        cp "$SCRIPT_DIR/nushell/config.nu" "$HOME/.config/nushell/"
    else
        echo "⚠️  config.nu not found in $SCRIPT_DIR/nushell/"
    fi

    if [ -f "$SCRIPT_DIR/nushell/env.nu" ]; then
        echo "📁 Copying env.nu..."
        cp "$SCRIPT_DIR/nushell/env.nu" "$HOME/.config/nushell/"
    else
        echo "⚠️  env.nu not found in $SCRIPT_DIR/nushell/"
    fi

    # Copy any other nushell config files
    if [ -d "$SCRIPT_DIR/nushell" ]; then
        echo "📁 Copying additional nushell config files..."
        for file in "$SCRIPT_DIR/nushell"/*; do
            if [ -f "$file" ] && [ "$(basename "$file")" != "config.nu" ] && [ "$(basename "$file")" != "env.nu" ]; then
                cp "$file" "$HOME/.config/nushell/"
                echo "  Copied $(basename "$file")"
            fi
        done
    fi

    echo "✅ Nushell configuration setup complete"
}

# Setup Starship configuration
setup_starship_config() {
    echo "✨ Setting up Starship configuration..."

    # Get the directory where this script is located
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

    # Create config directory
    mkdir -p "$HOME/.config"

    # Copy starship configuration files
    if [ -f "$SCRIPT_DIR/starship/starship.toml" ]; then
        echo "📁 Copying starship.toml..."
        cp "$SCRIPT_DIR/starship/starship.toml" "$HOME/.config/"
        echo "✅ Starship configuration copied to ~/.config/starship.toml"
    else
        echo "❌ starship.toml not found in $SCRIPT_DIR/starship/"
        exit 1
    fi

    # Copy any additional starship config files
    if [ -d "$SCRIPT_DIR/starship" ]; then
        echo "📁 Copying additional starship config files..."
        for file in "$SCRIPT_DIR/starship"/*; do
            if [ -f "$file" ] && [ "$(basename "$file")" != "starship.toml" ]; then
                cp "$file" "$HOME/.config/"
                echo "  Copied $(basename "$file") to ~/.config/"
            fi
        done
    fi

    echo "✅ Starship configuration setup complete"
}


# Main installation process
main() {
    echo "🐧 Linux Neovim + Nushell + Starship Installation Script"
    echo "======================================================="

    # Check if Neovim is already installed
    if command -v nvim >/dev/null 2>&1; then
        echo "✅ Neovim is already installed ($(nvim --version | head -n1))"
    else
        echo "📦 Neovim not found, installing..."
        install_neovim
    fi

    # Install Nushell
    install_nushell

    # Install Starship
    install_starship

    # Install dependencies
    install_dependencies

    # Install Node.js if on Debian/Ubuntu
    if [ "$(detect_package_manager)" = "apt" ]; then
        install_nodejs
    fi

    # Setup configurations
    setup_nvim_config
    setup_nushell_config
    setup_starship_config

    echo ""
    echo "🎉 Installation complete!"
    echo ""
    echo "Next steps:"
    echo "1. Run 'nvim' to start Neovim"
    echo "2. LazyVim will automatically install plugins on first run"
    echo "3. Use ':Mason' to install additional LSP servers"
    echo "4. Run 'nu' to start Nushell with your configuration"
    echo "5. Starship prompt is ready to use (add 'eval \"\$(starship init bash)\"' to .bashrc for bash)"
    echo "6. Consider setting Nushell as default shell: chsh -s \$(which nu)"
    echo ""
    echo "Enjoy your complete development setup! 🚀✨"
}

# Run the main function
main "$@"