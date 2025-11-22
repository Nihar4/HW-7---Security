# HW7 - PKI and Web Server Report

## Overview
This project implements a 3-tier PKI infrastructure and uses it to secure a local web server.
The infrastructure consists of:
1.  **Root CA**: The trust anchor.
2.  **Signing CA**: An intermediate CA signed by the Root CA.
3.  **Server Certificate**: A leaf certificate signed by the Signing CA, issued to `localhost`.

## PKI Structure
The PKI is generated using OpenSSL with a custom configuration script.

### Hierarchy
*   **Root CA**
    *   Subject: `CN=RootCA, OU=SecurityClass, O=SJSU, L=SanJose, ST=California, C=US`
    *   Validity: 20 years
*   **Signing CA**
    *   Subject: `CN=SigningCA, OU=SecurityClass, O=SJSU, L=SanJose, ST=California, C=US`
    *   Issuer: Root CA
    *   Validity: 10 years
*   **Server Certificate**
    *   Subject: `CN=localhost, OU=SecurityClass, O=SJSU, L=SanJose, ST=California, C=US`
    *   Issuer: Signing CA
    *   Validity: ~1 year
    *   SAN: `DNS:localhost`, `IP:127.0.0.1`

## Files
*   `pki/generate_pki.sh`: Bash script to automate certificate generation.
*   `pki/root.cnf`, `pki/signing.cnf`: OpenSSL configuration files.
*   `pki/root/certs/root.cert.pem`: Root CA Certificate.
*   `pki/signing/certs/signing.cert.pem`: Signing CA Certificate.
*   `pki/server/server_chain.pem`: Server certificate chain (Server Cert + Signing CA Cert).
*   `server/run_server.py`: Python script to run the HTTPS server.

## Instructions

### 1. Generate PKI
Run the generation script to create all keys and certificates:
```bash
cd pki
./generate_pki.sh
```

### 2. Start Web Server
The server uses Python's `http.server` module wrapped with SSL.
```bash
cd server
python3 run_server.py
```
The server listens on `https://localhost:8443`.

### 3. Verify Connection
Use `curl` to verify the connection, providing the Root CA to establish trust:
```bash
curl --cacert pki/root/certs/root.cert.pem https://localhost:8443
```
**Expected Output:**
```html
<h1>Hello from Secure Server!</h1><p>This connection is secured with TLS.</p>
```

## GitHub Repository
Code is available at: [Link to your repo if applicable, or just "Included in submission"]
(Note: You can initialize a git repo in this folder)
