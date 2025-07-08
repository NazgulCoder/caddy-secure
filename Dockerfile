# ---------- builder ----------
FROM caddy:builder-alpine AS builder
RUN apk add --no-cache curl bash git

# Build Caddy (latest BasicAuth-TOTP, no version pin)
RUN xcaddy build \
      --with github.com/steffenbusch/caddy-basicauth-totp

# ---------- create Cloudflare matcher snippet -------------
RUN mkdir -p /etc/caddy/snippets && \
    { \
      echo "(cf_only) {"; \
      echo "    @from_cf remote_ip"; \
      curl -sS https://www.cloudflare.com/ips-v4 https://www.cloudflare.com/ips-v6 | \
        while read cidr; do echo "        ${cidr}"; done; \
      echo "}"; \
    } > /etc/caddy/snippets/cf_only.caddy

# ---------- runtime ----------
FROM caddy:alpine
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
COPY --from=builder /etc/caddy/snippets/cf_only.caddy /etc/caddy/snippets/
COPY Caddyfile /etc/caddy/Caddyfile
VOLUME ["/data" "/config"]
EXPOSE 80 443
ENTRYPOINT ["caddy","run","--adapter","caddyfile","--config","/etc/caddy/Caddyfile"]
