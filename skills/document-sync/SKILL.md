---
name: document-sync
description: "Aktualisiert eine bestehende Confluence-Seite mit der vorhandenen dokumentation-preview.md — ohne Duplikat zu erstellen"
---

Dieser Skill aktualisiert eine bestehende Confluence-Seite idempotent. Er liest die vorhandene `dokumentation-preview.md` und delegiert an den `confluence-updater`-Agenten.

## Ablauf

### Schritt 1: Voraussetzungen prüfen

```bash
# Preview-Datei vorhanden?
[ -f "dokumentation-preview.md" ] && echo "OK" || echo "FEHLT"

# Aktuelle Confluence-Zieldaten aus der Preview ableiten (erste H1 = Seitentitel)
head -5 dokumentation-preview.md | grep "^# " | head -1 | sed 's/^# //'
```

Falls `dokumentation-preview.md` fehlt:
> "Keine `dokumentation-preview.md` gefunden. Führe zuerst `/solution-agent:document-project` aus, um eine Analyse und Vorschau zu erstellen."

### Schritt 2: Confluence-Zieldaten klären

Falls `$ARGUMENTS` einen Space Key oder Seitentitel enthält, verwende diese direkt.

Andernfalls, falls noch nicht bekannt, stelle **eine** kompakte Frage:

> "Für den Sync benötige ich:
> 1. **Space Key** (z.B. `PROJ`, `ARCH`) — in welchem Confluence-Space liegt die Seite?
> 2. **Seitentitel** — wie heißt die bestehende Seite? (Vorschlag aus Preview: `[abgeleiteter Titel]`)"

### Schritt 3: Qualitäts-Check via doc-reviewer

Bevor der Update-Agent startet, rufe den `doc-reviewer`-Agenten auf. Er prüft `dokumentation-preview.md` vollständig und gibt eine der drei Empfehlungen zurück:

- `🟢 GO` → weiter mit Schritt 4
- `🟡 WARN` → Nutzer informieren und fragen, ob trotzdem synchronisiert werden soll
- `🔴 STOP` → **nicht synchronisieren**, Nutzer auf das Problem hinweisen (insbesondere bei möglichen Secrets)

Warte auf das Ergebnis des `doc-reviewer`, bevor du mit Schritt 4 fortfährst.

### Schritt 4: confluence-updater starten

Delegiere an den `confluence-updater`-Agenten mit folgendem Kontext:
- `confluence_space`: aus Schritt 2
- `confluence_title`: aus Schritt 2
- Vorhandene `dokumentation-preview.md` als Quelle

Der `confluence-updater` sucht selbständig nach der bestehenden Seite und aktualisiert sie. Falls keine Seite gefunden wird, erstellt er eine neue.

---

Nutzeranfrage: $ARGUMENTS
