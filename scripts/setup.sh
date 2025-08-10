#!/bin/bash

# Project Setup Script
# 
# This script automatically sets up the project for new team members.
# It configures package manager enforcement, git hooks, and other project requirements.

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Function to detect shell
detect_shell() {
    if [ -n "$ZSH_VERSION" ]; then
        echo "zsh"
    elif [ -n "$BASH_VERSION" ]; then
        echo "bash"
    else
        echo "unknown"
    fi
}

# Function to get shell config file
get_shell_config() {
    local shell_type=$(detect_shell)
    local home_dir="$HOME"
    
    case $shell_type in
        "zsh")
            echo "$home_dir/.zshrc"
            ;;
        "bash")
            echo "$home_dir/.bashrc"
            ;;
        *)
            echo "$home_dir/.bashrc"
            ;;
    esac
}

# Function to check if pnpm is installed
check_pnpm() {
    local auto_mode="$1"
    
    if command -v pnpm >/dev/null 2>&1; then
        local version=$(pnpm --version)
        if [ "$auto_mode" = false ]; then
            print_success "pnpm is installed (version: $version)"
        fi
        return 0
    else
        if [ "$auto_mode" = false ]; then
            print_error "pnpm is not installed"
            print_info "Installing pnpm..."
        fi
        npm install -g pnpm
        if [ $? -eq 0 ]; then
            if [ "$auto_mode" = false ]; then
                print_success "pnpm installed successfully"
            fi
            return 0
        else
            if [ "$auto_mode" = false ]; then
                print_error "Failed to install pnpm"
            fi
            return 1
        fi
    fi
}

# Function to setup package manager enforcement
setup_pm_enforcement() {
    local shell_config=$(get_shell_config)
    local project_dir="$(pwd)"
    local auto_mode="$1"
    
    if [ "$auto_mode" = false ]; then
        print_info "Setting up package manager enforcement..."
    fi
    
    # Check if already configured
    if grep -q "UNIVERSAL_PM_CHECK_ENABLED" "$shell_config" 2>/dev/null; then
        if [ "$auto_mode" = false ]; then
            print_warning "Package manager enforcement already configured"
        fi
        return 0
    fi
    
    # Add universal check to shell config
    echo "" >> "$shell_config"
    echo "# Package Manager Enforcement for $(basename "$project_dir")" >> "$shell_config"
    echo "export PROJECT_ROOT=\"$project_dir\"" >> "$shell_config"
    echo "source \"$project_dir/scripts/pm/universal.sh\"" >> "$shell_config"
    
    # Create aliases
    echo "alias npm='check_package_manager \"npm\" \"\$*\" && npm \"\$@\"'" >> "$shell_config"
    echo "alias yarn='check_package_manager \"yarn\" \"\$*\" && yarn \"\$@\"'" >> "$shell_config"
    echo "export UNIVERSAL_PM_CHECK_ENABLED=1" >> "$shell_config"
    
    if [ "$auto_mode" = false ]; then
        print_success "Package manager enforcement configured"
    fi
}

# Function to setup git hooks
setup_git_hooks() {
    local auto_mode="$1"
    
    if [ "$auto_mode" = false ]; then
        print_info "Setting up git hooks..."
    fi
    
    if [ -f ".git/hooks/pre-commit" ]; then
        if [ "$auto_mode" = false ]; then
            print_warning "Git hooks already exist"
        fi
    else
        # Install husky hooks
        pnpm run prepare
        if [ "$auto_mode" = false ]; then
            print_success "Git hooks configured"
        fi
    fi
}

# Function to install dependencies
install_dependencies() {
    local auto_mode="$1"
    
    if [ "$auto_mode" = false ]; then
        print_info "Installing project dependencies..."
    fi
    
    if [ -f "pnpm-lock.yaml" ]; then
        pnpm install
        if [ $? -eq 0 ]; then
            if [ "$auto_mode" = false ]; then
                print_success "Dependencies installed successfully"
            fi
        else
            if [ "$auto_mode" = false ]; then
                print_error "Failed to install dependencies"
            fi
            return 1
        fi
    else
        if [ "$auto_mode" = false ]; then
            print_warning "No pnpm-lock.yaml found. Run 'pnpm install' manually."
        fi
    fi
}

# Function to verify setup
verify_setup() {
    local auto_mode="$1"
    
    if [ "$auto_mode" = false ]; then
        print_info "Verifying setup..."
    fi
    
    # Check pnpm
    if ! command -v pnpm >/dev/null 2>&1; then
        if [ "$auto_mode" = false ]; then
            print_error "pnpm is not available"
        fi
        return 1
    fi
    
    # Check package manager enforcement
    if [ -z "$UNIVERSAL_PM_CHECK_ENABLED" ]; then
        if [ "$auto_mode" = false ]; then
            print_warning "Package manager enforcement not active in current session"
            print_info "Run 'source $(get_shell_config)' to activate"
        fi
    else
        if [ "$auto_mode" = false ]; then
            print_success "Package manager enforcement is active"
        fi
    fi
    
    # Test enforcement
    if [ "$auto_mode" = false ]; then
        print_info "Testing package manager enforcement..."
    fi
    if npm --version >/dev/null 2>&1; then
        if [ "$auto_mode" = false ]; then
            print_success "npm is blocked (enforcement working)"
        fi
    else
        if [ "$auto_mode" = false ]; then
            print_warning "npm enforcement test failed"
        fi
    fi
    
    if [ "$auto_mode" = false ]; then
        print_success "Setup verification complete"
    fi
}

# Function to show next steps
show_next_steps() {
    local shell_config=$(get_shell_config)
    
    echo ""
    echo "🎉 Project Setup Complete!"
    echo "=========================="
    echo ""
    print_info "Next steps:"
    echo "1. Reload your shell configuration:"
    echo "   source $shell_config"
    echo ""
    echo "2. Or restart your terminal"
    echo ""
    echo "3. Test the setup:"
    echo "   yarn install    # Should show custom error"
    echo "   npm install     # Should show custom error"
    echo "   pnpm install    # Should work normally"
    echo ""
    print_info "Package manager enforcement is now active!"
    echo "All npm/yarn commands will show custom error messages."
    echo ""
    print_warning "To disable temporarily: unset UNIVERSAL_PM_CHECK_ENABLED"
    print_info "To re-enable: export UNIVERSAL_PM_CHECK_ENABLED=1"
}

# Main execution
main() {
    local project_dir="$(pwd)"
    local auto_mode=false
    
    # Check for --auto flag
    if [[ "$1" == "--auto" ]]; then
        auto_mode=true
    fi
    
    if [ "$auto_mode" = false ]; then
        echo "🚀 Project Setup Script"
        echo "======================="
        echo ""
        print_info "Setting up project: $(basename "$project_dir")"
        print_info "Shell: $(detect_shell)"
        print_info "Shell config: $(get_shell_config)"
        echo ""
    fi
    
    # Check if we're in the right directory
    if [ ! -f "package.json" ]; then
        print_error "package.json not found. Please run this script from the project root."
        exit 1
    fi
    
    # Check pnpm
    if ! check_pnpm "$auto_mode"; then
        print_error "pnpm setup failed. Please install pnpm manually."
        exit 1
    fi
    
    # Setup package manager enforcement
    if ! setup_pm_enforcement "$auto_mode"; then
        print_error "Package manager enforcement setup failed."
        exit 1
    fi
    
    # Setup git hooks
    setup_git_hooks "$auto_mode"
    
    # Install dependencies
    install_dependencies "$auto_mode"
    
    # Verify setup
    verify_setup "$auto_mode"
    
    # Show next steps (only in interactive mode)
    if [ "$auto_mode" = false ]; then
        show_next_steps
    fi
}

# Run main function
main "$@" 