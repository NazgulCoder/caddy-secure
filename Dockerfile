# ---------- builder ----------
FROM caddy:builder-alpine AS builder
RUN apk add --no-cache curl bash git

# Build Caddy with BasicAuth-TOTP (latest commit, no pin)
RUN xcaddy build \
      --with github.com/steffenbusch/caddy-basicauth-totp

# ---------- create Cloudflare snippets -------------
RUN set -e; \
mkdir -p /etc/caddy/snippets; \
curl -sS https://www.cloudflare.com/ips-v4 -o /tmp/cf4; \
curl -sS https://www.cloudflare.com/ips-v6 -o /tmp/cf6; \
\
# Create cf_only.caddy snippet (existing) \
{ \
printf '(cf_only) {\n @from_cf remote_ip '; \
cat /tmp/cf4 | tr '\n' ' '; \
printf ' '; \
cat /tmp/cf6 | tr '\n' ' '; \
printf '\n}\n'; \
} > /etc/caddy/snippets/cf_only.caddy; \
\
# Create trusted_proxies.caddy snippet (new) \
{ \
printf 'trusted_proxies static '; \
cat /tmp/cf4 | tr '\n' ' '; \
printf ' '; \
cat /tmp/cf6 | tr '\n' ' '; \
printf '\n'; \
} > /etc/caddy/snippets/trusted_proxies.caddy; \
\
rm /tmp/cf4 /tmp/cf6
      
# ---------- runtime ----------
FROM caddy:alpine
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
COPY --from=builder /etc/caddy/snippets/cf_only.caddy /etc/caddy/snippets/
COPY --from=builder /etc/caddy/snippets/trusted_proxies.caddy /etc/caddy/snippets/
COPY Caddyfile /etc/caddy/Caddyfile
VOLUME ["/data", "/config"]
EXPOSE 80 443
ENTRYPOINT ["caddy","run","--adapter","caddyfile","--config","/etc/caddy/Caddyfile"]
