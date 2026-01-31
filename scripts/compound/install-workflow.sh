#!/bin/bash
# =============================================================================
# INSTALL COMPOUND WORKFLOW
# =============================================================================
# Installs the /compound workflow to a project so you can use it in any
# conversation in that workspace.
#
# Usage:
#   ./install-workflow.sh /path/to/project    # Install to a specific project
#   ./install-workflow.sh --all               # Install to all projects in ~/Developer
#   ./install-workflow.sh --list              # List projects that have the workflow
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_FILE="$SCRIPT_DIR/../../.agent/workflows/compound.md"

# Fallback if running from scripts/compound
if [[ ! -f "$WORKFLOW_FILE" ]]; then
    WORKFLOW_FILE="$(dirname "$SCRIPT_DIR")/../.agent/workflows/compound.md"
fi

# If still not found, use the one in prompts as source
if [[ ! -f "$WORKFLOW_FILE" ]]; then
    echo "❌ Could not find compound.md workflow file"
    exit 1
fi

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}✓${NC} $*"; }
info() { echo -e "${BLUE}ℹ${NC} $*"; }
warn() { echo -e "${YELLOW}!${NC} $*"; }

install_to_project() {
    local project="$1"
    local workflows_dir="$project/.agent/workflows"
    
    mkdir -p "$workflows_dir"
    cp "$WORKFLOW_FILE" "$workflows_dir/compound.md"
    log "Installed to: $project"
}

install_all() {
    local dev_dir="${HOME}/Developer"
    local count=0
    
    echo ""
    echo "Installing /compound to all projects in $dev_dir..."
    echo ""
    
    # Find all git repositories
    for dir in "$dev_dir"/*; do
        if [[ -d "$dir/.git" ]] || [[ -d "$dir" ]]; then
            install_to_project "$dir"
            ((count++))
        fi
    done
    
    echo ""
    log "Installed to $count projects!"
}

list_projects() {
    local dev_dir="${HOME}/Developer"
    
    echo ""
    echo "Projects with /compound workflow:"
    echo ""
    
    for dir in "$dev_dir"/*; do
        if [[ -f "$dir/.agent/workflows/compound.md" ]]; then
            echo -e "  ${GREEN}✓${NC} $(basename "$dir")"
        else
            echo -e "  ${YELLOW}✗${NC} $(basename "$dir")"
        fi
    done
    echo ""
}

show_help() {
    echo ""
    echo "Usage: $(basename "$0") [OPTION] [PROJECT_PATH]"
    echo ""
    echo "Options:"
    echo "  /path/to/project    Install workflow to a specific project"
    echo "  --all               Install to ALL projects in ~/Developer"
    echo "  --list              List which projects have the workflow"
    echo "  --help              Show this help message"
    echo ""
    echo "After installing, you can type /compound in any conversation"
    echo "while working in that project to extract learnings to GEMINI.md"
    echo ""
}

# Main
case "${1:-}" in
    --all)
        install_all
        ;;
    --list)
        list_projects
        ;;
    --help|-h)
        show_help
        ;;
    "")
        show_help
        ;;
    *)
        if [[ -d "$1" ]]; then
            install_to_project "$(cd "$1" && pwd)"
        else
            echo "❌ Directory not found: $1"
            exit 1
        fi
        ;;
esac
