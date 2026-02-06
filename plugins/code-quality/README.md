# code-quality

Automated code quality hooks for Claude Code.

## Features

### Auto-fixes (PostToolUse)

Automatically applies ESLint fixes and Prettier formatting after every `Edit` or `Write` operation.

- Detects package manager (npm, yarn, pnpm, bun)
- Finds ESLint and Prettier configs by walking up from the edited file
- Only runs on supported file types (.js, .ts, .tsx, .vue, .svelte, etc.)

### Quality Gates (Stop)

Blocks Claude from stopping until code quality checks pass.

- Runs the `quality-gates` script from your package.json (if it exists)
- Detects package manager automatically
- Shows failure output and blocks stopping until issues are fixed

## Installation

Add to your Claude Code settings:

```json
{
  "plugins": [
    "/path/to/code-quality"
  ]
}
```

Or use the `--plugin-dir` flag:

```bash
claude --plugin-dir ~/dev/claude-code-plugins/code-quality
```

## Configuration

### Quality Gates Script

Add a `quality-gates` script to your project's package.json:

```json
{
  "scripts": {
    "quality-gates": "npm run check-types && npm run lint && npm run test"
  }
}
```

The script can run any combination of quality checks:
- Type checking (`tsc --noEmit`)
- Linting (`eslint .`)
- Tests (`vitest run`)
- Build verification (`npm run build`)

### ESLint & Prettier

The auto-fixes hook automatically detects ESLint and Prettier configurations in your project. No additional configuration needed.

## Requirements

- `jq` must be installed for JSON parsing
- ESLint and Prettier should be installed in your project (for auto-fixes)
