# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Seedium Skills is a Claude Code **plugin marketplace** — a collection of plugins that provide engineering workflow automation skills. It is not a compiled application; there is no build system, no package.json, and no tests. All logic lives in skill specification files (SKILL.md) that instruct Claude how to execute workflows.

## Repository Structure

```
.claude-plugin/marketplace.json    # Marketplace manifest — registers all plugins
plugins/<name>/
  .claude-plugin/plugin.json       # Plugin metadata (name, version, description)
  skills/<skill-name>/SKILL.md     # Skill specification with YAML frontmatter
  README.md                        # Plugin-level docs
```

Currently ships one plugin: **engineering** (`plugins/engineering/`) with the `/create-commit` skill.

## Key Concepts

**Marketplace manifest** (`.claude-plugin/marketplace.json`): Defines the marketplace name, owner, plugin root directory, and lists all available plugins with their source paths.

**Plugin manifest** (`plugin.json`): Minimal metadata — name, description, version. Must match the name registered in the marketplace manifest.

**Skill files** (`SKILL.md`): The core deliverable. Each skill has:
- **YAML frontmatter**: `name` (kebab-case), `description` (trigger phrases for Claude), `disable-model-invocation`, `allowed-tools` (security restrictions)
- **Markdown body**: Step-by-step execution instructions that Claude follows literally

## Conventions

- **Skill names** use kebab-case (`create-commit`, not `createCommit`)
- **Commits** follow [Conventional Commits](https://www.conventionalcommits.org) — use `/create-commit` to author them
- **Skill descriptions** must list trigger phrases so Claude knows when to invoke the skill
- **`allowed-tools`** in frontmatter restricts which tools a skill can use — always scope to the minimum needed
- **`disable-model-invocation: true`** means the skill defines its own complete flow and does not delegate to Claude's general reasoning

## Adding a New Skill

1. Create `plugins/<plugin>/skills/<skill-name>/SKILL.md` with frontmatter and execution steps
2. If creating a new plugin, also add `plugins/<name>/.claude-plugin/plugin.json` and register it in `.claude-plugin/marketplace.json`
