#!/bin/bash
# Blocks Bash commands that access .env files

input=$(cat)
cmd=$(echo "$input" | python3 -c "import sys, json; print(json.load(sys.stdin).get('tool_input', {}).get('command', ''))")

if echo "$cmd" | grep -qE '(\.env)(\.[^/[:space:]]*)?([ '"'"'"`]|$)'; then
  echo "Blockiert: Bash-Kommandos duerfen nicht auf .env-Dateien zugreifen."
  exit 2
fi
