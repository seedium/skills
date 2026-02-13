# Seedium Skills

A [Claude Code plugin marketplace](https://code.claude.com/docs/en/plugin-marketplaces) with engineering workflow skills by Seedium.

## Getting started

### 1. Add the marketplace

```shell
/plugin marketplace add seedium/skills
```

### 2. Install a plugin

```shell
/plugin install engineering@seedium
```

### 3. Use a skill

```shell
/create-commit
```

## Plugins

| Plugin | Description |
|---|---|
| [engineering](plugins/engineering) | Engineering workflow skills (commit automation, and more to come) |

## Contributing

Each plugin lives under `plugins/<name>/` and follows the [Claude Code plugin structure](https://code.claude.com/docs/en/plugins):

```
plugins/<name>/
  .claude-plugin/
    plugin.json
  skills/
    <skill-name>/
      SKILL.md
```

To add a new skill to an existing plugin, create a directory under `skills/` with a `SKILL.md` file. To add a new plugin, also register it in `.claude-plugin/marketplace.json`.
