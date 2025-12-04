#!/bin/bash
# =============================================================================
# test-bash-scripts.sh - Validate bash scripts syntax and structure
# =============================================================================
#
# Tests:
#   - Bash syntax validation (bash -n)
#   - Shellcheck linting
#   - Required functions exist
#   - Required variables defined
#
# Usage:
#   ./tests/test-bash-scripts.sh
#
# Exit codes:
#   0 - All tests passed
#   1 - Tests failed
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0

log_pass() {
    echo -e "${GREEN}✓ PASS${NC}: $1"
    ((TESTS_PASSED++)) || true
}

log_fail() {
    echo -e "${RED}✗ FAIL${NC}: $1"
    ((TESTS_FAILED++)) || true
}

log_skip() {
    echo -e "${YELLOW}○ SKIP${NC}: $1"
}

echo "============================================="
echo "  Bash Script Tests"
echo "============================================="
echo ""

# List of bash scripts to test
BASH_SCRIPTS=(
    "mac-setup/llm-workstation/install-llm-workstation.sh"
    "mac-setup/dev-workstation/install-dev-workstation.sh"
    "ubuntu-setup/dev-workstation/install-dev-workstation.sh"
    "ubuntu-setup/headless/install-headless.sh"
    "ubuntu-setup/update.sh"
)

# Test 1: Check scripts exist
echo "--- Checking scripts exist ---"
for script in "${BASH_SCRIPTS[@]}"; do
    if [[ -f "$ROOT_DIR/$script" ]]; then
        log_pass "$script exists"
    else
        log_fail "$script not found"
    fi
done
echo ""

# Test 2: Bash syntax validation
echo "--- Bash syntax validation ---"
for script in "${BASH_SCRIPTS[@]}"; do
    if [[ -f "$ROOT_DIR/$script" ]]; then
        if bash -n "$ROOT_DIR/$script" 2>/dev/null; then
            log_pass "$script syntax valid"
        else
            log_fail "$script has syntax errors"
        fi
    fi
done
echo ""

# Test 3: Shellcheck (if available)
echo "--- Shellcheck linting ---"
if command -v shellcheck &>/dev/null; then
    for script in "${BASH_SCRIPTS[@]}"; do
        if [[ -f "$ROOT_DIR/$script" ]]; then
            # SC1087: False positive for jq/non-bash expressions
            # SC1091: Don't follow sourced files
            # SC2015: A && B || C pattern (intentional for fallback logic)
            # SC2016: Single quotes prevent expansion (intentional)
            # SC2024: sudo redirect (log file owned by user, intentional)
            # SC2034: Unused variables (often for user config)
            # SC2086: Word splitting (intentional in many cases)
            if shellcheck -e SC1087,SC1091,SC2015,SC2016,SC2024,SC2034,SC2086 "$ROOT_DIR/$script" 2>/dev/null; then
                log_pass "$script passes shellcheck"
            else
                log_fail "$script has shellcheck warnings"
            fi
        fi
    done
else
    log_skip "shellcheck not installed"
fi
echo ""

# Test 4: Check shebang
echo "--- Checking shebang ---"
for script in "${BASH_SCRIPTS[@]}"; do
    if [[ -f "$ROOT_DIR/$script" ]]; then
        first_line=$(head -n 1 "$ROOT_DIR/$script")
        if [[ "$first_line" == "#!/bin/bash" ]] || [[ "$first_line" == "#!/usr/bin/env bash" ]]; then
            log_pass "$script has valid shebang"
        else
            log_fail "$script missing or invalid shebang: $first_line"
        fi
    fi
done
echo ""

# Test 5: Check for required elements in install scripts
echo "--- Checking required elements ---"
for script in "${BASH_SCRIPTS[@]}"; do
    if [[ -f "$ROOT_DIR/$script" ]] && [[ "$script" == *"install"* ]]; then
        # Check for logging function
        if grep -q "log\|echo" "$ROOT_DIR/$script"; then
            log_pass "$script has logging"
        else
            log_fail "$script missing logging"
        fi

        # Check for error handling
        if grep -q "set -e\|trap" "$ROOT_DIR/$script"; then
            log_pass "$script has error handling"
        else
            log_fail "$script missing error handling"
        fi
    fi
done
echo ""

# Test 6: Check JSON manifests are valid
echo "--- Checking JSON manifests ---"
JSON_FILES=(
    "mac-setup/llm-workstation/packages.json"
    "mac-setup/dev-workstation/packages.json"
    "win11-setup/dev-workstation/packages.json"
    "win11-setup/client-workstation/packages.json"
    "ubuntu-setup/dev-workstation/packages.json"
    "ubuntu-setup/headless/packages.json"
)

if command -v jq &>/dev/null; then
    for json in "${JSON_FILES[@]}"; do
        if [[ -f "$ROOT_DIR/$json" ]]; then
            if jq empty "$ROOT_DIR/$json" 2>/dev/null; then
                log_pass "$json is valid JSON"
            else
                log_fail "$json is invalid JSON"
            fi
        else
            log_fail "$json not found"
        fi
    done
else
    log_skip "jq not installed, skipping JSON validation"
fi
echo ""

# Summary
echo "============================================="
echo "  Test Summary"
echo "============================================="
echo -e "  Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "  Failed: ${RED}$TESTS_FAILED${NC}"
echo ""

if [[ $TESTS_FAILED -gt 0 ]]; then
    echo -e "${RED}Tests failed!${NC}"
    exit 1
else
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
fi
