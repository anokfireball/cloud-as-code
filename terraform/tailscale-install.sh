#!/bin/bash

curl -fsSL https://tailscale.com/install.sh | sh
tailscale up --authkey=${tailscale_auth_key} --accept-dns=false --accept-routes=true --reset
systemctl enable tailscaled
