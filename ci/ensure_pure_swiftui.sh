#!/bin/bash
set -e

echo "🔍 Checking for AppKit/WebKit violations..."

FORBIDDEN_PATTERNS=(
    "import AppKit"
    "import Cocoa"
    "import WebKit"
    "NSViewRepresentable"
    "NSViewControllerRepresentable"
    "@NSApplicationDelegateAdaptor"
    "NSDocument"
    "NSWindow"
    "NSView "
    "NSTextView"
    "WKWebView"
    "NSViewController"
    "NSWindowController"
)

VIOLATIONS=0
EXCLUDE_PATHS="TextDown/Utilities/NSColor.swift"  # Temporary exception for Color+CSS

for pattern in "${FORBIDDEN_PATTERNS[@]}"; do
    echo "  Checking for: $pattern"

    # Search in TextDown/ directory, excluding specific files
    if grep -r --include="*.swift" --exclude-dir="build" "$pattern" TextDown/ 2>/dev/null | grep -v "$EXCLUDE_PATHS"; then
        echo "❌ VIOLATION: Found '$pattern' in codebase"
        VIOLATIONS=$((VIOLATIONS + 1))
    fi
done

if [ $VIOLATIONS -gt 0 ]; then
    echo ""
    echo "❌ CI FAILED: $VIOLATIONS AppKit/WebKit violations detected"
    echo "   This branch requires PURE SwiftUI - no AppKit bridges allowed."
    echo "   Exception: NSColor.swift (will be migrated to Color+CSS.swift)"
    exit 1
fi

echo "✅ CI PASSED: Codebase is pure SwiftUI"
exit 0
