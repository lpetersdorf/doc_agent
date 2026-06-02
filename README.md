# Solution Agent

A Claude Code skill for documenting projects and researching Confluence Solution Designs.

## Installation

Add the shareable skill `document-project` to your Claude Code instance.  
On first use, the skill automatically installs all sub-agents, hooks, and templates.

## Usage

Open Claude Code in any project and type:

```
/document
```

Without arguments the skill asks which path you want:

- **PUSH** — Analyse a local project or remote repo and publish documentation to Confluence
- **PULL** — Research existing Confluence Solution Design documents

You can also pass your request directly:

```
/document analysiere das Repo github.com/… und erstell eine Confluence-Seite
/document was steht im Solution Design zum Payment Service?
```

## What it does

| What you say | What runs |
|---|---|
| "Analysiere das Repo github.com/…" | `repo-analyzer` |
| "Was zeigt dieses Architekturbild?" | `diagram-analyzer` |
| "Erstell eine Confluence-Seite" | `confluence-publisher` |
| "Was steht im Solution Design zu X?" | `solution-researcher` |
| "Analysiere Repo und erstell Confluence-Doku" | `repo-analyzer` → `confluence-publisher` |
| "Vollständige Doku: Repo + Bilder + Confluence" | `repo-analyzer` + `diagram-analyzer` → `confluence-publisher` |

## Requirements

- [Claude Code](https://claude.ai/code) installed
- Atlassian MCP server connected (for Confluence publishing)

## This repository

This repo is the **content store** for the skill — it holds sub-agents, hooks, and templates.  
The skill clones/pulls it automatically on setup. See [CLAUDE.md](CLAUDE.md) for the maintainer guide.
