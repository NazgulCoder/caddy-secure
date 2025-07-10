#!/usr/bin/env bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
#
# Refresh the IPsum feed into an ipset and be sure every packet whose
# SOURCE address is in that set is dropped both:
#   • before Docker’s FORWARD rules        (DOCKER-USER chain)
#   • before any host-service rules        (INPUT chain)
#
# Tested on Debian 12 (iptables-nft + ipset 7.x)

set -euo pipefail

FEED_URL="https://raw.githubusercontent.com/stamparm/ipsum/refs/heads/master/ipsum.txt"
SET_NAME="ipsum_blocklist"

TMP_FEED="$(mktemp)"
curl -fsSL "$FEED_URL" -o "$TMP_FEED"

# ------------------------------------------------------------------------------
# 1. Create the ipset if it does not exist (big ceiling so we never overflow)
# ------------------------------------------------------------------------------
if ! ipset list -n | grep -qx "$SET_NAME"; then
  ipset create "$SET_NAME" hash:ip family inet hashsize 65536 maxelem 1048576
fi

# ------------------------------------------------------------------------------
# 2. Atomically flush + reload the set from today’s feed
# ------------------------------------------------------------------------------
TMP_RESTORE="$(mktemp)"
{
  echo "flush $SET_NAME"
  grep -Eo '^[0-9]{1,3}(\.[0-9]{1,3}){3}' "$TMP_FEED" | while read -r IP; do
    echo "add $SET_NAME $IP"
  done
} > "$TMP_RESTORE"

ipset restore < "$TMP_RESTORE"

rm -f "$TMP_FEED" "$TMP_RESTORE"

# ------------------------------------------------------------------------------
# 3. Ensure the DOCKER-USER chain exists and drop the set (container traffic)
# ------------------------------------------------------------------------------
iptables -t filter -N DOCKER-USER 2>/dev/null || true
iptables -C DOCKER-USER -m set --match-set "$SET_NAME" src -j DROP 2>/dev/null || \
  iptables -I DOCKER-USER 1 -m set --match-set "$SET_NAME" src -j DROP

# ------------------------------------------------------------------------------
# 4. ALSO drop the set in the INPUT chain (host services: SSH, Webmin, …)
# ------------------------------------------------------------------------------
iptables -C INPUT -m set --match-set "$SET_NAME" src -j DROP 2>/dev/null || \
  iptables -I INPUT 1 -m set --match-set "$SET_NAME" src -j DROP

exit 0
