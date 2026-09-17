#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  exec sudo "$0" "$@"
fi

FILE="/etc/pam.d/sudo_local"
TEMPLATE="/etc/pam.d/sudo_local.template"

if [[ ! -f "$FILE" ]]; then
  if [[ -f "$TEMPLATE" ]]; then
    cp "$TEMPLATE" "$FILE"
  else
    touch "$FILE"
  fi
fi

if grep -qE '^[[:space:]]*auth[[:space:]]+sufficient[[:space:]]+pam_tid\.so' "$FILE"; then
  sed -i '' -E 's/^[[:space:]]*auth([[:space:]]+sufficient[[:space:]]+pam_tid\.so)/#auth\1/' "$FILE"
  echo "Touch ID for sudo: DISABLED"
elif grep -qE 'pam_tid\.so' "$FILE"; then
  sed -i '' -E 's/^[[:space:]]*#?[[:space:]]*auth([[:space:]]+sufficient[[:space:]]+pam_tid\.so)/auth\1/' "$FILE"
  echo "Touch ID for sudo: ENABLED"
else
  echo "auth       sufficient     pam_tid.so" >>"$FILE"
  echo "Touch ID for sudo: ENABLED"
fi
