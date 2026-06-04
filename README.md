# Solution Agent

A Claude Code **plugin** for documenting projects and researching Confluence Solution Designs.

## Installation

```bash
# Add the marketplace (once)
/plugin marketplace add lpetersdorf/doc_agent

# Install the plugin
/plugin install solution-agent
```

## Usage

Open Claude Code in any project and type:

```
/solution-agent:document-project
```

Without arguments the skill asks which path you want:

- **PUSH** — Analyse a local project or remote repo and publish documentation to Confluence
- **PULL** — Research existing Confluence Solution Design documents

You can also pass your request directly:

```
/solution-agent:document-project analysiere das Repo github.com/… und erstell eine Confluence-Seite
/solution-agent:document-project was steht im Solution Design zum Payment Service?
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

**Optional tools** (for analysing Office/PDF documents):
```bash
brew install pandoc poppler
```
Without these, `.docx`, `.pptx`, and `.pdf` files are skipped during document analysis. All other features work without them.

## This repository

This repo is the **Claude Code plugin** — it holds the skill, sub-agents, hooks, and templates.  
Claude Code loads everything automatically on plugin install. See [CLAUDE.md](CLAUDE.md) for the maintainer guide.
