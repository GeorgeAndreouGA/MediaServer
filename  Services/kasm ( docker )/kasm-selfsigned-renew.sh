#!/bin/bash

openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout /opt/kasm/current/certs/kasm_nginx.key \
  -out /opt/kasm/current/certs/kasm_nginx.crt \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=your.domain.com"

docker ps -q --filter "name=kasm" | xargs docker restart
