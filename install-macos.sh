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
    brew install --cask alacritty || echo "Alacritty already installed or installation failed, continuing..."

    echo "Installing WezTerm..."
    brew install --cask wezterm || echo "WezTerm already installed or installation failed, continuing..."

    echo "Installing Neovim..."
    brew install neovim || echo "Neovim already installed or installation failed, continuing..."

    echo "Installing Git (if not present)..."
    brew install git || echo "Git already installed or installation failed, continuing..."
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
    brew install nushell starship neovim git || echo "Some tools already installed or installation failed, continuing..."
    brew install --cask alacritty wezterm || echo "Some GUI apps already installed or installation failed, continuing..."
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

# Copy Nushell config to macOS location
echo "⚙️  Installing Nushell configuration..."
NUSHELL_CONFIG_DIR="$HOME/Library/Application Support/nushell"
mkdir -p "$NUSHELL_CONFIG_DIR"
cp "$SCRIPT_DIR/nushell/config.nu" "$NUSHELL_CONFIG_DIR/config.nu"
cp "$SCRIPT_DIR/nushell/rose-pine-moon.nu" "$NUSHELL_CONFIG_DIR/rose-pine-moon.nu"
# Also create env.nu if it doesn't exist
if [ ! -f "$NUSHELL_CONFIG_DIR/env.nu" ]; then
    cp "$SCRIPT_DIR/nushell/env.nu" "$NUSHELL_CONFIG_DIR/env.nu" 2>/dev/null || \
    echo "# Nushell Environment Config File" > "$NUSHELL_CONFIG_DIR/env.nu"
fi

# Copy Neovim config
echo "⚙️  Installing Neovim configuration..."
if [ -d "$SCRIPT_DIR/nvim" ]; then
    cp -r "$SCRIPT_DIR/nvim/"* "$HOME/.config/nvim/"
fi

# Add Homebrew to PATH in shell profiles
echo "🔧 Setting up PATH for Homebrew tools..."

# Determine Homebrew path
if [[ -f /opt/homebrew/bin/brew ]]; then
    HOMEBREW_PATH="/opt/homebrew/bin"
    HOMEBREW_SHELLENV='eval "$(/opt/homebrew/bin/brew shellenv)"'
elif [[ -f /usr/local/bin/brew ]]; then
    HOMEBREW_PATH="/usr/local/bin"
    HOMEBREW_SHELLENV='eval "$(/usr/local/bin/brew shellenv)"'
else
    echo "⚠️  Homebrew not found, skipping PATH setup"
    HOMEBREW_PATH=""
fi

if [ -n "$HOMEBREW_PATH" ]; then
    # Add to .zshrc if it exists or create it
    if [ -f "$HOME/.zshrc" ] || [ "$SHELL" = "/bin/zsh" ] || [ "$SHELL" = "/usr/bin/zsh" ]; then
        if ! grep -q "brew shellenv" "$HOME/.zshrc" 2>/dev/null; then
            echo "" >> "$HOME/.zshrc"
            echo "# Added by dotfiles installer" >> "$HOME/.zshrc"
            echo "$HOMEBREW_SHELLENV" >> "$HOME/.zshrc"
            echo "Added Homebrew to .zshrc"
        fi
    fi

    # Add to .bash_profile if it exists or bash is the shell
    if [ -f "$HOME/.bash_profile" ] || [ "$SHELL" = "/bin/bash" ] || [ "$SHELL" = "/usr/bin/bash" ]; then
        if ! grep -q "brew shellenv" "$HOME/.bash_profile" 2>/dev/null; then
            echo "" >> "$HOME/.bash_profile"
            echo "# Added by dotfiles installer" >> "$HOME/.bash_profile"
            echo "$HOMEBREW_SHELLENV" >> "$HOME/.bash_profile"
            echo "Added Homebrew to .bash_profile"
        fi
    fi

    # Add to .profile as fallback
    if ! grep -q "brew shellenv" "$HOME/.profile" 2>/dev/null; then
        echo "" >> "$HOME/.profile"
        echo "# Added by dotfiles installer" >> "$HOME/.profile"
        echo "$HOMEBREW_SHELLENV" >> "$HOME/.profile"
        echo "Added Homebrew to .profile"
    fi
fi

echo "✅ macOS configuration installation complete!"