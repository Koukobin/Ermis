#!/bin/bash

# Prompt for user input
echo -n "Enter the number of days the certificates should be valid for (default 3650):"
read DAYS_VALID
DAYS_VALID=${DAYS_VALID:-3650}  # Use 3650 days as default if no input

# Step 1: Create Your Own Certificate Authority (CA)

# 1.1 Generate the CA Private Key

echo
echo

echo "Generating CA private key..."
openssl genpkey -algorithm RSA -out ca.key -aes256 -pkeyopt rsa_keygen_bits:4096

# 1.2 Generate the CA Self-Signed Certificate

echo
echo

echo "Generating CA self-signed certificate..."
openssl req -key ca.key -new -x509 -out ca.crt -days $DAYS_VALID

# Step 2: Generate the Server Certificate

# 2.1 Generate a Private Key for the Server

echo
echo

echo "Generating server private key..."
openssl genpkey -algorithm RSA -out server.key -pkeyopt rsa_keygen_bits:4096

# 2.2 Generate a Certificate Signing Request (CSR)

echo
echo

echo "Generating server CSR..."
openssl req -new -key server.key -out server.csr

# 2.3 Sign the CSR with the CA

echo
echo

echo "Signing server CSR with CA..."
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days $DAYS_VALID

# Step 3: Convert the Certificates to PEM Format

# 3.1 Convert the Server Private Key to PEM Format

echo
echo

echo "Converting server private key to PEM format..."
openssl rsa -in server.key -out server.pem

# 3.2 Combine the Server Certificate and Private Key into a Full PEM File

echo
echo

echo "Combining server certificate and private key into full PEM format..."
cat server.crt server.pem > server_full.pem

# Step 4: Convert the Certificates to JKS Format

# 4.1 Import the CA Certificate into the JKS

echo
echo

echo "Importing CA certificate into JKS keystore..."
keytool -import -alias myca -file ca.crt -keystore keystore.jks -noprompt

# 4.2 Create a PKCS12 Keystore with the Server Certificate and Private Key

echo
echo

echo "Creating PKCS12 keystore for server certificate and private key..."
openssl pkcs12 -export -in server.crt -inkey server.key -out server.p12 -name server -CAfile ca.crt -caname root

# 4.3 Import the PKCS12 Keystore into the JKS Keystore

echo
echo

echo "Importing PKCS12 keystore into JKS keystore..."
keytool -importkeystore -srckeystore server.p12 -srcstoretype PKCS12 -destkeystore keystore.jks -deststoretype JKS

# Step 5: Verify and Use the Certificates

# Verify the contents of the JKS keystore

echo
echo

echo "Verifying JKS keystore..."
keytool -list -keystore keystore.jks

# Verify the PEM certificates

echo
echo

echo "Verifying JKS server certificate..."
keytool -list -keystore keystore.jks

echo "Verifying PEM server certificate..."
openssl x509 -in server.crt -text -noout

