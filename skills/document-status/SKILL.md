---
name: document-status
description: "Zeigt vorhandene Analyse-Artefakte und Dokumentations-Vorschau im aktuellen Verzeichnis"
---

Scanne das aktuelle Arbeitsverzeichnis nach Dokumentations-Artefakten und zeige eine kompakte Übersicht.

## Was zu prüfen ist

```bash
# Vorhandene Analyse-Reports
for f in repo-analysis.md diagram-analysis.md document-analysis.md dokumentation-preview.md; do
  if [ -f "$f" ]; then
    lines=$(wc -l < "$f")
    modified=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$f" 2>/dev/null || stat --format="%y" "$f" 2>/dev/null | cut -d. -f1)
    echo "✅ $f — $lines Zeilen — zuletzt geändert: $modified"
  else
    echo "❌ $f — nicht vorhanden"
  fi
done

# Offene Prüfpunkte in der Preview
if [ -f "dokumentation-preview.md" ]; then
  count=$(grep -c "Bitte pruefen\|Bitte prüfen\|⚠️" dokumentation-preview.md 2>/dev/null); count=${count:-0}
  echo ""
  echo "⚠️  Offene Prüfpunkte in Preview: $count"
fi
```

## Ausgabe-Format

Zeige die Ergebnisse in diesem Format:

```
📁 Dokumentations-Status: <aktuelles Verzeichnis>
─────────────────────────────────────────────

Analyse-Reports:
  ✅/❌ repo-analysis.md       [X Zeilen | YYYY-MM-DD HH:MM]
  ✅/❌ diagram-analysis.md    [X Zeilen | YYYY-MM-DD HH:MM]
  ✅/❌ document-analysis.md   [X Zeilen | YYYY-MM-DD HH:MM]

Dokumentation:
  ✅/❌ dokumentation-preview.md [X Zeilen | YYYY-MM-DD HH:MM]
     ⚠️  Offene Prüfpunkte: [Anzahl]

─────────────────────────────────────────────
Nächste Schritte:
  [Kontext-abhängige Empfehlung — z.B. "/solution-agent:document-project" zum Erstellen, "/solution-agent:document-sync" zum Update]
```

## Nächste-Schritte-Logik

| Situation | Empfehlung |
|---|---|
| Keine Dateien vorhanden | Führe `/solution-agent:document-project` aus, um die Dokumentation zu starten |
| Nur Analyse-Reports, keine Preview | Führe `/solution-agent:document-project` aus — die Preview fehlt noch |
| Preview vorhanden, frisch (< 1 Tag) | Bereit für `/solution-agent:document-sync` oder Confluence-Publish |
| Preview vorhanden, älter als 7 Tage | Erwäge eine neue Analyse mit `/solution-agent:document-project` |
| Offene Prüfpunkte > 0 | Preview vor Publish manuell prüfen oder `/solution-agent:document-project` mit Fokus auf `doc-reviewer` starten |
