# Solution Agent — Maintainer Guide

Dieses Repo ist der **Content-Store** für den shareable Claude Skill `document-project`.  
Er wird nicht direkt genutzt — der Skill klont/pullt dieses Repo beim ersten Aufruf und kopiert die Bausteine nach `~/.claude/`.

---

## Wie das System funktioniert

```
Nutzer tippt /document in Claude Code
        │
        ▼
Skill: document-project (shareable Claude Skill)
        │  Setup-Check: klont/pullt dieses Repo → ~/.solution_agent
        │  kopiert: agents/ · hooks/ · templates/ · settings.json → ~/.claude/
        ▼
Claude delegiert an den passenden Sub-Agenten
```

**Die Orchestrierungslogik lebt ausschließlich im Skill.** Dieses Repo liefert nur die Bausteine.

---

## Inventar

### `.claude/agents/` — Sub-Agenten

| Datei | Zweck |
|---|---|
| `repo-analyzer.md` | Analysiert Git-Repos (lokal oder remote): Architektur, Tech-Stack, APIs, Git-Historie |
| `diagram-analyzer.md` | Analysiert Diagramme (PNG, JPG, SVG, draw.io, PlantUML, Mermaid) visuell |
| `document-analyzer.md` | Analysiert Textdokumente (PDF, DOCX, PPTX, TXT, RST, MD in Doku-Ordnern); nutzt pandoc/pdftotext falls installiert |
| `confluence-publisher.md` | Erstellt und publiziert Confluence-Seiten; nutzt `confluence-template.md` als Grundstruktur |
| `solution-researcher.md` | Durchsucht Confluence nach Solution-Design-Seiten und liefert strukturierte Antworten |

### `.claude/hooks/` — Sicherheits-Hooks

| Datei | Zweck |
|---|---|
| `block-env-bash.sh` | Blockiert Bash-Befehle, die `.env`-Dateien lesen würden |
| `block-env-read.sh` | Blockiert Read-Tool-Zugriff auf `.env`-Dateien |

Hooks werden via `PreToolUse` in `settings.json` registriert. Pfade sind absolut (`$HOME/.claude/hooks/…`).

### `.claude/templates/`

| Datei | Zweck |
|---|---|
| `confluence-template.md` | Seitenstruktur-Vorlage für den `confluence-publisher` |

---

## Wartungsregeln

### Neuen Sub-Agenten hinzufügen
1. Agenten-Datei unter `.claude/agents/<name>.md` anlegen (Frontmatter: `name`, `description`)
2. Im Skill **Routing-Tabelle + Agentenliste aktualisieren** — sonst wird der Agent nie aufgerufen
3. Hier in der Tabelle oben eintragen

### Agenten oder Template ändern
Datei bearbeiten und committen → beim nächsten `/document`-Aufruf zieht der Skill die neue Version via `git pull`.

### Settings/Hooks ändern
`settings.json` wird vom Skill **nur kopiert, wenn `~/.claude/settings.json` noch nicht existiert**.  
Änderungen an Hooks greifen bei bestehenden Installationen erst nach manuellem Merge.  
Langfristig sollte der Skill-Bootstrap ein Merge statt Copy-if-absent implementieren.

---

## Zwei Nutzungs-Pfade

```
/document  →  PUSH: lokales Projekt (cwd) oder Remote-Repo dokumentieren → Confluence
/document  →  PULL: aus Confluence recherchieren (solution-researcher)
```

Beim Aufruf ohne Argument fragt der Skill explizit nach dem gewünschten Pfad.  
Lokaler Ordner (cwd) ist der Standard-Quellpfad für PUSH.
