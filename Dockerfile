# ---------- builder ----------
FROM caddy:builder-alpine AS builder
RUN xcaddy build \
      --with github.com/greenpau/caddy-security \
      --with github.com/corazawaf/coraza-caddy \
      --with github.com/steffenbusch/caddy-basicauth-totp \
      --with github.com/WeidiDeng/caddy-cloudflare-ip
# `xcaddy` pulls the most-recent Caddy release and HEAD of every plugin ﻿:contentReference[oaicite:0]{index=0}

# ---------- runtime ----------
FROM caddy:alpine
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
COPY Caddyfile /etc/caddy/Caddyfile
VOLUME ["/data", "/config"]
EXPOSE 80 443
ENTRYPOINT ["caddy","run","--adapter","caddyfile","--config","/etc/caddy/Caddyfile"]
