#!/bin/bash

# Linux-specific dotfiles installer

set -e

echo "🐧 Installing Linux configurations..."

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect Linux distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo $ID
    elif command_exists lsb_release; then
        lsb_release -si | tr '[:upper:]' '[:lower:]'
    else
        echo "unknown"
    fi
}

# Install tools based on Linux distribution
echo "📦 Installing tools..."

DISTRO=$(detect_distro)

case $DISTRO in
    "ubuntu"|"debian"|"pop"|"mint")
        echo "Detected Debian-based distribution. Using apt..."
        sudo apt update
        
        # Install from repositories where available
        sudo apt install -y git curl
        
        # Install Starship
        echo "Installing Starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- --yes
        
        # Install Nushell (from GitHub releases)
        echo "Installing Nushell..."
        if ! command_exists nu; then
            curl -LO https://github.com/nushell/nushell/releases/latest/download/nu-$(curl -s https://api.github.com/repos/nushell/nushell/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')-x86_64-unknown-linux-gnu.tar.gz
            tar -xzf nu-*.tar.gz
            sudo mv nu-*/nu /usr/local/bin/
            rm -rf nu-*
        fi
        
        # Install Alacritty
        echo "Installing Alacritty..."
        sudo apt install -y alacritty || {
            echo "Alacritty not in repos, installing from GitHub..."
            # Add Alacritty PPA or build from source instructions here
            echo "Please install Alacritty manually from: https://alacritty.org/"
        }
        
        # Install WezTerm
        echo "Installing WezTerm..."
        if ! command_exists wezterm; then
            curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
            echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
            sudo apt update
            sudo apt install -y wezterm
        fi
        
        # Install Neovim
        echo "Installing Neovim..."
        sudo apt install -y neovim || {
            echo "Installing latest Neovim from GitHub..."
            curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
            chmod u+x nvim.appimage
            sudo mv nvim.appimage /usr/local/bin/nvim
        }
        ;;
        
    "arch"|"manjaro")
        echo "Detected Arch-based distribution. Using pacman..."
        sudo pacman -Sy --noconfirm git curl nushell starship alacritty neovim
        
        # Install WezTerm from AUR (requires yay or paru)
        if command_exists yay; then
            yay -S --noconfirm wezterm
        elif command_exists paru; then
            paru -S --noconfirm wezterm
        else
            echo "⚠️  Please install wezterm manually or install an AUR helper (yay/paru)"
        fi
        ;;
        
    "fedora"|"rhel"|"centos")
        echo "Detected Red Hat-based distribution. Using dnf/yum..."
        sudo dnf install -y git curl neovim || sudo yum install -y git curl neovim
        
        # Install Starship
        curl -sS https://starship.rs/install.sh | sh -s -- --yes
        
        # Install other tools (may need to enable additional repos)
        echo "⚠️  Some tools may need manual installation on Red Hat systems"
        echo "Please check: https://alacritty.org/ and https://wezfurlong.org/wezterm/"
        ;;
        
    *)
        echo "⚠️  Distribution not recognized. Installing minimal tools..."
        
        # Install Starship (works on most Linux systems)
        curl -sS https://starship.rs/install.sh | sh -s -- --yes
        
        echo "Please install the following tools manually:"
        echo "   - Nushell: https://www.nushell.sh/"
        echo "   - Alacritty: https://alacritty.org/"
        echo "   - WezTerm: https://wezfurlong.org/wezterm/"
        echo "   - Neovim: https://neovim.io/"
        ;;
esac

# Create config directories
echo "📁 Creating configuration directories..."
mkdir -p "$HOME/.config/alacritty"
mkdir -p "$HOME/.config/wezterm"
mkdir -p "$HOME/.config/nushell"
mkdir -p "$HOME/.config/nvim"
mkdir -p "$HOME/.config"

# Copy Alacritty config
echo "⚙️  Installing Alacritty configuration..."
cp "$SCRIPT_DIR/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"

# Copy WezTerm config
echo "⚙️  Installing WezTerm configuration..."
cp "$SCRIPT_DIR/wezterm/wezterm.lua" "$HOME/.config/wezterm/wezterm.lua"

# Copy Starship config
echo "⚙️  Installing Starship configuration..."
cp "$SCRIPT_DIR/starship/starship.toml" "$HOME/.config/starship.toml"

# Copy Nushell config
echo "⚙️  Installing Nushell configuration..."
cp "$SCRIPT_DIR/nushell/config.nu" "$HOME/.config/nushell/config.nu"
cp "$SCRIPT_DIR/nushell/rose-pine-moon.nu" "$HOME/.config/nushell/rose-pine-moon.nu"

# Copy Neovim config
echo "⚙️  Installing Neovim configuration..."
if [ -d "$SCRIPT_DIR/nvim" ]; then
    cp -r "$SCRIPT_DIR/nvim/"* "$HOME/.config/nvim/"
fi

echo "✅ Linux configuration installation complete!"