#!/bin/sh

export HOST_IP=$(ip -4 route list match 0/0 | awk '{print $3}')
echo "[global]" > /root/conduit.toml
echo "server_name = \"${TOR_ADDRESS}\"" >> /root/conduit.toml
echo "database_path = \"/root/conduit_db\"" >> /root/conduit.toml
echo "port = 6167" >> /root/conduit.toml
echo "max_request_size = 20_000_000" >> /root/conduit.toml
echo "allow_registration = true" >> /root/conduit.toml
echo "allow_encryption = true" >> /root/conduit.toml
echo "allow_federation = true" >> /root/conduit.toml
echo "address = \"127.0.0.1\"" >> /root/conduit.toml
export CONDUIT_CONFIG="conduit.toml"
exec tini conduit

