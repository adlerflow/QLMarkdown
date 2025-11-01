#!/bin/bash
# Compare current HTML output against golden files
# Usage: ./compare.sh [implementation-name]
# Example: ./compare.sh cmark-gfm

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
TEST_DIR="$SCRIPT_DIR/.."
TESTCASES_DIR="$TEST_DIR/testcases"

# Default to cmark-gfm if no argument provided
IMPLEMENTATION="${1:-cmark-gfm}"
EXPECTED_DIR="$TEST_DIR/expected/$IMPLEMENTATION"

echo "=========================================="
echo "Golden File Comparison"
echo "=========================================="
echo "Implementation: $IMPLEMENTATION"
echo "Expected output: $EXPECTED_DIR"
echo "=========================================="
echo

# Check if expected files exist
if [ ! -d "$EXPECTED_DIR" ]; then
    echo "❌ ERROR: Expected output directory not found: $EXPECTED_DIR"
    echo
    echo "Generate baseline first:"
    echo "  ./generate-baseline.sh $IMPLEMENTATION"
    exit 1
fi

# Find the CLI tool (check multiple locations)
CLI_PATH=""
if [ -f "/Users/home/.local/bin/qlmarkdown_cli" ]; then
    CLI_PATH="/Users/home/.local/bin/qlmarkdown_cli"
elif [ -f "$PROJECT_ROOT/build/Debug/TextDown.app/Contents/Resources/qlmarkdown_cli" ]; then
    CLI_PATH="$PROJECT_ROOT/build/Debug/TextDown.app/Contents/Resources/qlmarkdown_cli"
fi

if [ -z "$CLI_PATH" ]; then
    echo "❌ ERROR: qlmarkdown_cli not found"
    echo "Run from main branch: xcodebuild -project QLMarkdown.xcodeproj -scheme qlmarkdown_cli build"
    exit 1
fi

# Create temporary directory for current output
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo "Temporary output: $TEMP_DIR"
echo

# Count test files
TEST_COUNT=$(find "$TESTCASES_DIR" -name "*.md" | wc -l | tr -d ' ')
echo "Running $TEST_COUNT tests..."
echo

PASSED=0
FAILED=0
FAILED_TESTS=()

for markdown_file in "$TESTCASES_DIR"/*.md; do
    if [ ! -f "$markdown_file" ]; then
        continue
    fi

    filename=$(basename "$markdown_file")
    basename="${filename%.md}"
    expected_file="$EXPECTED_DIR/${basename}.html"
    current_file="$TEMP_DIR/${basename}.html"

    # Generate current output
    "$CLI_PATH" "$markdown_file" > "$current_file" 2>/dev/null || true

    # Compare
    if diff -q "$expected_file" "$current_file" > /dev/null 2>&1; then
        echo "✅ PASS: $filename"
        ((PASSED++))
    else
        echo "❌ FAIL: $filename"
        ((FAILED++))
        FAILED_TESTS+=("$filename")

        # Show diff (first 20 lines)
        echo "   Differences:"
        diff -u "$expected_file" "$current_file" | head -20 | sed 's/^/   /'
        echo
    fi
done

echo
echo "=========================================="
echo "Results:"
echo "  Passed: $PASSED / $TEST_COUNT"
echo "  Failed: $FAILED / $TEST_COUNT"

if [ $FAILED -gt 0 ]; then
    echo
    echo "Failed tests:"
    for test in "${FAILED_TESTS[@]}"; do
        echo "  - $test"
    done
    echo
    echo "To see full diff for a failed test:"
    echo "  diff $EXPECTED_DIR/<test>.html $TEMP_DIR/<test>.html"
fi

echo "=========================================="

if [ $FAILED -gt 0 ]; then
    exit 1
fi

echo
echo "✅ All tests passed!"
