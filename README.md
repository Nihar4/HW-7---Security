# HW7 - PKI Infrastructure and Secure Web Server

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 📋 Project Overview

This project implements a complete **3-tier Public Key Infrastructure (PKI)** and demonstrates its use by configuring a secure HTTPS web server. The implementation follows industry best practices for certificate management and TLS/SSL configuration.

**Course**: CMPE 272 - Enterprise Software Platforms  
**Assignment**: HW7 - Security  
**Repository**: https://github.com/Nihar4/HW-7---Security.git

---

## 🏗️ PKI Architecture

### Certificate Hierarchy

```
Root CA (Self-Signed)
  ├── Subject: CN=RootCA, OU=SecurityClass, O=SJSU
  ├── Validity: 20 years
  └── Signs: Signing CA
       │
       └── Signing CA (Intermediate CA)
            ├── Subject: CN=SigningCA, OU=SecurityClass, O=SJSU
            ├── Validity: 10 years
            ├── Basic Constraints: CA:TRUE, pathlen:0
            └── Signs: Server Certificate
                 │
                 └── Server Certificate (Leaf)
                      ├── Subject: CN=localhost
                      ├── Validity: ~1 year
                      ├── SAN: DNS:localhost, IP:127.0.0.1
                      └── Extended Key Usage: TLS Web Server Authentication
```

---

## 📁 Project Structure

```
HW7/
├── pki/
│   ├── generate_pki.sh          # Certificate generation automation
│   ├── root.cnf                  # Root CA OpenSSL config
│   ├── signing.cnf               # Signing CA OpenSSL config
│   ├── root/
│   │   ├── certs/
│   │   │   └── root.cert.pem    # Root CA certificate
│   │   └── private/              # (Private keys - excluded from repo)
│   ├── signing/
│   │   ├── certs/
│   │   │   └── signing.cert.pem # Signing CA certificate
│   │   └── private/              # (Private keys - excluded from repo)
│   └── server/
│       ├── server.cert.pem      # Server certificate
│       ├── server_chain.pem     # Certificate chain
│       └── server.key.pem       # (Private key - excluded from repo)
├── server/
│   └── run_server.py            # Python HTTPS server
├── screenshots/                  # Documentation screenshots
├── .gitignore                   # Excludes private keys
└── README.md                    # This file
```

---

## 🚀 Quick Start

### Prerequisites

- **OpenSSL** (pre-installed on macOS)
- **Python 3.x** (pre-installed on macOS)
- macOS or Linux environment

### 1. Generate PKI Infrastructure

```bash
cd pki
./generate_pki.sh
```

**Output:**
- Root CA certificate and key
- Signing CA certificate and key (signed by Root CA)
- Server certificate and key (signed by Signing CA)
- Certificate chain file
- Verification: `server/server.cert.pem: OK`

### 2. Start the HTTPS Server

```bash
cd server
python3 run_server.py
```

Server starts on: `https://localhost:8443`

### 3. Test the Connection

**Using curl (recommended):**
```bash
curl --cacert pki/root/certs/root.cert.pem https://localhost:8443
```

**Expected output:**
```html
<h1>Hello from Secure Server!</h1>
<p>This connection is secured with TLS.</p>
```

**Using a browser:**
- Navigate to `https://localhost:8443`
- You'll see a security warning (expected - Root CA not in system trust store)
- Click "Advanced" → "Proceed to localhost"
- View the secure page

---

## 🔍 Verification

### Verify Certificate Chain

```bash
cd pki
openssl verify -CAfile root/certs/root.cert.pem \
  -untrusted signing/certs/signing.cert.pem \
  server/server.cert.pem
```

**Expected:** `server/server.cert.pem: OK`

### Inspect Certificates

**Root CA:**
```bash
openssl x509 -in pki/root/certs/root.cert.pem -text -noout | less
```

**Signing CA:**
```bash
openssl x509 -in pki/signing/certs/signing.cert.pem -text -noout | less
```

**Server Certificate:**
```bash
openssl x509 -in pki/server/server.cert.pem -text -noout | less
```

### Test with Verbose TLS Output

```bash
curl -v --cacert pki/root/certs/root.cert.pem https://localhost:8443
```

Observe:
- TLS protocol version (TLSv1.3)
- Cipher suite
- Certificate verification: "SSL certificate verify ok"

---

## 🔐 Security Features

### Certificate Extensions

**Root CA:**
- `basicConstraints`: CA:TRUE (critical)
- `keyUsage`: digitalSignature, cRLSign, keyCertSign (critical)

**Signing CA:**
- `basicConstraints`: CA:TRUE, pathlen:0 (critical)
- `keyUsage`: digitalSignature, cRLSign, keyCertSign (critical)

**Server Certificate:**
- `basicConstraints`: CA:FALSE
- `keyUsage`: digitalSignature, keyEncipherment (critical)
- `extendedKeyUsage`: serverAuth
- `subjectAltName`: DNS:localhost, IP:127.0.0.1

### Private Key Protection

All private keys (`.key.pem` files) are:
- Excluded from GitHub via `.gitignore`
- Stored locally with restricted permissions
- Never transmitted or shared

---

## 📖 Documentation

### Submission Document

- **HW7_Report_Template.docx** - Comprehensive report with:
  - PKI architecture explanation
  - Step-by-step implementation process
  - Screenshots of all verification steps
  - Testing results
  - GitHub repository reference

### Screenshots Included

17 screenshots documenting:
1. Directory structure
2. PKI generation scripts
3. Certificate generation output
4. Certificate file listings
5-7. Certificate details (Root CA, Signing CA, Server)
8. Certificate chain verification
9. Server code
10. Server startup
11-12. curl testing (basic and verbose)
13-15. Browser testing (warning, certificate details, content)
16. Git repository history
17. Project file structure

---

## ❓ FAQ

### Why does the browser show a security warning?

**This is expected behavior.** The browser shows "Your connection is not private" because:
- Our Root CA is not in the system's trust store
- Only public CAs (Let's Encrypt, DigiCert, etc.) are pre-trusted by browsers
- The certificate chain is valid; the browser just doesn't recognize our custom Root CA

**Solution:** Use `curl --cacert` to provide the Root CA explicitly, or manually import the Root CA into your system keychain.

### Can I use these certificates in production?

**No.** This PKI is for educational purposes only:
- Private keys are stored unencrypted
- Certificates are self-signed
- No Certificate Revocation List (CRL) or OCSP
- No Hardware Security Module (HSM) protection

For production, use:
- Let's Encrypt (free, automated)
- Commercial CAs (DigiCert, GlobalSign, etc.)
- Proper key management and HSM storage

---

## 🛠️ Technologies Used

- **OpenSSL** - Certificate generation and management
- **Python 3** - Web server implementation
- **http.server** - Built-in Python HTTP server
- **ssl module** - TLS/SSL support
- **Git** - Version control

---

## 📚 References

- [PKI Tutorial Documentation](https://pki-tutorial.readthedocs.io/en/latest/simple/)
- [OpenSSL Documentation](https://www.openssl.org/docs/)
- [RFC 5280 - X.509 PKI Certificate](https://tools.ietf.org/html/rfc5280)
- [Python SSL Module](https://docs.python.org/3/library/ssl.html)

---
