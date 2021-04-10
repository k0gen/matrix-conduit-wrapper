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

cat <<EOT >> /etc/nginx/nginx.conf

server {
    listen 443;
    listen 8448;
EOT
echo "    server_name ${TOR_ADDRESS};" >> /etc/nginx/nginx.conf
cat <<EOT >> /etc/nginx/nginx.conf

    location /_matrix/ {
        proxy_pass http://localhost:6167/_matrix/;
    }
}
EOT

export CONDUIT_CONFIG="conduit.toml"
exec tini conduit

