#!/bin/bash
# Simple Fastfetch Presets - configures a fastfetch preset wih a simple click (doesn't install fastfetch itself).
# Presets built for Linux Mint + default Mint terminal (GNOME Terminal), default font (Ubuntu Regular). Should work with all terminal emulators and fonts woth no issue.

set -euo pipefail

# --- COLOR AND STYLE DEFINITIONS ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

print_section() { echo -e "\n${CYAN}${BOLD}>${NC} ${BOLD}$1${NC}"; }
print_success() { echo -e "${GREEN}[OK] $1${NC}"; }
print_info()    { echo -e "${BLUE}[i]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
print_error()   { echo -e "${RED}[x] $1${NC}" >&2; }
print_step()    { echo -e "${MAGENTA}-> $1${NC}"; }

command_exists() { command -v "$1" >/dev/null 2>&1; }

prompt() {
    local msg="$1"
    local default="${2:-N}"

    if [[ "${NON_INTERACTIVE:-false}" = true ]]; then
        [[ "$default" =~ ^[Yy]$ ]] && return 0 || return 1
    fi

    local options="[y/N]"
    [[ "$default" =~ ^[Yy]$ ]] && options="[Y/n]"

    echo -en "${YELLOW}?${NC} $msg $options: "
    read -r response
    response="${response:-$default}"
    [[ "$response" =~ ^[Yy]$ ]]
}

# --- WELCOME SCREEN ---
show_welcome() {
    clear
    echo -e "${CYAN}${BOLD}"
    cat << "EOF"
   __            __  ____     __         __
  / _/__ ____ __/ /_/ __/__ _/ /_ ______/ /
 / _/ _ `(_-</ __/ _// -_)  /_ __/ __/ _  \/
/_/ \_,_/___/\__/_/  \__/_/ /_/ /____/_//_/
EOF
    echo -e "${NC}"
    echo -e "${CYAN}${BOLD}Simple Fastfetch Presets - configures a fastfetch preset wih a simple click${NC}"
    echo -e "${DIM}------------------------------------------------------------${NC}"

    print_section "Check Requirements"

    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        DISTRO_NAME="${PRETTY_NAME:-$NAME}"
        DISTRO_NAME="${DISTRO_NAME:-Unknown}"
    else
        DISTRO_NAME="Unknown"
    fi
    local shell_name
    shell_name=$(basename "$SHELL")
    print_info "System: ${BOLD}${DISTRO_NAME}${NC} | Shell: ${BOLD}${shell_name}${NC}"

    if ! command_exists fastfetch; then
        print_error "fastfetch is not installed"
        echo ""
        if prompt "Install it now via apt?" "Y"; then
            sudo apt update && sudo apt install -y fastfetch
        else
            print_warning "This script only configures presets, it needs fastfetch installed first."
            exit 1
        fi
    fi

    local version
    version=$(fastfetch --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)
    print_success "fastfetch is installed (v${version:-unknown})"

    echo ""
    print_warning "This script will:"
    echo "  - Apply your chosen fastfetch preset"
    echo "  - Optionally add fastfetch to your shell startup"
    echo ""
}

# --- CONFIGURATION FUNCTIONS ---
select_preset() {
    print_section "Select Preset"

    local presets=("minimal" "compact" "compact-ip" "full")
    local descriptions=(
        "Minimal:      no logo, just the essentials"
        "Compact:      distro ASCII logo + balanced info"
        "Compact + IP: distro ASCII logo + balanced info + local IP included"
        "Full:         everything - hardware, network, packages, colors, logo"
    )

    echo -e "${CYAN}Available presets:${NC}"
    for i in "${!presets[@]}"; do
        echo -e "  ${GREEN}$((i+1)))${NC} ${descriptions[$i]}"
    done

    if [[ -n "${CONFIG_TYPE:-}" ]]; then
        for p in "${presets[@]}"; do
            if [[ "$p" == "$CONFIG_TYPE" ]]; then
                SELECTED_PRESET="$CONFIG_TYPE"
                print_info "Using preset: $SELECTED_PRESET (from command line)"
                return 0
            fi
        done
        print_error "Unknown preset from --config: $CONFIG_TYPE"
        exit 1
    fi

    if [[ "$NON_INTERACTIVE" = true ]]; then
        SELECTED_PRESET="minimal"
        print_info "Auto-selected: minimal (non-interactive mode)"
        return 0
    fi

    local choice=""
    while [[ ! "$choice" =~ ^[1-4]$ ]]; do
        echo -en "${YELLOW}Select preset (1-4): ${NC}"
        read -r choice
        case "$choice" in
            1) SELECTED_PRESET="minimal" ;;
            2) SELECTED_PRESET="compact" ;;
            3) SELECTED_PRESET="compact-ip" ;;
            4) SELECTED_PRESET="full" ;;
            *) print_error "Invalid selection. Please enter 1-4." ;;
        esac
    done
}

apply_preset() {
    print_step "Applying '$SELECTED_PRESET' preset..."

    local config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/fastfetch"
    local config_file="$config_dir/config.jsonc"

    if [[ -f "$config_file" ]]; then
        local backup_file="$config_file.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$config_file" "$backup_file"
        print_info "Backed up existing config to: $(basename "$backup_file")"
    fi

    mkdir -p "$config_dir"

    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local preset_file="$script_dir/presets/${SELECTED_PRESET}.jsonc"

    if [[ -f "$preset_file" ]]; then
        cp "$preset_file" "$config_file"
        print_success "Applied preset: $SELECTED_PRESET"
    else
        print_error "Preset file not found: $preset_file"
        exit 1
    fi
}

# --- SHELL INTEGRATION ---
setup_shell_integration() {
    if [[ "$SKIP_SHELL" = true ]]; then
        print_info "Skipping shell integration (--skip-shell)"
        return
    fi

    print_section "Shell Integration"

    local current_shell
    current_shell=$(basename "$SHELL")
    local config_file=""

    case "$current_shell" in
        bash) config_file="$HOME/.bashrc" ;;
        zsh)  config_file="$HOME/.zshrc" ;;
        fish) config_file="$HOME/.config/fish/config.fish" ;;
        *)
            print_warning "Unsupported shell: $current_shell"
            print_info "Manually add 'fastfetch' to your shell's config file"
            return
            ;;
    esac

    if [[ ! -f "$config_file" ]]; then
        print_warning "Config file not found: $config_file"
        return
    fi

    if grep -q "fastfetch" "$config_file" 2>/dev/null; then
        print_info "fastfetch already in $current_shell config"
        return
    fi

    if prompt "Add fastfetch to $current_shell startup?" "Y"; then
        {
            echo ""
            echo "# Fastfetch - System Information Display"
            echo "if command -v fastfetch &> /dev/null; then"
            echo "    fastfetch"
            echo "fi"
        } >> "$config_file"

        print_success "Added to $current_shell"
        print_info "Restart terminal or run: source $config_file"
    else
        print_info "Skipped shell integration"
    fi
}

# --- MAIN EXECUTION ---
main() {
    local CONFIG_TYPE=""
    local NON_INTERACTIVE=false
    local SKIP_SHELL=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            -c|--config)
                if [[ -n "${2:-}" && ! "$2" =~ ^- ]]; then
                    CONFIG_TYPE="$2"
                    shift 2
                else
                    print_error "Error: -c/--config requires a value"
                    exit 1
                fi
                ;;
            -n|--non-interactive)
                NON_INTERACTIVE=true
                shift
                ;;
            --skip-shell)
                SKIP_SHELL=true
                shift
                ;;
            -h|--help)
                echo "Usage: $0 [OPTIONS]"
                echo "Options:"
                echo "  -c, --config TYPE     minimal | compact | compact-ip | full"
                echo "  -n, --non-interactive Run without prompts (defaults to minimal)"
                echo "  --skip-shell          Skip shell startup integration"
                echo "  -h, --help            Show this help"
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                print_info "Use -h for help"
                exit 1
                ;;
        esac
    done

    show_welcome

    if [[ "$NON_INTERACTIVE" = false ]]; then
        if ! prompt "Configure fastfetch presets?" "Y"; then
            print_error "Setup cancelled by user"
            exit 0
        fi
    fi

    select_preset
    apply_preset
    setup_shell_integration

    print_success "Fastfetch preset has been successfully configured!"
    echo ""
}

main "$@"
