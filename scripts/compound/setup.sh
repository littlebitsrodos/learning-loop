#!/bin/bash
# =============================================================================
# NIGHTLY AGENT LOOP - SETUP SCRIPT
# =============================================================================
# One-time setup to install LaunchAgents and configure the nightly loop.
#
# Usage:
#   ./setup.sh /path/to/your/project    # Install for a specific project
#   ./setup.sh --uninstall              # Remove all LaunchAgents
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() { echo -e "${GREEN}[✓]${NC} $*"; }
warn() { echo -e "${YELLOW}[!]${NC} $*"; }
error() { echo -e "${RED}[✗]${NC} $*" >&2; exit 1; }

uninstall() {
    echo "Uninstalling Nightly Agent Loop..."
    
    for label in com.compound.learning com.compound.shipping com.compound.caffeinate; do
        if launchctl list | grep -q "$label"; then
            launchctl unload "$LAUNCH_AGENTS_DIR/$label.plist" 2>/dev/null || true
            log "Unloaded $label"
        fi
        rm -f "$LAUNCH_AGENTS_DIR/$label.plist"
    done
    
    log "Uninstall complete!"
}

install() {
    local project_dir="$1"
    
    # Validate project directory
    if [[ ! -d "$project_dir" ]]; then
        error "Directory does not exist: $project_dir"
    fi
    
    project_dir="$(cd "$project_dir" && pwd)"  # Get absolute path
    
    if [[ ! -d "$project_dir/.git" ]]; then
        warn "Not a git repository. Initializing..."
        (cd "$project_dir" && git init)
    fi
    
    echo ""
    echo "=========================================="
    echo "  NIGHTLY AGENT LOOP SETUP"
    echo "=========================================="
    echo "Project: $project_dir"
    echo ""
    
    # Check for scripts
    if [[ ! -f "$project_dir/scripts/compound/daily-compound-review.sh" ]]; then
        warn "Scripts not found. Copying template..."
        mkdir -p "$project_dir/scripts/compound/prompts"
        mkdir -p "$project_dir/reports"
        mkdir -p "$project_dir/logs"
        
        cp -r "$SCRIPT_DIR/"*.sh "$project_dir/scripts/compound/" 2>/dev/null || true
        cp -r "$SCRIPT_DIR/prompts/"* "$project_dir/scripts/compound/prompts/" 2>/dev/null || true
        chmod +x "$project_dir/scripts/compound/"*.sh
        log "Copied scripts to $project_dir/scripts/compound/"
    fi
    
    # Create LaunchAgents directory if needed
    mkdir -p "$LAUNCH_AGENTS_DIR"
    
    # Install each plist
    for plist in com.compound.learning com.compound.shipping com.compound.caffeinate; do
        local src="$SCRIPT_DIR/launchagents/$plist.plist"
        local dest="$LAUNCH_AGENTS_DIR/$plist.plist"
        
        if [[ ! -f "$src" ]]; then
            warn "Plist not found: $src (skipping)"
            continue
        fi
        
        # Replace placeholder paths
        sed "s|/path/to/your/project|$project_dir|g" "$src" > "$dest"
        
        # Unload if already loaded
        launchctl unload "$dest" 2>/dev/null || true
        
        # Load the new version
        launchctl load "$dest"
        log "Installed $plist"
    done
    
    echo ""
    log "Setup complete!"
    echo ""
    echo "=========================================="
    echo "  SCHEDULE"
    echo "=========================================="
    echo "  • 5:00 PM  - Mac stays awake (caffeinate)"
    echo "  • 10:30 PM - Learning Loop (updates GEMINI.md)"
    echo "  • 11:00 PM - Shipping Loop (implements #1 priority)"
    echo ""
    echo "=========================================="
    echo "  NEXT STEPS"
    echo "=========================================="
    echo "  1. Test manually:"
    echo "     cd $project_dir"
    echo "     ./scripts/compound/daily-compound-review.sh --dry-run"
    echo "     ./scripts/compound/auto-compound.sh --dry-run"
    echo ""
    echo "  2. Create a report in reports/ to give the agent priorities"
    echo ""
    echo "  3. Check logs:"
    echo "     tail -f $project_dir/logs/compound-*.log"
    echo "     tail -f /tmp/compound-*.log"
    echo ""
    echo "  4. To uninstall: $0 --uninstall"
    echo "=========================================="
}

# Main
case "${1:-}" in
    --uninstall)
        uninstall
        ;;
    --help|-h)
        echo "Usage: $0 /path/to/project    Install for a project"
        echo "       $0 --uninstall          Remove LaunchAgents"
        ;;
    "")
        error "Please specify a project directory: $0 /path/to/project"
        ;;
    *)
        install "$1"
        ;;
esac
