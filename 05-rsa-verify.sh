#!/bin/bash

# Given a JWT, verify with a public key

echo 'content-type: text/plain'
echo

JWT=$1

HEADER=$(echo -n $JWT | cut -d '.' -f 1)
PAYLOAD=$(echo -n $JWT | cut -d '.' -f 2)
SIG=$(echo -n $JWT | cut -d '.' -f 3 | tr '-' '+' | tr '_' '/')

# We assume that the public key is available in the current directory 
# and is named public.pem

# Conceptually, openssl descrypts the signature hash 
# and compares it with the hash of ${HEADER}.${PAYLOAD}
# That's why verification requires 3 pieces of information
#   1. public key
#   2. current signature to be decrypted
#   3. the content to generate the hash

openssl dgst -verify public.pem -signature <(echo -n "$SIG" | base64 -d)  <(echo -n "$HEADER.$PAYLOAD")
