# ---------- builder ----------
FROM caddy:builder-alpine AS builder
RUN xcaddy build \
      --with github.com/steffenbusch/caddy-basicauth-totp \
      --with github.com/WeidiDeng/caddy-cloudflare-ip/v2

# ---------- runtime ----------
FROM caddy:alpine
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
COPY Caddyfile /etc/caddy/Caddyfile
VOLUME ["/data", "/config"]
EXPOSE 80 443
ENTRYPOINT ["caddy","run","--adapter","caddyfile","--config","/etc/caddy/Caddyfile"]
