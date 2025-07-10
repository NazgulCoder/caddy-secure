# caddy-secure 🚀🔒

A custom Docker build for a **hardened, flexible, and secure** Caddy web server.

## Overview 🌟

**caddy-secure** is a Docker image based on Caddy, enhanced with modern security and authentication features.  
Originally built for personal use, this project is open to suggestions and contributions! If you have ideas or need a hassle-free, fully functional Caddyfile, feel free to reach out—I'm happy to help expand and improve it.

## Features ✨

- **Caddy v2**: A modern, fast, and extensible web server.
- **BasicAuth-TOTP Plugin**: Adds two-factor authentication (TOTP) to HTTP Basic Auth for admin endpoints.
- **Cloudflare Trusted Proxy Snippet**: Automatically generates a Caddy snippet with up-to-date Cloudflare IP ranges, making it easy to restrict access or set up trusted proxies.
- **Block Bad IPs**: Automatically Block Bad IPs from Maltrail IP List.
- **Multi-Stage Build**: Keeps the final Docker image minimal and secure.
- **Customizable**: Mount your own `Caddyfile` and use the included Cloudflare snippet for advanced configurations.

## Quick Start 💻
To start using **caddy-secure** you can build the image by yourself or you can use my pre-made image with this simple code.
```
$ docker pull ghcr.io/nazgulcoder/caddy-secure:latest
```

The persistant volumes you need to map are like vanilla Caddy:
- **/etc/caddy/Caddyfile**
- **/data**
- **/config**

Additionally, you can map the **totp-secrets.json**. If you use my Caddyfile as example, just map **/data/totp-secrets.json**.

If you want to use my custom Block Bad IPs you need to map also in the container **/etc/caddy/snippets/deny_ips.caddy**, on the host if you don't touch anything bind it read-only **/opt/Caddy/deny_ips.caddy**

If you want to use my custom block bad IPs with Cloudflare, you need to set a Cronjob at **caddy-ipsum-blocklist.sh**. If you don't use Cloudflare it is recommended to use IPTables and therefore use **update-ipsum-blocklist.sh**

Why not implement it automatically in the Dockerfile like Cloudflare IP List? Simple, Cloudflare IP list rarely changes, while Maltrail IP list changes daily, it is definitely better to automatic update the IP list only, and not the entire container, then pre-load the list on Caddy by restarting it. If you want to use other lists feel free to do so, just remember to restart Caddy service (NO HOTSWAP).

## Roadmap 🛣️

Here’s what’s planned for future releases:

- [x] **BasicAuth-TOTP support** for 2FA on admin endpoints
- [x] **Cloudflare IP snippet** custom auto-generation
- [x] **Multi-stage Docker build** for a minimal image
- [x] **Block Bad IPs** with daily Cronjob
- [ ] **Crowdsec** for security
- [ ] **WAF** for security
- [ ] **More plugins** (suggest your favorites!)
- [ ] **Automated tests** and CI/CD integration

## Functional Caddyfile Sample 📄

A ready-to-use, secure [Caddyfile](https://raw.githubusercontent.com/NazgulCoder/caddy-secure/refs/heads/main/Caddyfile) reference to start building your own configuration. This includes many examples with tested configurations for many use cases and applications (e.g. UniFi Network Controller etc.)


## Get Involved 🤝

Have a feature request or want to contribute?  
Open an issue or submit a pull request—collaboration is welcome!

Enjoy a secure and modern Caddy experience with **caddy-secure**!
