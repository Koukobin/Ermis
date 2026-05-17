#!/bin/bash

# Read master password from configured Docker secret
MASTER_PASSWORD=$(cat ./secrets/db_user_password)

# Prompt for certificate validity
echo -n "Enter the number of days the certificates should be valid for (default 3650): "
read DAYS_VALID
DAYS_VALID=${DAYS_VALID:-3650} # Use 3650 days as default if no input

mkdir ./certs
cd ./certs

# Step 1: Create Your Own Certificate Authority (CA)

echo
echo "Generating CA private key..."
openssl genpkey \
    -algorithm RSA \
    -out ca.key \
    -aes256 \
    -pass pass:"$MASTER_PASSWORD" \
    -pkeyopt rsa_keygen_bits:4096

echo
echo "Generating CA self-signed certificate..."
openssl req \
    -key ca.key \
    -passin pass:"$MASTER_PASSWORD" \
    -new \
    -x509 \
    -out ca.crt \
    -days "$DAYS_VALID"

# Step 2: Generate the Server Certificate

echo
echo "Generating server private key..."
openssl genpkey \
    -algorithm RSA \
    -out server.key \
    -aes256 \
    -pass pass:"$MASTER_PASSWORD" \
    -pkeyopt rsa_keygen_bits:4096

echo
echo "Generating server CSR..."
openssl req \
    -new \
    -key server.key \
    -passin pass:"$MASTER_PASSWORD" \
    -out server.csr

echo
echo "Signing server CSR with CA..."
openssl x509 \
    -req \
    -in server.csr \
    -CA ca.crt \
    -CAkey ca.key \
    -passin pass:"$MASTER_PASSWORD" \
    -CAcreateserial \
    -out server.crt \
    -days "$DAYS_VALID"

# Step 3: Convert the Certificates to PEM Format

echo
echo "Converting server private key to PEM format..."
openssl rsa \
    -in server.key \
    -passin pass:"$MASTER_PASSWORD" \
    -out server.pem

echo
echo "Combining server certificate and private key into full PEM format..."
cat server.crt server.pem > server_full.pem

# Step 4: Convert the Certificates to JKS Format

echo
echo "Importing CA certificate into JKS keystore..."
keytool -import \
    -alias myca \
    -file ca.crt \
    -keystore keystore.jks \
    -storepass "$MASTER_PASSWORD" \
    -noprompt

echo
echo "Creating PKCS12 keystore for server certificate and private key..."
openssl pkcs12 \
    -export \
    -in server.crt \
    -inkey server.key \
    -passin pass:"$MASTER_PASSWORD" \
    -out server.p12 \
    -passout pass:"$MASTER_PASSWORD" \
    -name server \
    -CAfile ca.crt \
    -caname root

echo
echo "Importing PKCS12 keystore into JKS keystore..."
keytool -importkeystore \
    -srckeystore server.p12 \
    -srcstoretype PKCS12 \
    -srcstorepass "$MASTER_PASSWORD" \
    -destkeystore keystore.jks \
    -deststoretype JKS \
    -deststorepass "$MASTER_PASSWORD"

# Step 5: Verify and Use the Certificates

echo
echo "Verifying JKS keystore..."
keytool -list \
    -keystore keystore.jks \
    -storepass "$MASTER_PASSWORD"

echo
echo "Verifying PEM server certificate..."
openssl x509 -in server.crt -text -noout

echo
echo "Done."
