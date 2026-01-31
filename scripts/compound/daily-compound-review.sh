#!/bin/bash
# =============================================================================
# NIGHTLY AGENT LOOP - LEARNING (Compound Review)
# =============================================================================
# Extracts learnings from your daily work and updates the GEMINI.md memory file.
# Schedule: 10:30 PM daily via macOS LaunchAgent
#
# Usage:
#   ./daily-compound-review.sh              # Run learning loop
#   ./daily-compound-review.sh --dry-run    # Preview without making changes
# =============================================================================

set -euo pipefail

# ================================ CONFIG =====================================
# Customize these paths for your project
PROJECT_DIR="${PROJECT_DIR:-$(pwd)}"
GEMINI_CLI="${GEMINI_CLI:-/usr/local/Cellar/node/25.4.0/bin/gemini}"
MEMORY_FILE="${MEMORY_FILE:-$HOME/.gemini/GEMINI.md}"
LOG_FILE="${LOG_FILE:-$PROJECT_DIR/logs/compound-learning.log}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
    
    mkdir -p "$(dirname "$LOG_FILE")"
}

# ================================ MAIN =======================================
main() {
    local dry_run=false
    [[ "${1:-}" == "--dry-run" ]] && dry_run=true

    log "=========================================="
    log "LEARNING LOOP START"
    log "Project: $PROJECT_DIR"
    log "Memory File: $MEMORY_FILE"
    log "Dry Run: $dry_run"
    log "=========================================="

    check_dependencies
    cd "$PROJECT_DIR"

    # Gather today's work context
    local today=$(date '+%Y-%m-%d')
    local git_log=$(git log --since="$today 00:00" --until="$today 23:59" --oneline 2>/dev/null || echo "No commits today")
    local git_diff=$(git diff --stat HEAD~5 HEAD 2>/dev/null | tail -20 || echo "No recent changes")
    
    # Load prompt template
    local prompt_template="$SCRIPT_DIR/prompts/learning-prompt.md"
    if [[ ! -f "$prompt_template" ]]; then
        error "Prompt template not found: $prompt_template"
    fi

    # Build the full prompt
    local current_memory=""
    [[ -f "$MEMORY_FILE" ]] && current_memory=$(cat "$MEMORY_FILE")
    
    local prompt=$(cat "$prompt_template")
    prompt="${prompt//\{\{DATE\}\}/$today}"
    prompt="${prompt//\{\{GIT_LOG\}\}/$git_log}"
    prompt="${prompt//\{\{GIT_DIFF\}\}/$git_diff}"
    prompt="${prompt//\{\{CURRENT_MEMORY\}\}/$current_memory}"

    if $dry_run; then
        log "DRY RUN - Would send this prompt to Gemini:"
        echo "---"
        echo "$prompt"
        echo "---"
        log "DRY RUN - No changes made to $MEMORY_FILE"
    else
        log "Sending prompt to Gemini CLI..."
        
        local result
        # Temporary workaround for EPERM issues in ~/.gemini/tmp
        GEMINI_HOME="/tmp/gemini_fake_home_learning_$(date +%s)"
        mkdir -p "$GEMINI_HOME/.gemini"
        
        # Selective copy of config only
        cp "$HOME/.gemini"/*.json "$GEMINI_HOME/.gemini/" 2>/dev/null || true
        
        # Ensure cleanup on exit
        trap 'rm -rf "$GEMINI_HOME"' EXIT
        
        result=$(HOME="$GEMINI_HOME" "$GEMINI_CLI" --yolo -o text "$prompt" 2>&1) || {
            log "Gemini CLI output: $result"
            error "Gemini CLI failed"
        }
        
        # Extract the GEMINI.md content from response
        # The prompt asks Gemini to output the updated content between markers
        if echo "$result" | grep -q "<<<MEMORY_START>>>"; then
            local new_memory
            new_memory=$(echo "$result" | sed -n '/<<<MEMORY_START>>>/,/<<<MEMORY_END>>>/p' | sed '1d;$d')
            
            # Backup current memory
            [[ -f "$MEMORY_FILE" ]] && cp "$MEMORY_FILE" "$MEMORY_FILE.backup"
            
            # Write new memory
            echo "$new_memory" > "$MEMORY_FILE"
            log "Updated $MEMORY_FILE with new learnings"
        else
            log "No memory update markers found in response. Full response:"
            log "$result"
        fi
    fi

    log "LEARNING LOOP COMPLETE"
}

main "$@"
