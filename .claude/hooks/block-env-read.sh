#!/bin/bash
# Blocks the Read tool from accessing .env files

input=$(cat)
path=$(echo "$input" | python3 -c "import sys, json; print(json.load(sys.stdin).get('tool_input', {}).get('file_path', ''))")
filename=$(basename "$path")

if [[ "$filename" == ".env" || "$filename" == .env.* ]]; then
  echo "Blockiert: .env-Dateien enthalten Secrets und duerfen nicht gelesen werden."
  exit 2
fi
