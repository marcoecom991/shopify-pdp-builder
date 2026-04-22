#!/usr/bin/env bash
# setup-store.sh — Helper interattivo per creare il file .env di uno store Shopify.
#
# Uso:
#   ./scripts/setup-store.sh
#
# Lo script:
#   1. Chiede il path del workdir dello store (es. ~/Desktop/Shopify-Stores/Nimea/workdir).
#   2. Chiede il Theme Access token (shptka_...).
#   3. Chiede l'handle store (<handle>.myshopify.com).
#   4. Scrive <workdir>/.env con le variabili corrette.
#   5. Testa la connessione con `npx @shopify/cli theme list`.
#
# Il file .env NON viene mai committato (è nel workdir store, fuori dal plugin).

set -euo pipefail

echo "=== Shopify PDP Builder — Setup Store ==="
echo

read -r -p "Path del workdir store (es. /Users/me/Desktop/Shopify-Stores/Nimea/workdir): " WORKDIR
WORKDIR="${WORKDIR/#\~/$HOME}"

if [ ! -d "$WORKDIR" ]; then
  echo "⚠️  La cartella '$WORKDIR' non esiste. La creo ora."
  mkdir -p "$WORKDIR"
fi

ENV_FILE="$WORKDIR/.env"

if [ -f "$ENV_FILE" ]; then
  read -r -p "Esiste già un .env in $WORKDIR. Sovrascrivere? [y/N] " OVERWRITE
  if [[ ! "$OVERWRITE" =~ ^[Yy]$ ]]; then
    echo "Annullato."
    exit 0
  fi
fi

echo
echo "Theme Access token — generalo da Shopify Admin → Apps → Theme Access → Create password."
read -r -s -p "SHOPIFY_CLI_THEME_TOKEN (inizia con shptka_): " TOKEN
echo

if [[ ! "$TOKEN" =~ ^shptka_ ]]; then
  echo "⚠️  Il token dovrebbe iniziare con 'shptka_'. Procedo comunque."
fi

read -r -p "Handle store (es. qncxve-5r.myshopify.com): " STORE

cat > "$ENV_FILE" <<EOF
SHOPIFY_CLI_THEME_TOKEN=$TOKEN
SHOPIFY_FLAG_STORE=$STORE
EOF

chmod 600 "$ENV_FILE"

echo
echo "✅ Scritto $ENV_FILE (permessi 600)."
echo

read -r -p "Testare la connessione ora con 'theme list'? [Y/n] " DOTEST
if [[ ! "$DOTEST" =~ ^[Nn]$ ]]; then
  echo
  echo "→ Eseguo: npx @shopify/cli@latest theme list --no-color"
  (
    cd "$WORKDIR"
    set -a
    # shellcheck disable=SC1090
    source "$ENV_FILE"
    set +a
    npx @shopify/cli@latest theme list --no-color
  )
fi

echo
echo "Done. Aggiungi ora il path workdir in config/stores.json del plugin."
