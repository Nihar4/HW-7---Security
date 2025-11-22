import http.server
import ssl
import os

# Configuration
PORT = 8443
CERT_FILE = '../pki/server/server_chain.pem'
KEY_FILE = '../pki/server/server.key.pem'

class SimpleHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        self.wfile.write(b"<h1>Hello from Secure Server!</h1>")
        self.wfile.write(b"<p>This connection is secured with TLS.</p>")

print(f"Starting server on https://localhost:{PORT}")
server_address = ('localhost', PORT)
httpd = http.server.HTTPServer(server_address, SimpleHandler)

# Create an SSL context
context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
context.load_cert_chain(certfile=CERT_FILE, keyfile=KEY_FILE)

# Wrap the socket
httpd.socket = context.wrap_socket(httpd.socket, server_side=True)

try:
    httpd.serve_forever()
except KeyboardInterrupt:
    print("\nServer stopped.")
