#!/bin/bash

# macOS-specific dotfiles installer

set -e

echo "🍎 Installing macOS configurations..."

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install tools using Homebrew
echo "📦 Installing tools..."

if command_exists brew; then
    echo "Installing Nushell..."
    brew install nushell

    echo "Installing Starship..."
    brew install starship

    echo "Installing Alacritty..."
    brew install --cask alacritty

    echo "Installing WezTerm..."
    brew install --cask wezterm

    echo "Installing Neovim..."
    brew install neovim

    echo "Installing Git (if not present)..."
    brew install git
else
    echo "⚠️  Homebrew not found. Installing Homebrew first..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for this session
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    
    echo "Installing tools with Homebrew..."
    brew install nushell starship neovim git
    brew install --cask alacritty wezterm
fi

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

echo "✅ macOS configuration installation complete!"