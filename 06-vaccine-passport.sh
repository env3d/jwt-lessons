#!/bin/bash

# This script decodes Smart Health Card using the specs from
# outlined in https://spec.smarthealth.cards/
#
# To call this script:
#
# base64 sample-qr-code.png | curl --data @- https://${CGI_URL}/06-vaccine-passport.sh
#

# input base64 encoded barcode in stdin (POST parameter if called as CGI)
echo "content-type: text/plain"
echo

# NOTE: the - symbol represents stdin as a file.
#
# cat - reads from stdin, which is the base64 encoded version
# of the barcode.  We decode and pass to zbarimg to get the 
# data in the code.
CODE=$(cat - | base64 -d | zbarimg --raw -q - | cut -d '/' -f 2)

# This is a one-liner to convert the numeric string from QR code into JWT
# According to https://spec.smarthealth.cards/#encoding-chunks-as-qr-codes
B64=$(echo -n $CODE | fold -w2 | xargs -I{} echo "obase=16;{} + 45" | bc | xargs -I {} echo -e "\x{}" | tr -d '\n')

# Extracts the header and payload
HEADER=$(echo -n $B64 | tr '-' '+' | tr '_' '/' | cut -d '.' -f 1)
PAYLOAD=$(echo -n $B64 | tr '-' '+' | tr '_' '/' | cut -d '.' -f 2)

# The payload is compressed with zlib (zip), so we have to use zcat to decompress it.
# However, the payload is also without zlib header, so we need to append a dummy header
# before sending it to zcat
cat <(printf "\x1f\x8b\x08\x00\x00\x00\x00\x00\x00\x00") \
    <(echo "$PAYLOAD" | base64 -d 2>/dev/null) \
    | zcat 2>/dev/null | jq .

