#!/bin/bash

# Dual-Output Image Compressor Installation Script
# Installs dependencies and sets up the tool for use

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Installation banner
show_banner() {
    echo -e "${BOLD}${BLUE}================================================================"
    echo "🚀 DUAL-OUTPUT IMAGE COMPRESSOR INSTALLER"
    echo "================================================================${NC}"
}

# Check if running on macOS
check_macos() {
    if [[ "$(uname)" != "Darwin" ]]; then
        echo -e "${YELLOW}⚠️  This tool is optimized for macOS with Apple Silicon${NC}"
        echo -e "${YELLOW}   It may work on other Unix systems but performance may vary${NC}"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 0
        fi
    fi
}

# Check for Homebrew
check_homebrew() {
    echo -e "${CYAN}🔍 Checking for Homebrew...${NC}"

    if ! command -v brew &> /dev/null; then
        echo -e "${YELLOW}📦 Homebrew not found. Installing...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add brew to PATH for current session
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f "/usr/local/bin/brew" ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    else
        echo -e "${GREEN}✓ Homebrew found${NC}"
    fi
}

# Install dependencies
install_dependencies() {
    echo -e "${CYAN}📦 Installing dependencies...${NC}"

    # Update Homebrew
    echo -e "${YELLOW}🔄 Updating Homebrew...${NC}"
    brew update

    # Install ImageMagick
    echo -e "${YELLOW}🎨 Installing ImageMagick...${NC}"
    if brew list imagemagick &>/dev/null; then
        echo -e "${GREEN}✓ ImageMagick already installed${NC}"
    else
        brew install imagemagick
        echo -e "${GREEN}✓ ImageMagick installed${NC}"
    fi

    # Install bc (basic calculator)
    echo -e "${YELLOW}🧮 Installing bc...${NC}"
    if brew list bc &>/dev/null; then
        echo -e "${GREEN}✓ bc already installed${NC}"
    else
        brew install bc
        echo -e "${GREEN}✓ bc installed${NC}"
    fi
}

# Make script executable
setup_permissions() {
    echo -e "${CYAN}🔧 Setting up permissions...${NC}"

    local script_path="$(dirname "$0")/../bin/dual_output_image_compressor.sh"

    if [[ -f "$script_path" ]]; then
        chmod +x "$script_path"
        echo -e "${GREEN}✓ Script made executable${NC}"
    else
        echo -e "${RED}❌ Main script not found at: $script_path${NC}"
        exit 1
    fi
}

# Create symlink for easy access
create_symlink() {
    echo -e "${CYAN}🔗 Creating system-wide symlink...${NC}"

    local script_path="$(cd "$(dirname "$0")/../bin" && pwd)/dual_output_image_compressor.sh"
    local symlink_path="/usr/local/bin/dual-compressor"

    # Remove existing symlink if it exists
    if [[ -L "$symlink_path" ]]; then
        sudo rm "$symlink_path"
    fi

    # Create new symlink
    if sudo ln -s "$script_path" "$symlink_path" 2>/dev/null; then
        echo -e "${GREEN}✓ Symlink created: dual-compressor${NC}"
        echo -e "${GREEN}  You can now run: dual-compressor [options]${NC}"
    else
        echo -e "${YELLOW}⚠️  Could not create system-wide symlink${NC}"
        echo -e "${YELLOW}   You can still run the script directly from: $script_path${NC}"
    fi
}

# Verify installation
verify_installation() {
    echo -e "${CYAN}🔍 Verifying installation...${NC}"

    # Check ImageMagick
    if command -v magick &> /dev/null; then
        local magick_version=$(magick -version | head -n1 | cut -d' ' -f3)
        echo -e "${GREEN}✓ ImageMagick ${magick_version} ready${NC}"
    else
        echo -e "${RED}❌ ImageMagick not found${NC}"
        exit 1
    fi

    # Check bc
    if command -v bc &> /dev/null; then
        echo -e "${GREEN}✓ bc calculator ready${NC}"
    else
        echo -e "${RED}❌ bc calculator not found${NC}"
        exit 1
    fi

    # Check main script
    local script_path="$(dirname "$0")/../bin/dual_output_image_compressor.sh"
    if [[ -x "$script_path" ]]; then
        echo -e "${GREEN}✓ Main script executable${NC}"
    else
        echo -e "${RED}❌ Main script not executable${NC}"
        exit 1
    fi
}

# Show completion message
show_completion() {
    echo -e "\n${BOLD}${GREEN}================================================================"
    echo "🎉 INSTALLATION COMPLETE!"
    echo "================================================================${NC}"
    echo -e "${CYAN}Usage Options:${NC}"
    echo -e "${GREEN}  1. System command: dual-compressor [options]${NC}"
    echo -e "${GREEN}  2. Direct script:  ./bin/dual_output_image_compressor.sh [options]${NC}"
    echo
    echo -e "${CYAN}Quick Start:${NC}"
    echo -e "${GREEN}  dual-compressor                    # Process current directory (1MB)${NC}"
    echo -e "${GREEN}  dual-compressor ~/Pictures         # Process ~/Pictures (1MB)${NC}"
    echo -e "${GREEN}  dual-compressor . ./output -k500   # Process to 500KB files${NC}"
    echo
    echo -e "${CYAN}Get Help:${NC}"
    echo -e "${GREEN}  dual-compressor -h${NC}"
    echo
    echo -e "${BOLD}${BLUE}================================================================${NC}"
}

# Main installation process
main() {
    show_banner
    check_macos
    check_homebrew
    install_dependencies
    setup_permissions
    create_symlink
    verify_installation
    show_completion
}

# Run installation
main "$@"