# Claude Code Plugins

A collection of plugins for [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

## Available Plugins

| Plugin                                           | Description                                                                |
| ------------------------------------------------ | -------------------------------------------------------------------------- |
| [code-quality](plugins/code-quality)             | Auto-fixes (ESLint/Prettier) after edits and quality gates before stopping |
| [dart-lsp](plugins/dart-lsp)                     | LSP integration for Dart files using the Dart Analysis Server              |
| [vue-typescript-lsp](plugins/vue-typescript-lsp) | TypeScript Language Server with Vue support                                |

## Setup

### Add the Marketplace

Run the following slash command in Claude Code:

```
/plugin marketplace add blaugold/claude-code-plugins
```

### Browse and Install Plugins

List available plugins:

```
/plugin marketplace list
```

Install a plugin:

```
/plugin install <plugin-name>@local-plugins
```

### Alternative: Settings File

Add the marketplace to your Claude Code settings file (`~/.claude/settings.json`
or `.claude/settings.json` in your project):

```json
{
  "extraKnownMarketplaces": {
    "local-plugins": {
      "source": {
        "source": "github",
        "repo": "blaugold/claude-code-plugins"
      }
    }
  }
}
```
