# HW7 PKI and Web Server - Submission Guide

## What to Submit
Submit the file: **HW7_Report.docx**

This Word document contains:
- Complete explanation of the PKI infrastructure
- All steps taken to generate certificates
- Web server setup instructions
- Verification results
- GitHub/code information

## Files Included in This Directory

### PKI Infrastructure
- `pki/generate_pki.sh` - Automation script for certificate generation
- `pki/root.cnf`, `pki/signing.cnf` - OpenSSL configuration files
- `pki/root/certs/root.cert.pem` - Root CA certificate
- `pki/signing/certs/signing.cert.pem` - Signing CA certificate
- `pki/server/server_chain.pem` - Server certificate chain

### Web Server
- `server/run_server.py` - Python HTTPS server

### Documentation
- `HW7_Report.docx` - **Main submission document (Word format)**
- `HW7_Report.md` - Markdown version
- `.git/` - Git repository with complete history

## Quick Verification (Before Submitting)

### 1. Check Certificates Exist
```bash
ls pki/root/certs/root.cert.pem
ls pki/signing/certs/signing.cert.pem
ls pki/server/server_chain.pem
```

### 2. Verify Certificate Chain
```bash
cd pki
openssl verify -CAfile root/certs/root.cert.pem -untrusted signing/certs/signing.cert.pem server/server.cert.pem
```
Expected: `server/server.cert.pem: OK`

### 3. Test Web Server
**Terminal 1:**
```bash
cd server
python3 run_server.py
```

**Terminal 2:**
```bash
curl --cacert pki/root/certs/root.cert.pem https://localhost:8443
```
Expected: HTML output with "Hello from Secure Server!"

## GitHub (Optional)
If you want to upload to GitHub:
1. Create a new repository on GitHub
2. Run:
   ```bash
   git remote add origin <your-repo-url>
   git branch -M main
   git push -u origin main
   ```
3. Add the GitHub URL to your submission

Otherwise, the local Git repository with full history is sufficient.
