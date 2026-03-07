#!/bin/bash

################################################################################
# Test Script for AI Extension Installation/Uninstallation System
#
# Description: Demonstrates the metadata-based extension system
# Usage: ./test-system.sh
#
################################################################################

set -e

echo "========================================"
echo "AI Extension System Test"
echo "========================================"
echo ""

echo "Step 1: Initial State"
echo "-------------------"
ls -la extensions/commands/ 2>/dev/null | grep -v "^d" | tail -n +4 || echo "No files found"
echo ""

echo "Step 2: Install with default ID"
echo "-------------------------------"
./install.sh
echo ""

echo "Step 3: Check metadata in files"
echo "-------------------------------"
echo "File: extensions/commands/trans-md-en-to-zh.md"
head -5 extensions/commands/trans-md-en-to-zh.md
echo ""

echo "Step 4: Dry run uninstall"
echo "-------------------------"
./uninstall.sh --dry-run
echo ""

echo "Step 5: Reinstall with custom ID"
echo "---------------------------------"
./install.sh --extension-id test-extension-001
echo ""

echo "Step 6: Check updated metadata"
echo "-----------------------------"
echo "File: extensions/commands/trans-md-en-to-zh.md"
head -5 extensions/commands/trans-md-en-to-zh.md
echo ""

echo "Step 7: Dry run with custom ID"
echo "------------------------------"
./uninstall.sh --extension-id test-extension-001 --dry-run
echo ""

echo "Step 8: Force uninstall with custom ID"
echo "--------------------------------------"
./uninstall.sh --extension-id test-extension-001 --force
echo ""

echo "Step 9: Verify files removed"
echo "---------------------------"
ls -la extensions/commands/ 2>/dev/null | grep -v "^d" | tail -n +4 || echo "No files found"
echo ""

echo "========================================"
echo "Test Complete!"
echo "========================================"
echo ""
echo "Restoring files from git..."
git checkout HEAD -- extensions/
./install.sh
echo "✓ Files restored and reinstalled"
