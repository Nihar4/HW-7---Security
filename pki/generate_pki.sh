#!/bin/bash
set -e

# Directory setup
mkdir -p root/certs root/private root/newcerts
mkdir -p signing/certs signing/csr signing/private signing/newcerts
mkdir -p server

# Initialize databases
touch root/index.txt
echo 1000 > root/serial
touch signing/index.txt
echo 1000 > signing/serial

# Create Root CA Config
cat > root.cnf <<EOF
[ ca ]
default_ca = CA_default

[ CA_default ]
dir               = ./root
certs             = \$dir/certs
crl_dir           = \$dir/crl
new_certs_dir     = \$dir/newcerts
database          = \$dir/index.txt
serial            = \$dir/serial
RANDFILE          = \$dir/private/.rand

private_key       = \$dir/private/root.key.pem
certificate       = \$dir/certs/root.cert.pem

default_days      = 3650
default_md        = sha256
preserve          = no
policy            = policy_strict

[ policy_strict ]
countryName             = match
stateOrProvinceName     = match
organizationName        = match
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ req ]
default_bits        = 2048
distinguished_name  = req_distinguished_name
string_mask         = utf8only
default_md          = sha256
x509_extensions     = v3_ca

[ req_distinguished_name ]
countryName                     = Country Name (2 letter code)
stateOrProvinceName             = State or Province Name
localityName                    = Locality Name
0.organizationName              = Organization Name
organizationalUnitName          = Organizational Unit Name
commonName                      = Common Name
emailAddress                    = Email Address

[ v3_ca ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true
keyUsage = critical, digitalSignature, cRLSign, keyCertSign

[ v3_intermediate_ca ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true, pathlen:0
keyUsage = critical, digitalSignature, cRLSign, keyCertSign
EOF

# Create Signing CA Config
cat > signing.cnf <<EOF
[ ca ]
default_ca = CA_default

[ CA_default ]
dir               = ./signing
certs             = \$dir/certs
crl_dir           = \$dir/crl
new_certs_dir     = \$dir/newcerts
database          = \$dir/index.txt
serial            = \$dir/serial
RANDFILE          = \$dir/private/.rand

private_key       = \$dir/private/signing.key.pem
certificate       = \$dir/certs/signing.cert.pem

default_days      = 3650
default_md        = sha256
preserve          = no
policy            = policy_strict

[ policy_strict ]
countryName             = match
stateOrProvinceName     = match
organizationName        = match
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ req ]
default_bits        = 2048
distinguished_name  = req_distinguished_name
string_mask         = utf8only
default_md          = sha256
x509_extensions     = v3_intermediate_ca

[ req_distinguished_name ]
countryName                     = Country Name (2 letter code)
stateOrProvinceName             = State or Province Name
localityName                    = Locality Name
0.organizationName              = Organization Name
organizationalUnitName          = Organizational Unit Name
commonName                      = Common Name
emailAddress                    = Email Address

[ v3_intermediate_ca ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true, pathlen:0
keyUsage = critical, digitalSignature, cRLSign, keyCertSign

[ server_cert ]
basicConstraints = CA:FALSE
nsCertType = server
nsComment = "OpenSSL Generated Server Certificate"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer:always
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = localhost
IP.1 = 127.0.0.1
EOF

echo "=== Generating Root CA ==="
# Generate Root Key
openssl genrsa -out root/private/root.key.pem 4096
# Generate Root Cert
openssl req -config root.cnf \
      -key root/private/root.key.pem \
      -new -x509 -days 7300 -sha256 -extensions v3_ca \
      -out root/certs/root.cert.pem \
      -subj "/C=US/ST=California/L=SanJose/O=SJSU/OU=SecurityClass/CN=RootCA"

echo "=== Generating Signing CA ==="
# Generate Signing CA Key
openssl genrsa -out signing/private/signing.key.pem 4096
# Generate Signing CA CSR
openssl req -config signing.cnf -new -sha256 \
      -key signing/private/signing.key.pem \
      -out signing/csr/signing.csr.pem \
      -subj "/C=US/ST=California/L=SanJose/O=SJSU/OU=SecurityClass/CN=SigningCA"

# Sign Signing CA Cert with Root CA
openssl ca -config root.cnf -extensions v3_intermediate_ca \
      -days 3650 -notext -md sha256 \
      -in signing/csr/signing.csr.pem \
      -out signing/certs/signing.cert.pem \
      -batch

echo "=== Generating Server Certificate ==="
# Generate Server Key
openssl genrsa -out server/server.key.pem 2048
# Generate Server CSR
openssl req -config signing.cnf -new -sha256 \
      -key server/server.key.pem \
      -out server/server.csr.pem \
      -subj "/C=US/ST=California/L=SanJose/O=SJSU/OU=SecurityClass/CN=localhost"

# Sign Server Cert with Signing CA
openssl ca -config signing.cnf -extensions server_cert \
      -days 375 -notext -md sha256 \
      -in server/server.csr.pem \
      -out server/server.cert.pem \
      -batch

# Create Chain File
cat server/server.cert.pem signing/certs/signing.cert.pem > server/server_chain.pem

echo "=== Verification ==="
openssl verify -CAfile root/certs/root.cert.pem -untrusted signing/certs/signing.cert.pem server/server.cert.pem

echo "PKI Generation Complete!"
