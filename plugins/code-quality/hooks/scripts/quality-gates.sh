#!/usr/bin/env bash
# Stop hook to run quality gates before Claude stops
# Blocks stopping if the quality-gates script fails
#
# Output format (JSON to stdout):
#   On failure: { "decision": "block", "reason": "..." }
#   On success: (no output, exit 0)

set -euo pipefail

# Get the Claude Code launch directory from environment
launch_dir="${CLAUDE_WORKING_DIRECTORY:-$(pwd)}"

cd "$launch_dir"

# Check if package.json exists
if [[ ! -f "package.json" ]]; then
    exit 0
fi

# Find a script containing "quality" in the name
quality_script=$(jq -r '.scripts // {} | keys[] | select(contains("quality"))' package.json | head -1)

if [[ -z "$quality_script" ]]; then
    exit 0
fi

# Detect package manager by looking for lock files
detect_package_manager() {
    local dir="$1"

    if [[ -f "$dir/pnpm-lock.yaml" ]]; then
        echo "pnpm"
    elif [[ -f "$dir/yarn.lock" ]]; then
        echo "yarn"
    elif [[ -f "$dir/bun.lockb" ]]; then
        echo "bun"
    elif [[ -f "$dir/package-lock.json" ]]; then
        echo "npm"
    else
        echo ""
    fi
}

# Get the run command for the detected package manager
get_run_command() {
    local pm="$1"

    case "$pm" in
        npm)  echo "npm run" ;;
        yarn) echo "yarn run" ;;
        pnpm) echo "pnpm run" ;;
        bun)  echo "bun run" ;;
        *)    echo "" ;;
    esac
}

package_manager=$(detect_package_manager "$launch_dir")

# Skip if no package manager detected
if [[ -z "$package_manager" ]]; then
    exit 0
fi

run_cmd=$(get_run_command "$package_manager")

# Run the quality script and capture output
output=$($run_cmd "$quality_script" 2>&1) || {
    exit_code=$?
    reason=$(printf '%s\n\nFix the issues above before stopping.' "$output")
    jq -n --arg reason "$reason" '{"decision": "block", "reason": $reason}'
    exit 2
}

exit 0
