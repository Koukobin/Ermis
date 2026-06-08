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
    docker cp ermis-temp:/var/ermis-server/ ./web_assets

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

echo "=== Select the IP to inject into HTML: ==="
echo "This won't impact any server functionality, it will simply be how the server shows up on the web page"

# Fetch local IPs from network interfaces (filter out interfaces that don't have an IP assigned)
mapfile -t local_options < <(ip -brief addr show | awk '/UP|UNKNOWN/ {print $1 " (" $3 ")"}')

# Fetch public IP (with a 3-second timeout)
echo "Fetching public IP..."
public_ip=$(curl -s --max-time 3 https://ifconfig.me)

if [ -n "$public_ip" ]; then
    echo "Successfully fetched public IP"
else
    echo "Could not extract public IP"
    read -p "Specify public IP   (Enter to skip): " public_ip
fi

# Combine public and local IPs into a single array for the menu
options=("${local_options[@]}")
if [ -n "$public_ip" ]; then
    options+=("PUBLIC_EXTERNAL ($public_ip)")
fi

select opt in "${options[@]}" "Skip"; do
    if [ -n "$opt" ]; then
        # Extract solely the addr from the selection
        SELECTED_IP=$(echo "$opt" | grep -oP '\d+\.\d+\.\d+\.\d+')
        break
    else
        echo "Invalid selection"
    fi
done

echo ""

# Write settings into configs
echo "Writing configurations..."
sed -i "s|databaseAddress=.*|databaseAddress=postgres|" ./ermis-configs/database-settings/general-settings.cnf
find ./ermis-configs/nginx/ -type f -name "**" -exec sed -i "s|SERVER_ADDRESS|ermis-server|" {} +
[ -n "${SELECTED_IP}" ] && find ./web_assets -type f -name "**" -exec sed -i "s|SERVER_ADDRESS|${SELECTED_IP}|" {} +
find ./ermis-configs/nginx/ -type f -name "**" -exec sed -i "s|IP_ADDRESS|ermis-server|" {} +
[ -n "${SELECTED_IP}" ] && find ./web_assets -type f -name "**" -exec sed -i "s|IP_ADDRESS|${SELECTED_IP}|" {} +
find ./ermis-configs/nginx/ -type f -name "**" -exec sed -i "s|SERVER_PORT|5551|" {} +
find ./ermis-configs/nginx/ -type f -name "**" -exec sed -i "s|SSL_CERTIFICATE|/etc/ermis-server/certs/server_full.pem|" {} +
find ./ermis-configs/nginx/ -type f -name "**" -exec sed -i "s|SSL_CERTIFICATE_KEY|/etc/ermis-server/certs/server_plain.key|" {} +
sed -i "s|key-store=.*|key-store=/etc/ermis-server/certs/keystore.jks|" ./ermis-configs/server-settings/ssl-settings.cnf
[ -n "${EMAIL_USERNAME}"   ] && sed -i "s|emailUsername=.*|emailUsername=${EMAIL_USERNAME}|" ./ermis-configs/emailer-settings/general-settings.cnf
[ -n "${PAYPAL_CLIENT_ID}" ] && sed -i "s|paypal-client-id=.*|paypal-client-id=${PAYPAL_CLIENT_ID}|" ./ermis-configs/donation-settings/general-settings.cnf
[ -n "${BITCOIN_ADDRESS}"  ] && sed -i "s|bitcon=.*|bitcon=${BITCOIN_ADDRESS}|" ./ermis-configs/donation-settings/general-settings.cnf
[ -n "${MONERO_ADDRESS}"   ] && sed -i "s|monero=.*|monero=${MONERO_ADDRESS}|" ./ermis-configs/donation-settings/general-settings.cnf

echo "Setup complete!"
echo "You can modify the configs any time at ./ermis-configs"

