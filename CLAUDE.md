# Solution Agent — Maintainer Guide

Dieses Repo ist ein **Claude Code Plugin** mit dem Namen `solution-agent`.  
Es wird über den Plugin-Mechanismus von Claude Code installiert — kein Bootstrap, kein manuelles Kopieren.

---

## Plugin-Struktur

```
solution-agent/
├── .claude-plugin/
│   ├── plugin.json          ← Manifest (Name, Version, Autor)
│   └── marketplace.json     ← Distribution via GitHub
├── skills/                  ← Skills (auto-discovered)
│   ├── document-project/
│   │   └── SKILL.md         ← Orchestrierungs-Skill
│   ├── document-status/
│   │   └── SKILL.md         ← Dokumentations-Status anzeigen
│   └── document-sync/
│       └── SKILL.md         ← Bestehende Confluence-Seite aktualisieren
├── agents/                  ← Sub-Agenten (auto-discovered)
│   ├── repo-analyzer.md
│   ├── diagram-analyzer.md
│   ├── document-analyzer.md
│   ├── confluence-publisher.md
│   ├── confluence-updater.md
│   ├── doc-reviewer.md
│   └── solution-researcher.md
├── hooks/                   ← Sicherheits-Hooks (auto-discovered)
│   ├── hooks.json           ← Hook-Registrierung mit ${CLAUDE_PLUGIN_ROOT}
│   ├── block-env-bash.sh
│   ├── block-env-read.sh
│   └── block-destructive-ops.sh
└── templates/
    └── confluence-template.md  ← Referenz; Inhalt ist in confluence-publisher.md eingebettet
```

---

## Wie das System funktioniert

```
Nutzer tippt /solution-agent:document-project
        │
        ▼
Skill: skills/document-project/SKILL.md
        │  Orchestriert die Analyse und fragt nach PUSH oder PULL
        ▼
Claude delegiert an den passenden Sub-Agenten (agents/)
```

**Claude Code lädt alle Bausteine automatisch** — kein Bootstrap, kein `git clone`, kein Kopieren nach `~/.claude/`.

---

## Inventar

### `agents/` — Sub-Agenten

| Datei | Zweck |
|---|---|
| `repo-analyzer.md` | Analysiert Git-Repos (lokal oder remote): Architektur, Tech-Stack, APIs, Git-Historie |
| `diagram-analyzer.md` | Analysiert Diagramme (PNG, JPG, SVG, draw.io, PlantUML, Mermaid) visuell |
| `document-analyzer.md` | Analysiert Textdokumente (PDF, DOCX, PPTX, TXT, RST, MD in Doku-Ordnern); nutzt pandoc/pdftotext falls installiert |
| `confluence-publisher.md` | Erstellt und publiziert Confluence-Seiten; Template ist direkt eingebettet |
| `confluence-updater.md` | Aktualisiert bestehende Confluence-Seiten idempotent |
| `doc-reviewer.md` | Validiert `dokumentation-preview.md` vor dem Publish |
| `solution-researcher.md` | Durchsucht Confluence nach Solution-Design-Seiten und liefert strukturierte Antworten |

### `skills/` — Skills

| Datei | Zweck |
|---|---|
| `document-project/SKILL.md` | Orchestriert Analyse und Confluence-Dokumentation (PUSH) oder Confluence-Recherche (PULL) |
| `document-status/SKILL.md` | Zeigt Analyse-Artefakte im aktuellen Verzeichnis |
| `document-sync/SKILL.md` | Aktualisiert bestehende Confluence-Seite (delegiert an `confluence-updater`) |

### `hooks/` — Sicherheits-Hooks

| Datei | Zweck |
|---|---|
| `hooks.json` | Registriert Hooks via `PreToolUse`; nutzt `${CLAUDE_PLUGIN_ROOT}` für Pfade |
| `block-env-bash.sh` | Blockiert Bash-Befehle, die Credential-Dateien lesen würden (global, alle Verzeichnisse) |
| `block-env-read.sh` | Blockiert Read-Tool-Zugriff auf Credential-Dateien (global); fail-closed mit jq/python3-Fallback |
| `block-destructive-ops.sh` | Blockiert `git push` und Destruktiv-Operationen **nur** in geklonten Analyse-Repos (`/tmp/repo-analyzer-*`) |

> **Sicherheitsmodell `block-destructive-ops.sh`:** Der Scope auf `/tmp/repo-analyzer-*` ist **bewusst**. Der Hook schützt ausschließlich geklonte Remote-Repos davor, dass ein Analyse-Agent versehentlich in ein fremdes Repository pusht oder Build-Befehle ausführt. Im lokalen Arbeitsverzeichnis des Nutzers (`cwd`) sind diese Operationen weiterhin erlaubt — der Nutzer gilt dort als vertrauenswürdig, und der normale Claude-Code-Berechtigungsdialog greift wie gewohnt.

### `templates/`

| Datei | Zweck |
|---|---|
| `confluence-template.md` | Referenz-Template — Inhalt ist direkt in `agents/confluence-publisher.md` eingebettet |

> **Wichtig:** Bei Template-Änderungen muss der eingebettete Block am Ende von `agents/confluence-publisher.md` synchron gehalten werden.

---

## Wartungsregeln

### Neuen Sub-Agenten hinzufügen
1. Agenten-Datei unter `agents/<name>.md` anlegen (Frontmatter: `name`, `description`)
2. Im Skill **Routing-Tabelle + Agentenliste aktualisieren** — sonst wird der Agent nie aufgerufen
3. Hier in der Tabelle oben eintragen

### Agenten oder SKILL.md ändern
Datei bearbeiten und committen → Claude Code lädt die neue Version beim nächsten Plugin-Update.

### Template ändern
1. `templates/confluence-template.md` bearbeiten
2. Den eingebetteten Template-Block am Ende von `agents/confluence-publisher.md` synchron halten

### Hooks ändern
`hooks/hooks.json` und die zugehörigen `.sh`-Dateien bearbeiten.  
`${CLAUDE_PLUGIN_ROOT}` zeigt zur Plugin-Installation — nie absolute `$HOME/.claude/`-Pfade verwenden.

Nach Änderungen an Hooks bitte mit `shellcheck` prüfen:
```bash
shellcheck hooks/*.sh
```
(`brew install shellcheck` falls nicht vorhanden.) Da Sicherheits-Hooks fail-closed sein sollen, ist statische Analyse hier besonders wichtig.

---

## Installation

```bash
# Marketplace hinzufügen (einmalig)
/plugin marketplace add lpetersdorf/doc_agent

# Plugin installieren
/plugin install solution-agent
```

## Zwei Nutzungs-Pfade

```
/solution-agent:document-project  →  PUSH: lokales Projekt (cwd) oder Remote-Repo → Confluence
/solution-agent:document-project  →  PULL: aus Confluence recherchieren (solution-researcher)
```

Beim Aufruf ohne Argument fragt der Skill explizit nach dem gewünschten Pfad.  
Lokaler Ordner (cwd) ist der Standard-Quellpfad für PUSH.

---

## Release-Prozess (Marketplace-SHA aktualisieren)

Nach jedem Commit der in die Produktion soll, muss die SHA in `.claude-plugin/marketplace.json` manuell auf den neuen Commit-Hash gesetzt werden. Nutzer, die das Plugin installiert haben, erhalten den neuen Stand erst nach `/plugin update solution-agent`.

**Schritt-für-Schritt:**

```bash
# 1. Änderungen committen und pushen
git push origin main

# 2. Neuen Commit-Hash ermitteln
git rev-parse HEAD

# 3. SHA in marketplace.json aktualisieren
# → .claude-plugin/marketplace.json → "sha": "<neuer-hash>"

# 4. SHA-Update committen
git add .claude-plugin/marketplace.json
git commit -m "chore: bump marketplace sha to <kurz-hash>"
git push origin main
```

> **Langfristig:** Alternativ eine Tag-Referenz (`"ref": "v0.2.0"`) statt Commit-SHA erwägen, sobald das Plugin-Format das unterstützt — dann entfällt das manuelle Bumpen.
