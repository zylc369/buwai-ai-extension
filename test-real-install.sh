#!/bin/bash

echo "========================================"
echo "Testing Real Installation System"
echo "========================================"
echo ""

echo "Step 1: Check current state"
echo "----------------------------"
echo "Source extensions:"
ls -la extensions/commands/ 2>/dev/null | tail -n +4 || echo "  No files"
echo ""
echo "OpenCode directories:"
for dir in "$HOME/.config/opencode" "$HOME/.opencode" "$HOME/.openclaw"; do
    if [ -d "$dir" ]; then
        echo "  ✓ $dir (exists)"
        ls -la "$dir/" 2>/dev/null | grep -E "commands|skills" || echo "    No extensions yet"
    else
        echo "  ✗ $dir (not exists)"
    fi
done
echo ""

echo "Step 2: Test install.sh --help"
echo "--------------------------------------"
./install.sh --help
echo ""

echo "Step 3: Test install.sh --verify-only"
echo "----------------------------------------"
./install.sh --verify-only
echo ""

echo "Step 4: Test install.sh (dry install to temp)"
echo "------------------------------------------------"
echo "Note: This will actually try to install to OpenCode"
echo "      If OpenCode directory exists, files will be copied there."
echo ""
read -p "Continue with real install test? (y/N): " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Skipped real install test"
    echo ""
    echo "Step 5: Display installation record format"
    echo "----------------------------------------"
    cat << 'RECORD'
# Extension Installation Record
# DO NOT DELETE - Used for uninstallation

EXTENSION_ID="buwai-ai-extension"
INSTALL_DATE="2026-03-07T12:30:00Z"
INSTALL_DIR="/home/user/.config/opencode"
FILES_COUNT="5"
VERSION="1.0.0"
RECORD
    exit 0
fi

echo "Running real install..."
./install.sh

if [ -f .extension-install ]; then
    echo ""
    echo "Step 5: Check installation record"
    echo "------------------------------------"
    cat .extension-install
    echo ""

    echo "Step 6: Test uninstall.sh --dry-run"
    echo "-----------------------------------------"
    ./uninstall.sh --dry-run
else
    echo "✗ Installation record not created"
fi

echo ""
echo "========================================"
echo "Test Complete!"
echo "========================================"
