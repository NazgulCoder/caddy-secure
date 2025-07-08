# ---------- builder ----------
FROM caddy:builder-alpine AS builder

#  pull Coraza, Salmi WAF, TOTP, Cloudflare-IP
RUN xcaddy build \
      --with github.com/corazawaf/coraza-caddy@latest \
      --with github.com/fabriziosalmi/caddy-waf@latest \
      --with github.com/steffenbusch/caddy-basicauth-totp@latest \
      --with github.com/WeidiDeng/caddy-cloudflare-ip/v2@latest

#  Copy OWASP CRS into the image (v4.0.0 today)
ADD https://github.com/coreruleset/coreruleset/archive/refs/tags/v4.0.0.tar.gz /tmp/crs.tar.gz
RUN mkdir -p /opt/owasp_crs && \
    tar -xf /tmp/crs.tar.gz --strip-components=1 -C /opt/owasp_crs && \
    rm /tmp/crs.tar.gz

# ---------- runtime ----------
FROM caddy:alpine
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
COPY Caddyfile /etc/caddy/Caddyfile
COPY --from=builder /opt/owasp_crs /opt/owasp_crs    # CRS rules
VOLUME ["/data", "/config"]
EXPOSE 80 443
ENTRYPOINT ["caddy","run","--adapter","caddyfile","--config","/etc/caddy/Caddyfile"]
