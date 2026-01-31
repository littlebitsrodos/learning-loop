#!/bin/bash
# =============================================================================
# CLEAN MEMORY - Prune Old Artifacts
# =============================================================================
# Reclaims disk space by removing old browser recordings and temp files.
#
# Usage:
#   ./clean-memory.sh [--force] [--days N]
#
# Options:
#   --force     Actually delete files (default is dry-run)
#   --days N    Delete files older than N days (default: 14)
# =============================================================================

set -e

# Config
TARGET_DIR="$HOME/.gemini/antigravity"
DAYS_DEFAULT=14

# Parse args
FORCE=false
DAYS=$DAYS_DEFAULT

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --force) FORCE=true ;;
        --days) DAYS="$2"; shift ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

# Check target
if [[ ! -d "$TARGET_DIR" ]]; then
    log "Target directory not found: $TARGET_DIR"
    exit 0
fi

log "=========================================="
log "CLEANUP MEMORY START"
log "Target: $TARGET_DIR"
log "Policy: Older than $DAYS days"
log "Mode: $( $FORCE && echo "DELETE (Force)" || echo "DRY RUN" )"
log "=========================================="

# Find candidates
CANDIDATES=$(find "$TARGET_DIR" -name "*.webp" -type f -mtime +$DAYS)
COUNT=$(echo "$CANDIDATES" | grep -v "^$" | wc -l | tr -d ' ')

if [[ "$COUNT" -eq 0 ]]; then
    log "No files found strictly older than $DAYS days."
else
    # Calculate size (macOS compatible du)
    SIZE=$(echo "$CANDIDATES" | tr '\n' '\0' | xargs -0 du -ch | tail -1 | awk '{print $1}')
    
    log "Found $COUNT files (Total size: ~$SIZE)"
    
    if $FORCE; then
        log "Deleting $COUNT files..."
        echo "$CANDIDATES" | tr '\n' '\0' | xargs -0 rm -f
        log "✅ Reclaimed ~$SIZE of disk space."
    else
        log "📝 Candidates for deletion:"
        echo "$CANDIDATES" | head -5
        if [[ "$COUNT" -gt 5 ]]; then echo "... and $((COUNT - 5)) more"; fi
        log ""
        log "To delete these files, run: ./clean-memory.sh --force"
    fi
fi

# Also check for broken temp folders
TEMP_DIR="$HOME/.gemini/tmp"
if [[ -d "$TEMP_DIR" ]]; then
    log "Checking for temp files in $TEMP_DIR..."
    # Just show count for now, temp requires strict verification
    TEMP_COUNT=$(find "$TEMP_DIR" -type f | wc -l | tr -d ' ')
    log "Found $TEMP_COUNT files in temp directory."
fi

log "CLEANUP COMPLETE"
