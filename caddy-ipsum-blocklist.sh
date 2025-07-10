#!/usr/bin/env bash
# ────────────────────────────────────────────────────────────────
#  Fetch IPsum, build a (block_ips) snippet that blocks unwanted
#  clients, save it to /opt/Caddy/deny_ips.caddy, restart the
#  container "Caddy-Secure".
# ────────────────────────────────────────────────────────────────
set -euo pipefail

URL="https://raw.githubusercontent.com/stamparm/ipsum/refs/heads/master/ipsum.txt"
DEST_SNIPPET="/opt/Caddy/deny_ips.caddy"

TMP_FEED="$(mktemp)"
TMP_SNIP="$(mktemp)"

curl -sSL "$URL" -o "$TMP_FEED"

{
  printf "# Auto-generated on %s UTC\n" "$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
  printf "(block_ips) {\n"
  printf "    @block_ips client_ip"
  awk '($1 !~ /^#/ && $1 != "") { printf " %s", $1 }' "$TMP_FEED"
  printf "\n"
  printf "    handle @block_ips {\n"
  printf "        respond 403\n"
  printf "    }\n"
  printf "}\n"
} > "$TMP_SNIP"

install -m 0644 "$TMP_SNIP" "$DEST_SNIPPET"
docker restart Caddy-Secure

rm -f "$TMP_FEED" "$TMP_SNIP"
