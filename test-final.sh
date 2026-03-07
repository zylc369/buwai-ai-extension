#!/bin/bash

echo "========================================"
echo "Final System Test"
echo "========================================"
echo ""

echo "Test 1: Fresh Install"
echo "---------------------"
./install.sh
echo ""
echo "Metadata check:"
head -5 extensions/commands/trans-md-en-to-zh.md
echo ""
echo "Duplicate check:"
grep -c "^extension-id:" extensions/commands/trans-md-en-to-zh.md
echo ""

echo "Test 2: Reinstall (should skip)"
echo "---------------------------------"
./install.sh
echo ""

echo "Test 3: Dry-run Uninstall"
echo "----------------------------"
./uninstall.sh --dry-run
echo ""

echo "Test 4: Force Uninstall"
echo "--------------------------"
./uninstall.sh --force
echo ""

echo "Test 5: Verify Files Removed"
echo "----------------------------"
if [ ! -f "extensions/commands/trans-md-en-to-zh.md" ]; then
    echo "✓ Command file removed"
else
    echo "✗ Command file still exists"
fi

if [ ! -d "extensions/commands/trans-md-en-to-zh-assets" ]; then
    echo "✓ Assets folder removed"
else
    echo "✗ Assets folder still exists"
fi
echo ""

echo "========================================"
echo "All Tests Complete!"
echo "========================================"
echo ""
echo "Restoring files for next test..."
git checkout HEAD -- extensions/
./install.sh
echo "✓ System ready"
