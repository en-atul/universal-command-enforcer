#!/bin/bash

# Universal Package Manager Checker
#
# This script checks if the correct package manager is being used for ANY command.
# It can be sourced or called to enforce pnpm usage across the entire project.

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REQUIRED_PM="pnpm"
ALLOWED_COMMANDS=("pnpm" "node" "git" "ls" "cat" "echo" "cd" "pwd" "find" "grep" "chmod" "mkdir" "rm" "cp" "mv" "touch" "which" "whereis" "type" "command" "hash" "alias" "unalias" "export" "unset" "source" ".")

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

# Function to detect package manager from command
detect_package_manager() {
    local command="$1"

    # Check for package manager commands
    case "$command" in
        "npm"|"npm.cmd")
            echo "npm"
            return 0
            ;;
        "yarn"|"yarn.cmd")
            echo "yarn"
            return 0
            ;;
        "pnpm"|"pnpm.cmd")
            echo "pnpm"
            return 0
            ;;
        *)
            echo "unknown"
            return 1
            ;;
    esac
}

# Function to check if command is allowed without package manager check
is_allowed_command() {
    local command="$1"

    for allowed in "${ALLOWED_COMMANDS[@]}"; do
        if [[ "$command" == "$allowed" ]]; then
            return 0  # allowed
        fi
    done

    return 1  # not allowed
}

# Function to show custom error message
show_custom_error() {
    local detected_pm="$1"
    local command="$2"
    local content_width=63  # width between the box borders

    # Function to get display width (emoji safe)
    str_width() {
        local text="$1"
        local width=0
        local i=0
        local len=${#text}
        
        while [ $i -lt $len ]; do
            local char="${text:$i:1}"
            case "$char" in
                # Emojis and wide characters (2 display units)
                🔍|📦|🚫|💡|🔗|❌|✅|⚠️|ℹ️|🎉|🚀|🔄)
                    width=$((width + 2))
                    ;;
                # Regular characters (1 display unit)
                *)
                    width=$((width + 1))
                    ;;
            esac
            i=$((i + 1))
        done
        echo $width
    }

    # Helper to print a padded line
    print_line() {
        local text="$1"
        local width
        width=$(str_width "$text")
        local padding=$((content_width - width))
        printf "║ %s%*s ║\n" "$text" "$padding" ""
    }

    printf "\n"
    printf "╔═════════════════════════════════════════════════════════════════╗\n"
    print_line ""
    print_line "❌  Package Manager Error"
    print_line ""
    print_line "🔍  Detected: \"$detected_pm\" (via universal checker)"
    print_line "📦  Required: \"$REQUIRED_PM\""
    print_line "🚫  Command: $command"
    print_line ""
    print_line "💡  Solutions:"
    print_line "   1. Install pnpm: npm install -g pnpm"
    print_line "   2. Use pnpm commands: pnpm install, pnpm run build, etc."
    print_line "   3. Run: pnpm run check-pm (to verify)"
    print_line ""
    print_line "🔗  Learn more: https://pnpm.io/installation"
    print_line ""
    printf "╚═════════════════════════════════════════════════════════════════╝\n"
    printf "\n"
}

# Function to check package manager for a command
check_package_manager() {
    local command="$1"
    local args="$2"

    # Skip check for allowed commands
    if is_allowed_command "$command"; then
        return 0
    fi

    # Detect package manager
    local detected_pm=$(detect_package_manager "$command")

    if [[ "$detected_pm" != "unknown" ]]; then
        if [[ "$detected_pm" != "$REQUIRED_PM" ]]; then
            print_error "Package manager \"$detected_pm\" is not allowed in this project!"
            echo ""
            print_info "Instead of: $command $args"
            echo "   Use: $REQUIRED_PM $args"
            echo "   Or: pnpm $args"
            echo ""
            show_custom_error "$detected_pm" "$command $args"
            return 1
        else
            print_success "Package manager check: $detected_pm ✅"
            return 0
        fi
    fi

    # If not a package manager command, allow it
    return 0
}

# Function to intercept and check commands
intercept_command() {
    local original_command="$1"
    shift
    local args="$*"

    # Check package manager
    if ! check_package_manager "$original_command" "$args"; then
        exit 1
    fi

    # If check passes, execute the original command
    exec "$original_command" "$@"
}

# Main execution
main() {
    if [[ $# -eq 0 ]]; then
        echo "🔍 Universal Package Manager Checker"
        echo "===================================="
        echo ""
        print_info "This script checks if the correct package manager is being used."
        echo ""
        print_info "Usage:"
        echo "  $0 <command> [args...]"
        echo ""
        print_info "Examples:"
        echo "  $0 npm install"
        echo "  $0 yarn add react"
        echo "  $0 pnpm install"
        echo ""
        print_info "The script will:"
        echo "  ✅ Allow pnpm commands"
        echo "  ❌ Block npm and yarn commands"
        echo "  ✅ Allow system commands (ls, git, etc.)"
        exit 0
    fi

    local command="$1"
    shift
    local args="$*"

    intercept_command "$command" "$args"
}

# Only run main if called directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi