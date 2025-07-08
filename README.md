# caddy-secure 🚀🔒

A custom Docker build for a **hardened, flexible, and secure** Caddy web server.

## Overview 🌟

**caddy-secure** is a Docker image based on Caddy, enhanced with modern security and authentication features.  
Originally built for personal use, this project is open to suggestions and contributions! If you have ideas or need a hassle-free, fully functional Caddyfile, feel free to reach out—I'm happy to help expand and improve it.

## Features ✨

- **Caddy v2**: A modern, fast, and extensible web server.
- **BasicAuth-TOTP Plugin**: Adds two-factor authentication (TOTP) to HTTP Basic Auth for admin endpoints.
- **Cloudflare Trusted Proxy Snippet**: Automatically generates a Caddy snippet with up-to-date Cloudflare IP ranges, making it easy to restrict access or set up trusted proxies.
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

Additionally, you can map the **totp-secrets.json**. If you use my Caddyfile as example, just map **/data/totp-secrets.json**

## Roadmap 🛣️

Here’s what’s planned for future releases:

- [x] **BasicAuth-TOTP support** for 2FA on admin endpoints
- [x] **Cloudflare IP snippet** custom auto-generation
- [x] **Multi-stage Docker build** for a minimal image
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
