#!/bin/bash
# Blocks the Read tool from accessing sensitive credential files.
# Allows .env.example / .env.sample / .env.template / .env.dist (safe variants).

input=$(cat)
path=$(echo "$input" | python3 -c "import sys, json; print(json.load(sys.stdin).get('tool_input', {}).get('file_path', ''))")
filename=$(basename "$path")

# Block .env — but allow known-safe example/template variants
if [[ "$filename" == ".env" ]]; then
  echo "Blockiert: .env-Dateien enthalten Secrets und duerfen nicht gelesen werden."
  exit 2
fi
if [[ "$filename" == .env.* ]]; then
  case "$filename" in
    .env.example|.env.sample|.env.template|.env.dist|.env.test)
      ;;  # safe variants — allow
    *)
      echo "Blockiert: .env-Varianten (ausser .env.example/.sample/.template/.dist) koennen Secrets enthalten."
      exit 2
      ;;
  esac
fi

# Block private key and certificate files
case "$filename" in
  *.pem|*.key|*.p12|*.pfx|*.keystore|*.jks)
    echo "Blockiert: Zertifikat- und Schluessel-Dateien duerfen nicht gelesen werden."
    exit 2
    ;;
esac

# Block SSH private keys
case "$filename" in
  id_rsa|id_dsa|id_ed25519|id_ecdsa)
    echo "Blockiert: SSH-Schluessel-Dateien duerfen nicht gelesen werden."
    exit 2
    ;;
esac

# Block cloud credentials and registry files
case "$filename" in
  credentials.json|service_account.json|.npmrc|.pypirc)
    echo "Blockiert: Credential-Dateien duerfen nicht gelesen werden."
    exit 2
    ;;
esac
