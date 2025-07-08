# ---------- builder ----------
FROM caddy:builder-alpine AS builder
RUN apk add --no-cache curl bash git

# Build Caddy with one plugin only (BasicAuth-TOTP, latest commit)
RUN xcaddy build \
      --with github.com/steffenbusch/caddy-basicauth-totp

# Grab Cloudflare CIDRs and turn them into a snippet
RUN mkdir -p /etc/caddy/snippets && \
    curl -sS https://www.cloudflare.com/ips-v4 -o /tmp/cf4 && \
    curl -sS https://www.cloudflare.com/ips-v6 -o /tmp/cf6 && \
    { printf "(cf_only) {\n    @from_cf remote_ip"; cat /tmp/cf4 /tmp/cf6; \
      printf "\n}\n"; } | tr '\n' ' ' | sed 's/ $/\n/' \
      > /etc/caddy/snippets/cf_only.caddy && \
    rm /tmp/cf4 /tmp/cf6

# ---------- runtime ----------
FROM caddy:alpine
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
COPY --from=builder /etc/caddy/snippets/cf_only.caddy /etc/caddy/snippets/
COPY Caddyfile /etc/caddy/Caddyfile
VOLUME ["/data" "/config"]
EXPOSE 80 443
ENTRYPOINT ["caddy","run","--adapter","caddyfile","--config","/etc/caddy/Caddyfile"]
