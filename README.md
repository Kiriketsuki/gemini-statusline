# gemini-statusline

A two-line Gemini CLI status bar displaying model, workspace context, and vault inbox depth. Built for the [obKidian](https://github.com/Kiriketsuki/obKidian) vault.

Note: Gemini CLI does not natively support a `statusLine` hook like Claude Code. This script can be used in your shell prompt or as a standalone status tool.

## Scripts

| Script | Role |
|:---|:---|
| `statusline-command.sh` | Main renderer — reads caches and emits the formatted two-line status bar |
| `fetch-stats.sh` | Background fetcher — polls GitHub for open issue count per repo and writes to `/tmp/.gemini_stats_cache_{slug}` |

## Status Line Layout

```
<model> | <folder> • <branch> ↑<unsynced>
issues: <n> • inbox: <n>
```

Colours follow the Chrysaki palette.

## Setup

Add as a submodule inside your Gemini agent directory:

```bash
# From your Gemini agent directory (e.g. ~/dev/obKidian/000-System/Agents/Gemini)
git submodule add https://github.com/Kiriketsuki/gemini-statusline.git statusline
```

## Dependencies

- `jq` — JSON parsing
- `gh` — GitHub CLI for issue counts (fetch-stats.sh); must be authenticated
- `git` — branch and commit info
