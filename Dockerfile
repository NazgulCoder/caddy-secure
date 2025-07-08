# ---------- builder ----------
FROM caddy:builder-alpine AS builder
RUN apk add --no-cache curl bash git

# Build Caddy with BasicAuth-TOTP (latest commit, no pin)
RUN xcaddy build \
      --with github.com/steffenbusch/caddy-basicauth-totp

# ---------- create Cloudflare matcher snippet -------------
RUN set -e; \
    mkdir -p /etc/caddy/snippets; \
    CIDRS="$(curl -sS https://www.cloudflare.com/ips-v4 https://www.cloudflare.com/ips-v6 | xargs)"; \
    printf '(cf_only) {\n    @from_cf remote_ip %s\n}\n' "$CIDRS" \
      > /etc/caddy/snippets/cf_only.caddy
      
# ---------- runtime ----------
FROM caddy:alpine
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
COPY --from=builder /etc/caddy/snippets/cf_only.caddy /etc/caddy/snippets/
COPY Caddyfile /etc/caddy/Caddyfile
VOLUME ["/data", "/config"]
EXPOSE 80 443
ENTRYPOINT ["caddy","run","--adapter","caddyfile","--config","/etc/caddy/Caddyfile"]
