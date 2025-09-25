#!/bin/bash

# Dual-Output Image Compressor Uninstallation Script
# Removes the tool and cleans up system modifications

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Uninstallation banner
show_banner() {
    echo -e "${BOLD}${RED}================================================================"
    echo "🗑️  DUAL-OUTPUT IMAGE COMPRESSOR UNINSTALLER"
    echo "================================================================${NC}"
}

# Confirm uninstallation
confirm_uninstall() {
    echo -e "${YELLOW}⚠️  This will remove the Dual-Output Image Compressor and clean up system modifications.${NC}"
    echo -e "${CYAN}The following items will be removed:${NC}"
    echo "   • System-wide symlink (/usr/local/bin/dual-compressor)"
    echo "   • Homebrew packages (ImageMagick, bc) - OPTIONAL"
    echo "   • Project files in current directory - OPTIONAL"
    echo
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}Uninstallation cancelled.${NC}"
        exit 0
    fi
}

# Remove system symlink
remove_symlink() {
    echo -e "${CYAN}🔗 Removing system-wide symlink...${NC}"

    local symlink_path="/usr/local/bin/dual-compressor"

    if [[ -L "$symlink_path" ]]; then
        if sudo rm "$symlink_path" 2>/dev/null; then
            echo -e "${GREEN}✓ Symlink removed: $symlink_path${NC}"
        else
            echo -e "${YELLOW}⚠️  Could not remove symlink: $symlink_path${NC}"
            echo -e "${YELLOW}   You may need to remove it manually${NC}"
        fi
    else
        echo -e "${BLUE}ℹ️  No symlink found at $symlink_path${NC}"
    fi
}

# Optional: Remove Homebrew packages
remove_homebrew_packages() {
    echo -e "${CYAN}📦 Homebrew packages removal...${NC}"
    echo -e "${YELLOW}⚠️  ImageMagick and bc may be used by other applications.${NC}"
    read -p "Remove ImageMagick and bc via Homebrew? (y/N): " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${CYAN}🗑️  Removing Homebrew packages...${NC}"

        if command -v brew &> /dev/null; then
            # Remove ImageMagick
            if brew list imagemagick &>/dev/null; then
                brew uninstall imagemagick && echo -e "${GREEN}✓ ImageMagick removed${NC}" || \
                    echo -e "${YELLOW}⚠️  Could not remove ImageMagick${NC}"
            else
                echo -e "${BLUE}ℹ️  ImageMagick not installed via Homebrew${NC}"
            fi

            # Remove bc
            if brew list bc &>/dev/null; then
                brew uninstall bc && echo -e "${GREEN}✓ bc removed${NC}" || \
                    echo -e "${YELLOW}⚠️  Could not remove bc${NC}"
            else
                echo -e "${BLUE}ℹ️  bc not installed via Homebrew${NC}"
            fi

            # Cleanup Homebrew
            echo -e "${CYAN}🧹 Cleaning up Homebrew...${NC}"
            brew cleanup &>/dev/null || true
            echo -e "${GREEN}✓ Homebrew cleanup completed${NC}"
        else
            echo -e "${BLUE}ℹ️  Homebrew not found${NC}"
        fi
    else
        echo -e "${BLUE}ℹ️  Homebrew packages preserved${NC}"
    fi
}

# Optional: Remove project files
remove_project_files() {
    echo -e "${CYAN}📁 Project files removal...${NC}"
    echo -e "${YELLOW}⚠️  This will delete all project files in the current directory.${NC}"
    echo -e "${CYAN}Current directory: $(pwd)${NC}"
    read -p "Remove all project files from current directory? (y/N): " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${CYAN}🗑️  Removing project files...${NC}"

        # List of files and directories to remove
        local items=(
            "bin/"
            "docs/"
            "examples/"
            "scripts/"
            "tests/"
            ".github/"
            "README.md"
            "LICENSE"
            "CHANGELOG.md"
            "CONTRIBUTING.md"
            ".gitignore"
            "config.local.sh"
        )

        local removed_count=0
        for item in "${items[@]}"; do
            if [[ -e "$item" ]]; then
                rm -rf "$item" && ((removed_count++))
            fi
        done

        echo -e "${GREEN}✓ Removed $removed_count project items${NC}"

        # Remove any output directories that might exist
        find . -maxdepth 1 -name "*compressed*" -type d -exec rm -rf {} \; 2>/dev/null || true
        find . -maxdepth 1 -name "*output*" -type d -exec rm -rf {} \; 2>/dev/null || true

        echo -e "${GREEN}✓ Cleaned up output directories${NC}"
    else
        echo -e "${BLUE}ℹ️  Project files preserved${NC}"
    fi
}

# Clean up any remaining temporary files
cleanup_temp_files() {
    echo -e "${CYAN}🧹 Cleaning up temporary files...${NC}"

    # Remove any temporary files that might have been left behind
    local temp_patterns=(
        "/tmp/dual_image_worker_*"
        "/tmp/jpeg_dual_*"
        "/tmp/png_dual_*"
        "/tmp/*result*$$*"
        "/tmp/dual_input_files_*"
    )

    local cleaned_count=0
    for pattern in "${temp_patterns[@]}"; do
        if compgen -G "$pattern" > /dev/null 2>&1; then
            rm -rf $pattern 2>/dev/null && ((cleaned_count++)) || true
        fi
    done

    if [[ $cleaned_count -gt 0 ]]; then
        echo -e "${GREEN}✓ Cleaned up $cleaned_count temporary file groups${NC}"
    else
        echo -e "${BLUE}ℹ️  No temporary files found${NC}"
    fi
}

# Verification
verify_uninstallation() {
    echo -e "${CYAN}🔍 Verifying uninstallation...${NC}"

    local issues=0

    # Check symlink
    if [[ -L "/usr/local/bin/dual-compressor" ]]; then
        echo -e "${YELLOW}⚠️  Symlink still exists: /usr/local/bin/dual-compressor${NC}"
        ((issues++))
    fi

    # Check for running processes
    if pgrep -f "dual_output_image_compressor" >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Compressor processes still running${NC}"
        ((issues++))
    fi

    if [[ $issues -eq 0 ]]; then
        echo -e "${GREEN}✓ Uninstallation verified successfully${NC}"
    else
        echo -e "${YELLOW}⚠️  $issues issues found - manual cleanup may be required${NC}"
    fi
}

# Show completion message
show_completion() {
    echo -e "\n${BOLD}${GREEN}================================================================"
    echo "🎉 UNINSTALLATION COMPLETE!"
    echo "================================================================${NC}"

    echo -e "${CYAN}Summary:${NC}"
    echo -e "${GREEN}  ✓ System symlink removed${NC}"
    echo -e "${GREEN}  ✓ Temporary files cleaned${NC}"

    if command -v magick &> /dev/null; then
        echo -e "${BLUE}  ℹ️  ImageMagick still available system-wide${NC}"
    fi

    if command -v bc &> /dev/null; then
        echo -e "${BLUE}  ℹ️  bc calculator still available system-wide${NC}"
    fi

    echo
    echo -e "${CYAN}Thank you for using Dual-Output Image Compressor!${NC}"
    echo -e "${BLUE}================================================================${NC}"
}

# Main uninstallation process
main() {
    show_banner
    confirm_uninstall
    remove_symlink
    remove_homebrew_packages
    remove_project_files
    cleanup_temp_files
    verify_uninstallation
    show_completion
}

# Handle help argument
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    echo "Dual-Output Image Compressor Uninstaller"
    echo
    echo "Usage: $0"
    echo
    echo "This script will interactively remove the Dual-Output Image Compressor"
    echo "and clean up system modifications."
    echo
    echo "Items that can be removed:"
    echo "  • System-wide symlink (/usr/local/bin/dual-compressor)"
    echo "  • Homebrew packages (ImageMagick, bc) - optional"
    echo "  • Project files in current directory - optional"
    echo "  • Temporary processing files"
    echo
    echo "The script will ask for confirmation before removing each item."
    exit 0
fi

# Run uninstallation
main "$@"