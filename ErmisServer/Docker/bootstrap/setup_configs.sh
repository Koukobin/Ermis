#!/bin/bash
echo -e "=== Ermis Server Setup ===\n"

# Extract default configs - if missing or empty - from the image
if [ ! -d "./ermis-configs" ] || [ -z "$(ls ./ermis-configs 2>/dev/null)" ]; then
    echo "Extracting default configuration files..."

    if [ -z $ERMIS_SERVER_VERSION ]; then
        IMAGE_DECLARATION=$(cat docker-compose.yml | grep 'koukobin/ermis-server')
        ERMIS_SERVER_VERSION=$(echo "$IMAGE_DECLARATION" | cut -d: -f3)
    fi

    if [ -z $NGINX_VERSION ]; then
        IMAGE_DECLARATION=$(cat docker-compose.yml | grep 'image: nginx')
        NGINX_VERSION=$(echo "$IMAGE_DECLARATION" | cut -d: -f3)
    fi

    docker create --name ermis-temp koukobin/ermis-server:$ERMIS_SERVER_VERSION > /dev/null
    docker create --name nginx-temp nginx:$NGINX_VERSION > /dev/null

    rm -r ./ermis-configs 2> /dev/null
    docker cp ermis-temp:/etc/ermis-server/configs ./ermis-configs

    mkdir ./ermis-configs/nginx
    docker cp nginx-temp:/etc/nginx/nginx.conf ./ermis-configs/nginx
    docker cp nginx-temp:/etc/nginx/mime.types ./ermis-configs/nginx/mime.types
    docker cp ermis-temp:/etc/nginx/sites-enabled ./ermis-configs/nginx/conf.d
    docker cp ermis-temp:/etc/nginx/modules-enabled ./ermis-configs/nginx/modules-enabled
    sed -i '1i include /etc/nginx/modules-enabled/*.conf;' ./ermis-configs/nginx/nginx.conf

    docker rm nginx-temp > /dev/null
    docker rm ermis-temp > /dev/null

    echo -e "Configs extracted to ./ermis-configs\n"
fi

# Collect user settings
echo "=== Server Settings ==="
read -p "Email username   (Enter to skip): " EMAIL_USERNAME
read -p "PayPal client ID (Enter to skip): " PAYPAL_CLIENT_ID
read -p "Bitcoin address  (Enter to skip): " BITCOIN_ADDRESS
read -p "Monero  address  (Enter to skip): " MONERO_ADDRESS
echo ""

# Write settings into configs
echo "Writing configurations..."
sed -i "s|databaseAddress=.*|databaseAddress=postgres|" ./ermis-configs/database-settings/general-settings.cnf
find ./ermis-configs/nginx/ -type f -name "**" -exec sed -i "s|IP_ADDRESS|ermis-server|" {} +
find ./ermis-configs/nginx/ -type f -name "**" -exec sed -i "s|SERVER_PORT|5551|" {} +
find ./ermis-configs/nginx/ -type f -name "**" -exec sed -i "s|SSL_CERTIFICATE|/etc/ermis-server/certs/server_full.pem|" {} +
find ./ermis-configs/nginx/ -type f -name "**" -exec sed -i "s|SSL_CERTIFICATE_KEY|/etc/ermis-server/certs/server.key|" {} +
sed -i "s|key-store=.*|key-store=/etc/ermis-server/certs/keystore.jks|" ./ermis-configs/server-settings/ssl-settings.cnf
[ -s "${EMAIL_USERNAME}"   ] && sed -i "s|emailUsername=.*|emailUsername=${EMAIL_USERNAME}|" ./ermis-configs/emailer-settings/general-settings.cnf
[ -s "${PAYPAL_CLIENT_ID}" ] && sed -i "s|paypal-client-id=.*|paypal-client-id=${PAYPAL_CLIENT_ID}|" ./ermis-configs/donation-settings/general-settings.cnf
[ -s "${BITCOIN_ADDRESS}"  ] && sed -i "s|bitcon=.*|bitcon=${BITCOIN_ADDRESS}|" ./ermis-configs/donation-settings/general-settings.cnf
[ -s "${MONERO_ADDRESS}"   ] && sed -i "s|monero=.*|monero=${MONERO_ADDRESS}|" ./ermis-configs/donation-settings/general-settings.cnf

echo "Setup complete!"
echo "You can modify the configs any time at ./ermis-configs"

