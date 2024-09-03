#!/bin/sh

# This script will generate a self signed SSL certificate along with a certificate authority.
# The purpose of this is to have a one time setup to generate a self signed SSL certificate so local development will have an https connection

# Slightly modified version of code from: https://devopscube.com/create-self-signed-certificates-openssl/

currentDir=$(pwd)
defaultDomain=local.dev

rootCA_filename=local_rootCA
rootCA_country=UK
rootCA_organization="SelfSigned Certificates"
rootCA_commonname="Localhost Root Certificate Authority"

country=UK
state=London
locality=Barnet
organization="Sursill Ltd."
organizationalUnit="Sursill Ltd. dev"

if [ "$#" -ne 1 ]
then
    echo "Warning: No domain was provided. Using local.dev as domain name"
    echo "Usage: $0 <domain name>"
    domain=$defaultDomain
else
    domain=$1
fi

commonname=$domain

if [ ! -f "$currentDir/$rootCA_filename.key" ]
then
    echo "RootCA Certificate not found. Generating a new one."

    # Generate root CA and Private key
    openssl req -x509 \
                -sha256 -days 3650 \
                -nodes \
                -newkey rsa:2048 \
                -subj "/C=$rootCA_country/O=$rootCA_organization/CN=$rootCA_commonname" \
                -keyout $rootCA_filename.key -out $rootCA_filename.crt

else
    echo "RootCA Certificate found"
fi

# Create folder for domain
if [ ! -d ./$domain ];
then
    mkdir $domain
fi

cd $domain

# Generate Private key
openssl genrsa -out $domain.key 2048

# Create csf conf
cat > csr.conf <<EOF
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
C = $country
ST = $state
L = $locality
O = $organization
OU = $organizationalUnit
CN = $commonname

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = $domain
DNS.2 = www.$domain
IP.1 = 127.0.0.1

EOF


# Create CSR request using private key
openssl req -new \
            -key $domain.key \
            -out $domain.csr \
            -config csr.conf

# Create external config file for the certificate
cat > cert.conf <<EOF

authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = $domain
DNS.2 = www.$domain

EOF

# Create SSL with self signed CA
openssl x509 -req \
        -nodes \
        -days 3650 \
        -sha256 \
        -in $domain.csr \
        -CA $rootCA_filename.crt \
        -CAkey $rootCA_filename.key \
        -CAcreateserial \
        -out $domain.crt \
        -extfile cert.conf


# Cleanup
rm ./csr.conf
rm ./cert.conf
