#!/bin/bash
# Blocks Bash commands that access sensitive credential files.
# Allows .env.example / .env.sample / .env.template / .env.dist (safe variants).

input=$(cat)
cmd=$(echo "$input" | python3 -c "import sys, json; print(json.load(sys.stdin).get('tool_input', {}).get('command', ''))")

# Block .env files — but allow known-safe example/template variants
if echo "$cmd" | grep -qE '\.env'; then
  if ! echo "$cmd" | grep -qE '\.env\.(example|sample|template|dist|test)'; then
    echo "Blockiert: Bash-Kommandos duerfen nicht auf .env-Dateien zugreifen."
    exit 2
  fi
fi

# Block private key and certificate files
if echo "$cmd" | grep -qE '\.(pem|key|p12|pfx|keystore|jks)([[:space:]"'"'"'`]|$)'; then
  echo "Blockiert: Zugriff auf Zertifikat- und Schluessel-Dateien ist nicht erlaubt."
  exit 2
fi

# Block SSH private keys
if echo "$cmd" | grep -qE '(id_rsa|id_dsa|id_ed25519|id_ecdsa)([[:space:]"'"'"'`]|$)'; then
  echo "Blockiert: Zugriff auf SSH-Schluessel-Dateien ist nicht erlaubt."
  exit 2
fi

# Block cloud credential files
if echo "$cmd" | grep -qE '(\.aws/credentials|credentials\.json|service_account\.json)'; then
  echo "Blockiert: Zugriff auf Cloud-Credential-Dateien ist nicht erlaubt."
  exit 2
fi

# Block package registry credential files
if echo "$cmd" | grep -qE '\.(npmrc|pypirc)([[:space:]"'"'"'`]|$)'; then
  echo "Blockiert: Zugriff auf Package-Registry-Credentials ist nicht erlaubt."
  exit 2
fi
