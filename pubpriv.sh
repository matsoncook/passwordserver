OpenSSL Guide: Creating a Private Key and Self-Signed Certificate

This guide outlines the common command used on Linux (like AWS Ubuntu) to create a private key and a self-signed certificate using OpenSSL.

1. Generating a New Private Key and Certificate Simultaneously

The easiest and most common way to get started is to generate both the private key and the public certificate at the same time.

The Command

Use this single command to create a key pair and a certificate signed by that key (self-signed):

sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout server.key -out server.crt


Explanation of Arguments

Argument

Description

sudo

Ensures you have the necessary permissions to write files to /etc/nginx/ssl/ or similar secure directories.

openssl req

Command to create a new Certificate Signing Request (CSR) or, with -x509, a self-signed certificate.

-x509

Tells OpenSSL to output a self-signed certificate instead of just a CSR.

-nodes

No DES encryption. This prevents encrypting the private key (server.key) with a passphrase. WARNING: This is common for Nginx for automated startup, but means the key is unencrypted.

-days 365

Sets the validity period for the certificate to 365 days.

-newkey rsa:2048

Specifies that a new private key should be generated using the RSA algorithm with a key size of 2048 bits (the standard minimum).

-keyout server.key

Specifies the output filename for the Private Key. This file must be kept secret.

-out server.crt

Specifies the output filename for the Certificate (containing the public key).

Interactive Prompt (req Details)

When you run the command, OpenSSL will prompt you to enter information that will be embedded in the certificate.

Pay special attention to the Common Name (CN):

If using a Domain: Enter your domain name (e.g., your_domain_name.com).

If accessing by IP (for testing): Enter the IP address of your server (e.g., 123.45.67.89).

Example of the input prompt:

Country Name (2 letter code) [AU]:US
State or Province Name (full name) [Some-State]:California
Locality Name (eg, city) []:Mountain View
Organization Name (eg, company) [Internet Widgits Pty Ltd]:My Company
Organizational Unit Name (eg, section) []:IT
Common Name (e.g. server FQDN or YOUR name) []:your_domain_name.com  <- THIS IS CRITICAL
Email Address []:admin@your_domain_name.com


2. The Resulting Files

After running the command, you will have two files in your current directory:

server.key (Private Key):

Keep Secret! This is the cryptographic secret.

Used in Nginx: ssl_certificate_key

server.crt (Public Certificate):

Can be Shared. This is the public key and identity information.

Used in Nginx: ssl_certificate

3. Recommended Storage Location

For a production Nginx setup, you should move these files to a secure location where Nginx can read them, such as:

sudo mkdir -p /etc/nginx/ssl
sudo mv server.key server.crt /etc/nginx/ssl/


Then, you would use these paths in your nginx.conf:

ssl_certificate /etc/nginx/ssl/server.crt;
ssl_certificate_key /etc/nginx/ssl/server.key;
