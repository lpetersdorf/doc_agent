# Solution Agent
 
Ein Claude-Code-**Plugin** zum Dokumentieren von Projekten und Recherchieren von Confluence Solution Designs.
 
## Installation
 
```bash
# Marketplace hinzufügen (einmalig)
/plugin marketplace add lpetersdorf/doc_agent
 
# Plugin installieren
/plugin install solution-agent
```
 
## Verwendung
 
### Claude CLI
 
Nach der Installation:
 
1. Wechsle in das zu dokumentierende Projektverzeichnis und öffne dort ein Terminal.
2. Starte Claude (`claude`).
3. Verwende in Claude den Skill, um den Projektordner zu dokumentieren:
```
/document-project
```
 
### Claude Cowork / Chat
 
Wenn du lieber **Cowork** oder den **Chat** nutzt, muss das Plugin zunächst in den
Einstellungen aktiviert werden:
 
1. Öffne **Einstellungen → Fähigkeiten → Skills**.
2. Über **Plugin erstellen** lässt sich ein Marketplace hinzufügen — füge den
   Marketplace `lpetersdorf/doc_agent` hinzu.
3. Aktiviere anschließend den **Solution Agent**.
Danach stehen die Skills des Plugins in Cowork und Chat zum Dokumentieren zur Verfügung.
 
### Pfade (PUSH / PULL)
 
Ohne Argument fragt der Skill, welchen Pfad du möchtest:
 
- **PUSH** — Ein lokales Projekt oder Remote-Repo analysieren und die Dokumentation nach Confluence veröffentlichen
- **PULL** — Vorhandene Confluence-Solution-Design-Dokumente recherchieren
Du kannst deine Anfrage auch direkt übergeben:
 
```
/document-project Analysiere mein aktuelles Projektverzeichnis und erstelle eine Confluence-Doku dazu.
/document-project Welche vorhandenen Solution Designs beschäftigen sich mit Databricks?
```
 
## Was es macht
 
| Was du sagst | Was läuft |
|---|---|
| „Analysiere das Repo github.com/…" | `repo-analyzer` |
| „Was zeigt dieses Architekturbild?" | `diagram-analyzer` |
| „Erstell eine Confluence-Seite" | `confluence-publisher` |
| „Was steht im Solution Design zu X?" | `solution-researcher` |
| „Analysiere Repo und erstell Confluence-Doku" | `repo-analyzer` → `confluence-publisher` |
| „Vollständige Doku: Repo + Bilder + Confluence" | `repo-analyzer` + `diagram-analyzer` → `confluence-publisher` |
 
## Skills
 
| Skill | Zweck |
|---|---|
| `/document-project` | Orchestriert Analyse und Confluence-Dokumentation (PUSH) oder Confluence-Recherche (PULL) |
| `/document-status` | Zeigt vorhandene Analyse-Artefakte und die Dokumentations-Vorschau im aktuellen Verzeichnis |
| `/document-sync` | Aktualisiert eine bestehende Confluence-Seite mit der vorhandenen `dokumentation-preview.md` — ohne Duplikat zu erstellen |
 
## Sicherheit
 
Das Plugin bringt Sicherheits-Hooks mit, die automatisch greifen:
 
- Bash-Befehle und Read-Zugriffe auf Credential-Dateien (z. B. `.env`) werden blockiert.
- `git push` und destruktive Operationen werden in geklonten Analyse-Repos (`/tmp/repo-analyzer-*`)
  unterbunden — dein lokales Arbeitsverzeichnis bleibt davon unberührt.
## Voraussetzungen
 
- [Claude Code](https://claude.ai/code) installiert
- Atlassian-MCP-Server verbunden (für die Confluence-Veröffentlichung)
**Optionale Tools** (zum Analysieren von Office-/PDF-Dokumenten):
 
```bash
brew install pandoc poppler
```
 
Ohne diese werden `.docx`-, `.pptx`- und `.pdf`-Dateien bei der Dokumentenanalyse übersprungen. Alle anderen Funktionen arbeiten auch ohne sie.
 
## Dieses Repository
 
Dieses Repo ist das **Claude-Code-Plugin** — es enthält den Skill, die Sub-Agents, Hooks und Templates.  
Claude Code lädt bei der Plugin-Installation alles automatisch. Siehe [CLAUDE.md](CLAUDE.md) für die Maintainer-Anleitung.
Das Plugin bringt Sicherheits-Hooks mit, die automatisch greifen:

- Bash-Befehle und Read-Zugriffe auf Credential-Dateien (z. B. `.env`) werden blockiert.
- `git push` und destruktive Operationen werden in geklonten Analyse-Repos (`/tmp/repo-analyzer-*`)
  unterbunden — dein lokales Arbeitsverzeichnis bleibt davon unberührt.

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
