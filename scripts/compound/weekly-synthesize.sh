#!/bin/bash
# =============================================================================
# WEEKLY COMPOUND LOOP - PRUNE & SYNTHESIZE
# =============================================================================
# Cleans up and synthesizes GEMINI.md to keep it focused and actionable.
# Schedule: Sunday 10:00 PM via macOS LaunchAgent
#
# Usage:
#   ./weekly-synthesize.sh              # Run cleanup
#   ./weekly-synthesize.sh --dry-run    # Preview without changes
# =============================================================================

set -euo pipefail

# ================================ CONFIG =====================================
GEMINI_CLI="${GEMINI_CLI:-/usr/local/Cellar/node/25.4.0/bin/gemini}"
MEMORY_FILE="${MEMORY_FILE:-$HOME/.gemini/GEMINI.md}"
ARCHIVE_DIR="${ARCHIVE_DIR:-$HOME/.gemini/archive}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${LOG_FILE:-$SCRIPT_DIR/../../logs/compound-synthesize.log}"

# Thresholds
MAX_LINES="${MAX_LINES:-200}"

# ================================ HELPERS ====================================
log() {
    mkdir -p "$(dirname "$LOG_FILE")"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

error() {
    log "ERROR: $*" >&2
    exit 1
}

# ================================ MAIN =======================================
main() {
    local dry_run=false
    [[ "${1:-}" == "--dry-run" ]] && dry_run=true

    log "=========================================="
    log "WEEKLY SYNTHESIZE START"
    log "Memory File: $MEMORY_FILE"
    log "Archive Dir: $ARCHIVE_DIR"
    log "Dry Run: $dry_run"
    log "=========================================="

    # Check dependencies
    if [[ ! -x "$GEMINI_CLI" ]]; then
        error "Gemini CLI not found at $GEMINI_CLI"
    fi

    if [[ ! -f "$MEMORY_FILE" ]]; then
        log "No memory file found. Nothing to synthesize."
        exit 0
    fi

    # Count current lines
    local current_lines=$(wc -l < "$MEMORY_FILE")
    log "Current GEMINI.md: $current_lines lines"

    # Archive current version
    mkdir -p "$ARCHIVE_DIR"
    local archive_file="$ARCHIVE_DIR/GEMINI_$(date +%Y-%m-%d_%H%M%S).md"
    
    if $dry_run; then
        log "DRY RUN - Would archive to: $archive_file"
    else
        cp "$MEMORY_FILE" "$archive_file"
        log "Archived to: $archive_file"
    fi

    # Load prompt template
    local prompt_template="$SCRIPT_DIR/prompts/synthesize-prompt.md"
    if [[ ! -f "$prompt_template" ]]; then
        error "Prompt template not found: $prompt_template"
    fi

    # Build the full prompt
    local current_memory=$(cat "$MEMORY_FILE")
    local prompt=$(cat "$prompt_template")
    prompt="${prompt//\{\{CURRENT_MEMORY\}\}/$current_memory}"
    prompt="${prompt//\{\{MAX_LINES\}\}/$MAX_LINES}"
    prompt="${prompt//\{\{CURRENT_LINES\}\}/$current_lines}"

    if $dry_run; then
        log "DRY RUN - Would send synthesize prompt to Gemini"
        log "DRY RUN - No changes made to $MEMORY_FILE"
    else
        log "Sending synthesize prompt to Gemini CLI..."
        
        local result
        result=$("$GEMINI_CLI" --yolo -o text "$prompt" 2>&1) || {
            log "Gemini CLI output: $result"
            error "Gemini CLI failed"
        }
        
        # Extract synthesized content
        if echo "$result" | grep -q "<<<MEMORY_START>>>"; then
            local new_memory
            new_memory=$(echo "$result" | sed -n '/<<<MEMORY_START>>>/,/<<<MEMORY_END>>>/p' | sed '1d;$d')
            
            # Write synthesized memory
            echo "$new_memory" > "$MEMORY_FILE"
            
            local new_lines=$(wc -l < "$MEMORY_FILE")
            log "Synthesized: $current_lines → $new_lines lines"
            log "Reduction: $((current_lines - new_lines)) lines removed"
        else
            log "No synthesis markers found in response."
            log "Response: $result"
        fi
    fi

    # Cleanup old archives (keep last 10)
    if [[ -d "$ARCHIVE_DIR" ]]; then
        local archive_count=$(ls -1 "$ARCHIVE_DIR" 2>/dev/null | wc -l)
        if [[ $archive_count -gt 10 ]]; then
            log "Cleaning up old archives (keeping last 10)..."
            ls -1t "$ARCHIVE_DIR" | tail -n +11 | xargs -I {} rm "$ARCHIVE_DIR/{}"
        fi
    fi

    log "WEEKLY SYNTHESIZE COMPLETE"
}

main "$@"
