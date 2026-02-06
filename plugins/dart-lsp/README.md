# Dart LSP Plugin

This plugin provides Language Server Protocol (LSP) support for Dart files in Claude Code.

## Prerequisites

You must have the Dart SDK installed and available in your PATH. The plugin uses the `dart language-server` command which is included with the Dart SDK.

### Installation

**macOS (Homebrew):**

```bash
brew tap dart-lang/dart
brew install dart
```

**Linux:**

```bash
sudo apt-get update
sudo apt-get install dart
```

**Windows:**

Download the Dart SDK from https://dart.dev/get-dart

### Verify Installation

```bash
dart --version
```

## Features

- Real-time diagnostics (errors, warnings, hints)
- Go to definition
- Find references
- Hover information (types, documentation)
- Document symbols

## Configuration

The plugin uses the Dart Analysis Server in LSP mode with the following configuration:

```json
{
  "dart": {
    "command": "dart",
    "args": ["language-server", "--protocol=lsp"],
    "extensionToLanguage": {
      ".dart": "dart"
    }
  }
}
```
