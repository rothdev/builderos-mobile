#!/bin/bash
# Xcode Project Backup Script
# Automatically backs up project file before any modifications

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_FILE="$SCRIPT_DIR/BuilderOS.xcodeproj/project.pbxproj"
BACKUP_DIR="$SCRIPT_DIR/.xcodeproj-backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Create backup
if [ -f "$PROJECT_FILE" ]; then
    cp "$PROJECT_FILE" "$BACKUP_DIR/project.pbxproj.$TIMESTAMP"
    echo "✅ Backed up Xcode project to: $BACKUP_DIR/project.pbxproj.$TIMESTAMP"

    # Keep only last 10 backups
    ls -t "$BACKUP_DIR"/project.pbxproj.* | tail -n +11 | xargs rm -f 2>/dev/null
    echo "📁 Keeping last 10 backups"
else
    echo "❌ Project file not found: $PROJECT_FILE"
    exit 1
fi

# Validate project file format
if head -1 "$PROJECT_FILE" | grep -q "// !\$\*UTF8\*\$!"; then
    echo "✅ Project file format is valid"
else
    echo "⚠️  WARNING: Project file may be corrupted!"
    exit 1
fi
