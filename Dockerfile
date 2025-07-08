# ---------- builder ----------
FROM caddy:builder-alpine AS builder
RUN apk add --no-cache git wget

# Clone the WAF repo (1 depth = faster)
RUN git clone --depth 1 https://github.com/fabriziosalmi/caddy-waf /wafsrc

# Build Caddy with three plugins:
#   • Salmi WAF  • BasicAuth-TOTP  • Cloudflare-IP
RUN xcaddy build \
      --with github.com/fabriziosalmi/caddy-waf=/wafsrc \
      --with github.com/steffenbusch/caddy-basicauth-totp \
      --with github.com/WeidiDeng/caddy-cloudflare-ip/v2

# Grab the GeoLite2 Country DB (for GeoIP rules)
RUN mkdir -p /opt/geoip     \
 && wget -qO /opt/geoip/GeoLite2-Country.mmdb \
      https://git.io/GeoLite2-Country.mmdb

# ---------- runtime ----------
FROM caddy:alpine
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
COPY --from=builder /opt/geoip /opt/geoip                # GeoIP DB
COPY Caddyfile       /etc/caddy/Caddyfile
COPY rules.json      /etc/caddy/waf/rules.json           # sample rules
VOLUME ["/data", "/config"]
EXPOSE 80 443
ENTRYPOINT ["caddy","run","--adapter","caddyfile","--config","/etc/caddy/Caddyfile"]
