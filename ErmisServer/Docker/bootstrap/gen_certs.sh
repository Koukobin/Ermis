#!/bin/bash
# TLS Certificate Generator
#
# Generates a CA + signed server certificate with SAN support, exports to
# PEM, PKCS12, and JKS formats.
#
# Usage:
#   ./gen_certs.sh [--days N] [--domains "d1,d2"] [--ips "ip1,ip2"]
#                  [--out DIR] [--key-bits N] [--cn NAME] [--org NAME]
#                  [--ou NAME] [--country CC] [--state NAME] [--city NAME]
#                  [--email ADDR] [--alias NAME] [--secret PATH]
#
# PS, Claude may have assisted me in the generation of this script

set -euo pipefail
IFS=$'\n\t'

# Color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m' # Color reset

info()    { echo -e "${CYAN}[INFO]${RESET}  $*"; }
success() { echo -e "${GREEN}[OK]${RESET}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*" >&2; }
die()     { echo -e "${RED}[ERROR]${RESET} $*" >&2; exit 1; }
step()    { echo -e "\n${BOLD}── $* ──${RESET}"; }

# Defaults
DAYS_VALID=3650
DOMAINS="localhost"
IPS="127.0.0.1"
OUT_DIR="./certs"
KEY_BITS=4096
COMMON_NAME="ermis-server"
ORG_NAME="Ermis Organisation"
ORG_UNIT=""          # optional
COUNTRY=""           # optional
STATE=""             # optional
CITY=""              # optional
EMAIL=""             # optional
CERT_ALIAS="ermis-server"  # alias used in PKCS12 and JKS entries
SECRET_PATH="./secrets/keystore_password"

# Cleanup ephemeral intermediate files
function cleanup() {
    step "Cleanup"
    info "Removing ephemeral intermediate files..."
    rm -f "$SERVER_CSR" "${OUT_DIR}/ca.srl" "$OPENSSL_CNF"
    success "Cleaned up: server.csr, ca.srl, openssl.cnf"
}

trap cleanup EXIT

# Argument parsing
while [[ $# -gt 0 ]]; do
    case "$1" in
        --days)      DAYS_VALID="$2";   shift 2 ;;
        --domains)   DOMAINS="$2";      shift 2 ;;
        --ips)       IPS="$2";          shift 2 ;;
        --out)       OUT_DIR="$2";      shift 2 ;;
        --key-bits)  KEY_BITS="$2";     shift 2 ;;
        --cn)        COMMON_NAME="$2";  shift 2 ;;
        --org)       ORG_NAME="$2";     shift 2 ;;
        --ou)        ORG_UNIT="$2";     shift 2 ;;
        --country)   COUNTRY="$2";      shift 2 ;;
        --state)     STATE="$2";        shift 2 ;;
        --city)      CITY="$2";         shift 2 ;;
        --email)     EMAIL="$2";        shift 2 ;;
        --alias)     CERT_ALIAS="$2";   shift 2 ;;
        --secret)    SECRET_PATH="$2";  shift 2 ;;
        *) die "Unknown argument" ;;
    esac
done

[[ -f "$SECRET_PATH" ]] || die "Secret file not found (run ./set_secret.sh first): $SECRET_PATH"
MASTER_PASSWORD=$(< "$SECRET_PATH")

# Argument validation
step "Validating environment"

[[ "$DAYS_VALID" =~ ^[0-9]+$ ]] || die "--days must be a positive integer."
[[ "$KEY_BITS" =~ ^(2048|3072|4096|8192)$ ]] || die "--key-bits must be 2048, 3072, 4096, or 8192."

# Country must be exactly 2 uppercase letters
if [[ -n "$COUNTRY" ]]; then
    [[ "$COUNTRY" =~ ^[A-Z]{2}$ ]] || die "--country must be a 2-letter ISO 3166-1 code (e.g. GR, CY, US)."
fi

# Email basic sanity check
if [[ -n "$EMAIL" ]]; then
    [[ "$EMAIL" =~ ^[^@]+@[^@]+\.[^@]+$ ]] || die "--email does not look like a valid address."
fi

for cmd in openssl; do
    command -v "$cmd" &>/dev/null || die "'$cmd' is not installed or not in PATH."
done

# Password check
[[ -n "$MASTER_PASSWORD" ]] || die "Secret file is empty: $SECRET_PATH"
[[ ${#MASTER_PASSWORD} -ge 6 ]] || die "Password must be at least 6 characters (keytool requirement)."

# Build Distinguished Name string
# Only include fields that were actually provided
build_dn() {
    local dn="/CN=${COMMON_NAME}"
    [[ -n "$ORG_NAME"  ]] && dn+="/O=${ORG_NAME}"
    [[ -n "$ORG_UNIT"  ]] && dn+="/OU=${ORG_UNIT}"
    [[ -n "$COUNTRY"   ]] && dn+="/C=${COUNTRY}"
    [[ -n "$STATE"     ]] && dn+="/ST=${STATE}"
    [[ -n "$CITY"      ]] && dn+="/L=${CITY}"
    [[ -n "$EMAIL"     ]] && dn+="/emailAddress=${EMAIL}"
    echo "$dn"
}

SUBJECT_DN=$(build_dn)
CA_SUBJECT_DN="/CN=${ORG_NAME} CA"
[[ -n "$ORG_NAME"  ]] && CA_SUBJECT_DN+="/O=${ORG_NAME}"
[[ -n "$ORG_UNIT"  ]] && CA_SUBJECT_DN+="/OU=${ORG_UNIT}"
[[ -n "$COUNTRY"   ]] && CA_SUBJECT_DN+="/C=${COUNTRY}"
[[ -n "$STATE"     ]] && CA_SUBJECT_DN+="/ST=${STATE}"
[[ -n "$CITY"      ]] && CA_SUBJECT_DN+="/L=${CITY}"

# Output directory
if [[ -d "$OUT_DIR" ]]; then
    warn "Output directory '$OUT_DIR' already exists. Existing files may be overwritten."
else
    mkdir -p "$OUT_DIR"
fi
# Restrict directory permissions immediately
chmod 750 "$OUT_DIR"

# Build SAN extension block
build_san() {
    local san=""
    local idx=1
    IFS=',' read -ra DOMAIN_LIST <<< "$DOMAINS"
    for d in "${DOMAIN_LIST[@]}"; do
        d=$(echo "$d" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')  # trim whitespaces
        [[ -n "$d" ]] && san+="DNS.${idx} = ${d}\n" && ((idx++))
    done
    idx=1
    IFS=',' read -ra IP_LIST <<< "$IPS"
    for ip in "${IP_LIST[@]}"; do
        ip=$(echo "$ip" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//') # trim whitespaces
        [[ -n "$ip" ]] && san+="IP.${idx} = ${ip}\n" && ((idx++))
    done
    printf '%b' "$san"
}

SAN_ENTRIES=$(build_san)
[[ -n "$SAN_ENTRIES" ]] || die "At least one domain or IP must be specified for SAN."

# Build [dn] section for openssl.cnf
# Only emit lines for fields that were provided — openssl rejects empty values
build_cnf_dn() {
    echo "CN = ${COMMON_NAME}"
    [[ -n "$ORG_NAME" ]] && echo "O  = ${ORG_NAME}"
    [[ -n "$ORG_UNIT" ]] && echo "OU = ${ORG_UNIT}"
    [[ -n "$COUNTRY"  ]] && echo "C  = ${COUNTRY}"
    [[ -n "$STATE"    ]] && echo "ST = ${STATE}"
    [[ -n "$CITY"     ]] && echo "L  = ${CITY}"
    [[ -n "$EMAIL"    ]] && echo "emailAddress = ${EMAIL}"
    return 0
}

DN_SECTION=$(build_cnf_dn)

# OpenSSL config file
OPENSSL_CNF="${OUT_DIR}/openssl.cnf" # ephemeral
cat > "$OPENSSL_CNF" <<EOF
[ req ]
default_bits        = ${KEY_BITS}
prompt              = no
default_md          = sha256
distinguished_name  = dn
req_extensions      = v3_req

[ dn ]
${DN_SECTION}

[ v3_req ]
subjectAltName      = @alt_names
keyUsage            = critical, digitalSignature, keyEncipherment
extendedKeyUsage    = serverAuth, clientAuth
basicConstraints    = CA:FALSE

[ v3_ca ]
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints       = critical, CA:TRUE, pathlen:0
keyUsage               = critical, keyCertSign, cRLSign

[ alt_names ]
${SAN_ENTRIES}
EOF
success "OpenSSL config written --> $OPENSSL_CNF"

# Step 1: Certificate Authority
step "Step 1/5 - Certificate Authority"

CA_KEY="${OUT_DIR}/ca.key"
CA_CRT="${OUT_DIR}/ca.crt"

info "Generating CA private key (RSA-${KEY_BITS}, AES-256 encrypted)..."
openssl genpkey \
    -algorithm RSA \
    -out "$CA_KEY" \
    -aes256 \
    -pass file:"$SECRET_PATH" \
    -pkeyopt rsa_keygen_bits:"$KEY_BITS"
chmod 600 "$CA_KEY"

info "Generating CA self-signed certificate (valid ${DAYS_VALID} days)..."
openssl req \
    -new \
    -x509 \
    -key "$CA_KEY" \
    -passin file:"$SECRET_PATH" \
    -out "$CA_CRT" \
    -days "$DAYS_VALID" \
    -config "$OPENSSL_CNF" \
    -extensions v3_ca \
    -subj "$CA_SUBJECT_DN"
chmod 644 "$CA_CRT"
success "CA certificate --> $CA_CRT"

# Step 2: Server Certificate
step "Step 2/5 - Server Certificate"

SERVER_KEY="${OUT_DIR}/server.key"
SERVER_KEY_PLAIN="${OUT_DIR}/server_plain.key"  # unencrypted
SERVER_CSR="${OUT_DIR}/server.csr"  # ephemeral
SERVER_CRT="${OUT_DIR}/server.crt"

info "Generating server private key (RSA-${KEY_BITS}, AES-256 encrypted)..."
openssl genpkey \
    -algorithm RSA \
    -out "$SERVER_KEY" \
    -aes256 \
    -pass file:"$SECRET_PATH" \
    -pkeyopt rsa_keygen_bits:"$KEY_BITS"
chmod 640 "$SERVER_KEY"

info "Generating plain unencrypted server private key..."
openssl rsa \
    -in "$SERVER_KEY" \
    -out "$SERVER_KEY_PLAIN" \
    -passin file:"$SECRET_PATH"

info "Generating server CSR (DN: $SUBJECT_DN)..."
openssl req \
    -new \
    -key "$SERVER_KEY" \
    -passin file:"$SECRET_PATH" \
    -out "$SERVER_CSR" \
    -config "$OPENSSL_CNF" \
    -subj "$SUBJECT_DN"

info "Signing server CSR with CA (SAN included)..."
openssl x509 \
    -req \
    -in "$SERVER_CSR" \
    -CA "$CA_CRT" \
    -CAkey "$CA_KEY" \
    -passin file:"$SECRET_PATH" \
    -CAcreateserial \
    -out "$SERVER_CRT" \
    -days "$DAYS_VALID" \
    -sha256 \
    -extfile "$OPENSSL_CNF" \
    -extensions v3_req
chmod 644 "$SERVER_CRT"
success "Server certificate --> $SERVER_CRT"

# Step 3: PEM Formats
step "Step 3/5 - PEM Formats"

SERVER_FULL_PEM="${OUT_DIR}/server_full.pem"

info "Decrypting server key into memory and assembling full PEM (no plaintext key on disk)..."
# Pipe directly — never write the plaintext key to a named file on disk
openssl rsa \
    -in "$SERVER_KEY" \
    -passin file:"$SECRET_PATH" | \
cat "$SERVER_CRT" - > "$SERVER_FULL_PEM"
chmod 640 "$SERVER_FULL_PEM"
success "Full PEM bundle --> $SERVER_FULL_PEM"

# Step 4: PKCS12 + JKS
step "Step 4/5 - PKCS12 / JKS"

P12="${OUT_DIR}/server.p12"
JKS="${OUT_DIR}/keystore.jks"

info "Creating PKCS12 bundle (alias: ${CERT_ALIAS})..."
openssl pkcs12 \
    -export \
    -in "$SERVER_CRT" \
    -inkey "$SERVER_KEY" \
    -passin file:"$SECRET_PATH" \
    -out "$P12" \
    -passout pass:"$MASTER_PASSWORD" \
    -name "$COMMON_NAME" \
    -CAfile "$CA_CRT" \
    -caname root
chmod 640 "$P12"
success "PKCS12 bundle --> $P12"

info "Importing CA into JKS keystore (alias: ${CERT_ALIAS}-ca)..."
keytool -import \
    -alias "$CERT_ALIAS-ca" \
    -file "$CA_CRT" \
    -keystore "$JKS" \
    -storepass "$MASTER_PASSWORD" \
    -noprompt

info "Importing PKCS12 into JKS keystore (alias: ${CERT_ALIAS})..."
keytool -importkeystore \
    -srckeystore "$P12" \
    -srcstoretype PKCS12 \
    -srcstorepass "$MASTER_PASSWORD" \
    -destkeystore "$JKS" \
    -deststoretype JKS \
    -deststorepass "$MASTER_PASSWORD" \
    -noprompt
chmod 640 "$JKS"
success "JKS keystore --> $JKS"

# Step 5: Verification
step "Step 5/5 - Verification"

info "Verifying certificate chain..."
openssl verify -CAfile "$CA_CRT" "$SERVER_CRT" \
    && success "Server cert verifies against CA." \
    || die "Certificate chain verification FAILED."

info "Verifying private key matches certificate..."
CERT_MODULUS=$(openssl x509 -noout -modulus -in "$SERVER_CRT" | openssl sha256)
KEY_MODULUS=$(openssl rsa -noout -modulus \
    -in "$SERVER_KEY" -passin file:"$SECRET_PATH" | openssl sha256)
[[ "$CERT_MODULUS" == "$KEY_MODULUS" ]] \
    && success "Private key matches certificate." \
    || die "Private key does NOT match certificate — something went wrong."

info "Certificate details:"
openssl x509 -in "$SERVER_CRT" -noout \
    -subject -issuer -dates -fingerprint -sha256

info "SAN entries on server cert:"
openssl x509 -in "$SERVER_CRT" -noout -ext subjectAltName

info "JKS keystore contents:"
keytool -list -keystore "$JKS" -storepass "$MASTER_PASSWORD"

# Summary
step "Done"
echo -e "${BOLD}Output files in ${OUT_DIR}/${RESET}"
echo
printf "  %-30s %s\n" "ca.crt"           "CA certificate (install as trusted root)"
printf "  %-30s %s\n" "ca.key"           "CA private key (AES-256 encrypted — keep offline)"
printf "  %-30s %s\n" "server.crt"       "Server certificate"
printf "  %-30s %s\n" "server.key"       "Server private key (AES-256 encrypted)"
printf "  %-30s %s\n" "server_full.pem"  "Server cert + decrypted key bundle (PEM)"
printf "  %-30s %s\n" "server.p12"       "PKCS12 bundle (alias: ${CERT_ALIAS})"
printf "  %-30s %s\n" "keystore.jks"     "JKS keystore (alias: ${CERT_ALIAS} + ${CERT_ALIAS}-ca)"
echo
