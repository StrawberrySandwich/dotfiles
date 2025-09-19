#!/bin/bash

# Windows-specific dotfiles installer

set -e

echo "🪟 Installing Windows configurations..."

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install tools using winget
echo "📦 Installing tools..."

if command_exists winget; then
    echo "Installing Nushell..."
    winget install --id nushell.nushell --silent --accept-package-agreements --accept-source-agreements

    echo "Installing Starship..."
    winget install --id Starship.Starship --silent --accept-package-agreements --accept-source-agreements

    echo "Installing Alacritty..."
    winget install --id Alacritty.Alacritty --silent --accept-package-agreements --accept-source-agreements

    echo "Installing WezTerm..."
    winget install --id wez.wezterm --silent --accept-package-agreements --accept-source-agreements

    echo "Installing Neovim..."
    winget install --id Neovim.Neovim --silent --accept-package-agreements --accept-source-agreements

    echo "Installing Git (if not present)..."
    winget install --id Git.Git --silent --accept-package-agreements --accept-source-agreements
else
    echo "⚠️  winget not found. Please install tools manually:"
    echo "   - Nushell: https://www.nushell.sh/"
    echo "   - Starship: https://starship.rs/"
    echo "   - Alacritty: https://alacritty.org/"
    echo "   - WezTerm: https://wezfurlong.org/wezterm/"
    echo "   - Neovim: https://neovim.io/"
fi

# Create config directories
echo "📁 Creating configuration directories..."
mkdir -p "$APPDATA/alacritty"
mkdir -p "$USERPROFILE/.config/wezterm"
mkdir -p "$USERPROFILE/.config"
mkdir -p "$APPDATA/nushell"
mkdir -p "$LOCALAPPDATA/nvim"

# Copy Alacritty config
echo "⚙️  Installing Alacritty configuration..."
cp "$SCRIPT_DIR/alacritty/alacritty.toml" "$APPDATA/alacritty/alacritty.toml"

# Copy WezTerm config
echo "⚙️  Installing WezTerm configuration..."
cp "$SCRIPT_DIR/wezterm/wezterm.lua" "$USERPROFILE/.config/wezterm/wezterm.lua"

# Copy Starship config
echo "⚙️  Installing Starship configuration..."
cp "$SCRIPT_DIR/starship/starship.toml" "$USERPROFILE/.config/starship.toml"

# Copy Nushell config
echo "⚙️  Installing Nushell configuration..."
cp "$SCRIPT_DIR/nushell/config.nu" "$APPDATA/nushell/config.nu"
cp "$SCRIPT_DIR/nushell/rose-pine-moon.nu" "$APPDATA/nushell/rose-pine-moon.nu"

# Copy Neovim config
echo "⚙️  Installing Neovim configuration..."
if [ -d "$SCRIPT_DIR/nvim" ]; then
    cp -r "$SCRIPT_DIR/nvim/"* "$LOCALAPPDATA/nvim/"
fi

echo "✅ Windows configuration installation complete!"