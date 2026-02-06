#!/usr/bin/env bash
# Post-tool hook to apply ESLint fixes and Prettier formatting after Edit/Write operations
# Reads hook input from stdin (JSON with tool_input containing file_path)

set -o pipefail

# Read the hook input JSON from stdin
hook_input=$(cat)

# Extract the file path from the tool input
file_path=$(echo "$hook_input" | jq -r '.tool_input.file_path // empty')

if [[ -z "$file_path" ]]; then
    exit 0
fi

# Get the Claude Code launch directory from environment
launch_dir="${CLAUDE_WORKING_DIRECTORY:-$(pwd)}"

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

# Get the exec command for the detected package manager
get_exec_command() {
    local pm="$1"

    case "$pm" in
        npm)  echo "npm exec --" ;;
        yarn) echo "yarn exec" ;;
        pnpm) echo "pnpm exec" ;;
        bun)  echo "bun run" ;;
        *)    echo "" ;;
    esac
}

# Check if file has an ESLint-supported extension
is_eslint_file() {
    local file="$1"
    case "$file" in
        *.js|*.mjs|*.cjs|*.jsx|*.ts|*.mts|*.cts|*.tsx|*.vue|*.svelte)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Walk up from file dir to launch dir once, finding both ESLint and Prettier configs
# Sets global variables: ESLINT_CONFIG_DIR, PRETTIER_CONFIG_DIR
find_configs() {
    local start_dir="$1"
    local stop_dir="$2"
    local current_dir="$start_dir"

    ESLINT_CONFIG_DIR=""
    PRETTIER_CONFIG_DIR=""

    # Normalize stop path for comparison
    stop_dir=$(cd "$stop_dir" 2>/dev/null && pwd)

    while true; do
        current_dir=$(cd "$current_dir" 2>/dev/null && pwd) || break

        # Check for ESLint config (if not found yet)
        if [[ -z "$ESLINT_CONFIG_DIR" ]]; then
            for cfg in eslint.config.{js,mjs,cjs} .eslintrc{,.js,.cjs,.json,.yaml,.yml}; do
                if [[ -f "$current_dir/$cfg" ]]; then
                    ESLINT_CONFIG_DIR="$current_dir"
                    break
                fi
            done
        fi

        # Check for Prettier config (if not found yet)
        if [[ -z "$PRETTIER_CONFIG_DIR" ]]; then
            for cfg in .prettierrc{,.json,.yaml,.yml,.js,.cjs,.mjs} prettier.config.{js,cjs,mjs}; do
                if [[ -f "$current_dir/$cfg" ]]; then
                    PRETTIER_CONFIG_DIR="$current_dir"
                    break
                fi
            done
        fi

        # Stop early if both found
        if [[ -n "$ESLINT_CONFIG_DIR" ]] && [[ -n "$PRETTIER_CONFIG_DIR" ]]; then
            break
        fi

        # Stop if we've reached the launch dir
        if [[ "$current_dir" == "$stop_dir" ]]; then
            break
        fi

        # Stop if we've reached root
        if [[ "$current_dir" == "/" ]]; then
            break
        fi

        # Move to parent directory
        current_dir="$current_dir/.."
    done
}


# Main logic
package_manager=$(detect_package_manager "$launch_dir")

# Skip if no package manager detected
if [[ -z "$package_manager" ]]; then
    exit 0
fi

exec_cmd=$(get_exec_command "$package_manager")
file_dir=$(dirname "$file_path")

# Find both configs in a single directory walk
find_configs "$file_dir" "$launch_dir"

# --- ESLint ---
if is_eslint_file "$file_path" && [[ -n "$ESLINT_CONFIG_DIR" ]]; then
    cd "$ESLINT_CONFIG_DIR" && $exec_cmd eslint --fix "$file_path" 2>&1 || true
fi

# --- Prettier ---
if [[ -n "$PRETTIER_CONFIG_DIR" ]]; then
    cd "$PRETTIER_CONFIG_DIR" && $exec_cmd prettier --write --ignore-unknown "$file_path" 2>&1 || true
fi

exit 0
