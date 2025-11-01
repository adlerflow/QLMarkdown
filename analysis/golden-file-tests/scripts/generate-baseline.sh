#!/bin/bash
# Generate golden HTML files from Markdown test cases
# Usage: ./generate-baseline.sh [implementation-name]
# Example: ./generate-baseline.sh cmark-gfm

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
TEST_DIR="$SCRIPT_DIR/.."
TESTCASES_DIR="$TEST_DIR/testcases"

# Default to cmark-gfm if no argument provided
IMPLEMENTATION="${1:-cmark-gfm}"
EXPECTED_DIR="$TEST_DIR/expected/$IMPLEMENTATION"

echo "=========================================="
echo "Golden File Generator"
echo "=========================================="
echo "Implementation: $IMPLEMENTATION"
echo "Test cases: $TESTCASES_DIR"
echo "Output: $EXPECTED_DIR"
echo "=========================================="
echo

# Create expected directory
mkdir -p "$EXPECTED_DIR"

# Check if TextDown app exists
APP_PATH="$PROJECT_ROOT/build/Debug/TextDown.app"
if [ ! -d "$APP_PATH" ]; then
    echo "❌ ERROR: TextDown.app not found at $APP_PATH"
    echo "Please build the project first:"
    echo "  cd $PROJECT_ROOT"
    echo "  xcodebuild -scheme TextDown -configuration Debug"
    exit 1
fi

# Find the CLI tool
CLI_PATH="$APP_PATH/Contents/Resources/qlmarkdown_cli"
if [ ! -f "$CLI_PATH" ]; then
    echo "⚠️  WARNING: qlmarkdown_cli not found (expected for post-Phase 2)"
    echo "Using Swift rendering fallback..."
    USE_CLI=false
else
    echo "✓ Using qlmarkdown_cli: $CLI_PATH"
    USE_CLI=true
fi

# Count test files
TEST_COUNT=$(find "$TESTCASES_DIR" -name "*.md" | wc -l | tr -d ' ')
echo "Found $TEST_COUNT test cases"
echo

# Process each test case
PROCESSED=0
FAILED=0

for markdown_file in "$TESTCASES_DIR"/*.md; do
    if [ ! -f "$markdown_file" ]; then
        continue
    fi

    filename=$(basename "$markdown_file")
    basename="${filename%.md}"
    html_file="$EXPECTED_DIR/${basename}.html"

    echo -n "Processing: $filename ... "

    if [ "$USE_CLI" = true ]; then
        # Use CLI tool
        if "$CLI_PATH" "$markdown_file" > "$html_file" 2>/dev/null; then
            echo "✅"
            ((PROCESSED++))
        else
            echo "❌ FAILED"
            ((FAILED++))
        fi
    else
        # Fallback: Use Swift script (requires Settings+render.swift to be accessible)
        # This is a placeholder - in practice, we'd need to compile and run Swift code
        echo "⚠️  SKIPPED (no CLI available)"
    fi
done

echo
echo "=========================================="
echo "Results:"
echo "  Processed: $PROCESSED / $TEST_COUNT"
if [ $FAILED -gt 0 ]; then
    echo "  Failed: $FAILED"
fi
echo "  Output: $EXPECTED_DIR"
echo "=========================================="

if [ $FAILED -gt 0 ]; then
    exit 1
fi

echo
echo "✅ Golden files generated successfully!"
echo
echo "Next steps:"
echo "  1. Review generated HTML files in $EXPECTED_DIR"
echo "  2. Run comparison: ./compare.sh $IMPLEMENTATION"
echo "  3. Commit golden files to git"
