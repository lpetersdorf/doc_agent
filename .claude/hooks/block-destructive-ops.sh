#!/bin/bash
# Blocks destructive git operations and build commands within cloned analysis repos.
# Applies only when commands target /tmp/repo-analyzer-* directories.
# git push is blocked globally — analysis agents must never push to remotes.

input=$(cat)
cmd=$(echo "$input" | python3 -c "import sys, json; print(json.load(sys.stdin).get('tool_input', {}).get('command', ''))")

# Block git push globally — analysis workflows never push
if echo "$cmd" | grep -qE '\bgit\b.*\bpush\b'; then
  echo "Blockiert: git push ist in Analyse-Workflows nicht erlaubt."
  exit 2
fi

# All remaining checks apply only when targeting cloned repo directories
if ! echo "$cmd" | grep -qE '/tmp/repo-analyzer-'; then
  exit 0
fi

# Block build and install commands inside cloned repos
if echo "$cmd" | grep -qE '\b(npm\s+(install|ci|run\s+build|build)|yarn\s+(install|build)|pip\s+install|mvn\s+(install|package|build)|gradle\s+build|docker\s+build|docker-compose\s+up|poetry\s+install|bundle\s+install)\b'; then
  echo "Blockiert: Build- und Install-Befehle in geklonten Analyse-Repos sind nicht erlaubt (nur statische Analyse)."
  exit 2
fi

# Block executing scripts directly from a cloned repo
if echo "$cmd" | grep -qE '/tmp/repo-analyzer-[^[:space:]]*/.*\.(sh|py|rb|pl|js)\b'; then
  echo "Blockiert: Ausfuehren von Skripten aus geklonten Repos ist nicht erlaubt."
  exit 2
fi

# Block destructive git operations within cloned repos
if echo "$cmd" | grep -qE '\bgit\b.*(reset\s+--hard|clean\s+-[a-zA-Z]*f|branch\s+-[Dd]\b)'; then
  echo "Blockiert: Destruktive Git-Operationen (reset --hard, clean -f, branch -D) sind nicht erlaubt."
  exit 2
fi
