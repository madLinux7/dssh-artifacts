#!/usr/bin/env bash
set -euo pipefail

DSSH_DIR="$HOME/.dssh"
DB="dssh.db"
DEMO_DB="demoDB_dssh.db"
BACKUP="/tmp/dssh.db"
OUTPUT_DIR="../dssh"

TAPES=(
    demo_1.tape
    demo_instant_connect.tape
    demo_wizard.tape
    demo_config.tape
    demo_tabs.tape
)

cleanup() {
    echo "Restoring original database..."
    if [[ -f "$BACKUP" ]]; then
        mv "$BACKUP" "$DSSH_DIR/$DB"
        echo "Original database restored."
    else
        echo "WARNING: No backup found at $BACKUP"
    fi
}
trap cleanup EXIT

# 1. Backup current DB
if [[ -f "$DSSH_DIR/$DB" ]]; then
    mv "$DSSH_DIR/$DB" "$BACKUP"
    echo "Backed up $DB to $BACKUP"
else
    echo "No existing $DB found, skipping backup."
fi

# 2. Switch to demo DB
if [[ -f "$DSSH_DIR/$DEMO_DB" ]]; then
    cp "$DSSH_DIR/$DEMO_DB" "$DSSH_DIR/$DB"
    echo "Activated demo database."
else
    echo "ERROR: $DSSH_DIR/$DEMO_DB not found" >&2
    exit 1
fi

# 3-7. Run all tapes
for tape in "${TAPES[@]}"; do
    echo "Recording $tape..."
    vhs "$tape"
done

# 8. Move output GIFs to ../dssh
mkdir -p "$OUTPUT_DIR"
for tape in "${TAPES[@]}"; do
    gif="${tape%.tape}.gif"
    if [[ -f "$gif" ]]; then
        mv "$gif" "$OUTPUT_DIR/"
        echo "Moved $gif to $OUTPUT_DIR/"
    else
        echo "WARNING: $gif not found"
    fi
done

echo "Done. All demos created."
# 9. Cleanup (restore) happens via trap
