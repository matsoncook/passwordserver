import datetime
from cryptography import x509
from cryptography.x509.oid import NameOID
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.primitives import serialization

# --- Configuration for the Certificate (Similar to OpenSSL's Interactive Prompt) ---
# NOTE: For an IP address, use an empty list for subject_alt_names and 
# set the COMMON_NAME to the IP.
COMMON_NAME = u"your_domain_name.com"  # Replace with your domain or IP address (for testing)
ORGANIZATION = u"My Company"
COUNTRY = u"US"
STATE = u"California"
CITY = u"Mountain View"
EMAIL = u"admin@your_domain_name.com"
CERT_DURATION_DAYS = 365 # Same as -days 365 in OpenSSL

# Output filenames
KEY_FILE = "server_python.key"
CERT_FILE = "server_python.crt"
# -----------------------------------------------------------------------------------


def generate_self_signed_cert(common_name, organization, country, state, city, email, duration_days):
    """
    Generates an RSA private key and a self-signed X.509 certificate.
    """
    print(f"Starting key and certificate generation for: {common_name}")

    # 1. Generate Private Key (RSA 2048-bit)
    # This is equivalent to -newkey rsa:2048
    private_key = rsa.generate_private_key(
        public_exponent=65537,
        key_size=2048,
    )
    print(f"Generated private key: {private_key.key_size} bits.")

    # 2. Define Certificate Subject and Issuer (The identity information)
    subject = issuer = x509.Name([
        x509.NameAttribute(NameOID.COUNTRY_NAME, country),
        x509.NameAttribute(NameOID.STATE_OR_PROVINCE_NAME, state),
        x509.NameAttribute(NameOID.LOCALITY_NAME, city),
        x509.NameAttribute(NameOID.ORGANIZATION_NAME, organization),
        x509.NameAttribute(NameOID.COMMON_NAME, common_name),
        x509.NameAttribute(NameOID.EMAIL_ADDRESS, email),
    ])

    # 3. Build the Certificate
    one_day = datetime.timedelta(1, 0, 0)
    
    builder = x509.CertificateBuilder().subject_name(subject).issuer_name(issuer)
    
    # Set validity period (Not Before & Not After)
    builder = builder.not_valid_before(datetime.datetime.now(datetime.timezone.utc) - one_day)
    builder = builder.not_valid_after(datetime.datetime.now(datetime.timezone.utc) + datetime.timedelta(days=duration_days))
    
    # Set the public key
    builder = builder.public_key(private_key.public_key())
    
    # Add key usage and basic constraints (mandatory for a valid certificate)
    builder = builder.add_extension(
        x509.BasicConstraints(ca=True, path_length=None), critical=True,
    )
    builder = builder.add_extension(
        x509.KeyUsage(
            digital_signature=True, content_commitment=False, key_encipherment=True,
            data_encipherment=False, key_agreement=False, key_cert_sign=True,
            crl_sign=True, encipher_only=False, decipher_only=False
        ), critical=True
    )
    
    # Self-sign the certificate using SHA256 (common and secure hash algorithm)
    certificate = builder.sign(
        private_key=private_key, algorithm=hashes.SHA256(),
    )
    print("Certificate successfully created and self-signed.")

    # 4. Write Private Key to Disk
    with open(KEY_FILE, "wb") as f:
        # Save key unencrypted (equivalent to -nodes)
        f.write(private_key.private_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PrivateFormat.PKCS8,
            encryption_algorithm=serialization.NoEncryption(),
        ))
    print(f"Private Key saved to: {KEY_FILE}")

    # 5. Write Certificate to Disk
    with open(CERT_FILE, "wb") as f:
        f.write(certificate.public_bytes(
            encoding=serialization.Encoding.PEM,
        ))
    print(f"Certificate saved to: {CERT_FILE}")


if __name__ == "__main__":
    try:
        generate_self_signed_cert(
            COMMON_NAME, ORGANIZATION, COUNTRY, STATE, CITY, EMAIL, CERT_DURATION_DAYS
        )
        print("\n--- Next Steps ---")
        print(f"1. Install the 'cryptography' library: pip install cryptography")
        print(f"2. Run the script: python {__file__}")
        print(f"3. Move {KEY_FILE} and {CERT_FILE} to /etc/nginx/ssl/")
        print("4. Update your nginx.conf to point to these new files.")
    except Exception as e:
        print(f"An error occurred during generation: {e}")