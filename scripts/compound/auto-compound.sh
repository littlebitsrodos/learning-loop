#!/bin/bash
# =============================================================================
# NIGHTLY AGENT LOOP - SHIPPING (Auto Compound)
# =============================================================================
# Analyzes reports, identifies the #1 priority, and implements it autonomously.
# Schedule: 11:00 PM daily via macOS LaunchAgent
#
# Usage:
#   ./auto-compound.sh              # Run shipping loop
#   ./auto-compound.sh --dry-run    # Preview without making changes
# =============================================================================

set -euo pipefail

# ================================ CONFIG =====================================
# Customize these paths for your project
PROJECT_DIR="${PROJECT_DIR:-$(pwd)}"
GEMINI_CLI="${GEMINI_CLI:-/usr/local/Cellar/node/25.4.0/bin/gemini}"
MEMORY_FILE="${MEMORY_FILE:-$HOME/.gemini/GEMINI.md}"
LOG_FILE="${LOG_FILE:-$PROJECT_DIR/logs/compound-shipping.log}"
REPORTS_DIR="${REPORTS_DIR:-$PROJECT_DIR/reports}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Loop configuration
MAX_ITERATIONS="${MAX_ITERATIONS:-10}"
BRANCH_PREFIX="${BRANCH_PREFIX:-compound}"

# ================================ HELPERS ====================================
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

error() {
    log "ERROR: $*" >&2
    exit 1
}

# ================================ CHECKS =====================================
check_dependencies() {
    if [[ ! -x "$GEMINI_CLI" ]]; then
        error "Gemini CLI not found at $GEMINI_CLI. Set GEMINI_CLI env var."
    fi
    
    if [[ ! -d "$PROJECT_DIR/.git" ]]; then
        error "Not a git repository: $PROJECT_DIR"
    fi
    
    if ! command -v jq &> /dev/null; then
        error "jq is required but not installed. Run: brew install jq"
    fi
    
    mkdir -p "$(dirname "$LOG_FILE")"
}

# ================================ ANALYSIS ===================================
analyze_reports() {
    log "Analyzing reports in $REPORTS_DIR..."
    
    local reports=""
    if [[ -d "$REPORTS_DIR" ]]; then
        # Get the 3 most recent reports
        reports=$(find "$REPORTS_DIR" -name "*.md" -type f -mtime -7 | sort -r | head -3 | while read f; do
            echo "=== $(basename "$f") ==="
            cat "$f"
            echo ""
        done)
    fi
    
    if [[ -z "$reports" ]]; then
        log "No recent reports found. Creating sample report..."
        reports="No reports available. The agent should identify priorities from the codebase itself."
    fi
    
    echo "$reports"
}

# ================================ SHIPPING ===================================
run_shipping_loop() {
    local dry_run=$1
    local reports=$2
    local today=$(date '+%Y-%m-%d')
    
    # Load prompt template
    local prompt_template="$SCRIPT_DIR/prompts/shipping-prompt.md"
    if [[ ! -f "$prompt_template" ]]; then
        error "Prompt template not found: $prompt_template"
    fi

    # Load memory file
    local memory=""
    [[ -f "$MEMORY_FILE" ]] && memory=$(cat "$MEMORY_FILE")
    
    # Get current branch and status
    local current_branch=$(git branch --show-current)
    local git_status=$(git status --short)
    
    # Build the full prompt
    local prompt=$(cat "$prompt_template")
    prompt="${prompt//\{\{DATE\}\}/$today}"
    prompt="${prompt//\{\{REPORTS\}\}/$reports}"
    prompt="${prompt//\{\{MEMORY\}\}/$memory}"
    prompt="${prompt//\{\{CURRENT_BRANCH\}\}/$current_branch}"
    prompt="${prompt//\{\{GIT_STATUS\}\}/$git_status}"
    prompt="${prompt//\{\{MAX_ITERATIONS\}\}/$MAX_ITERATIONS}"
    prompt="${prompt//\{\{BRANCH_PREFIX\}\}/$BRANCH_PREFIX}"

    if $dry_run; then
        log "DRY RUN - Would send this prompt to Gemini:"
        echo "---"
        echo "$prompt" | head -100
        echo "... [truncated for dry-run]"
        echo "---"
        log "DRY RUN - No branches created, no PRs opened"
        return 0
    fi

    log "Starting shipping loop with Gemini CLI..."
    log "Max iterations: $MAX_ITERATIONS"
    
    # Pull latest changes
    log "Pulling latest changes..."
    git pull --rebase origin "$(git branch --show-current)" 2>/dev/null || log "Pull skipped (not tracking remote)"
    
    # Run Gemini in YOLO mode - it will handle branch creation, coding, and PR
    local result
    result=$("$GEMINI_CLI" --yolo -o text "$prompt" 2>&1) || {
        log "Gemini CLI output: $result"
        error "Gemini CLI failed"
    }
    
    log "Gemini CLI response (last 50 lines):"
    echo "$result" | tail -50
    
    # Check for completion markers
    if echo "$result" | grep -qi "pull request\|PR created\|opened pr"; then
        log "SUCCESS: PR appears to have been created!"
    elif echo "$result" | grep -qi "no priority\|nothing to do\|all done"; then
        log "No actionable priority identified. Skipping."
    else
        log "Shipping loop completed. Check output above for results."
    fi
}

# ================================ MAIN =======================================
main() {
    local dry_run=false
    [[ "${1:-}" == "--dry-run" ]] && dry_run=true

    log "=========================================="
    log "SHIPPING LOOP START"
    log "Project: $PROJECT_DIR"
    log "Reports: $REPORTS_DIR"
    log "Dry Run: $dry_run"
    log "=========================================="

    check_dependencies
    cd "$PROJECT_DIR"

    # Ensure we're on a clean working tree
    if [[ -n "$(git status --porcelain)" ]]; then
        log "WARNING: Working tree not clean. Stashing changes..."
        git stash push -m "auto-compound-stash-$(date +%s)" || true
    fi

    local reports
    reports=$(analyze_reports)
    
    run_shipping_loop "$dry_run" "$reports"

    log "SHIPPING LOOP COMPLETE"
}

main "$@"
