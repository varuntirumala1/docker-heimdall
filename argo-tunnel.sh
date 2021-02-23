#!/bin/bash
cloudflared --origincert /config/cert.pem --config /config/config.yml tunnel run -p http2 heimdall
