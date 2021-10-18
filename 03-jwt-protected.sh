#!/bin/bash

# This script will only return 200 if a valid JWT is 
# provided in the Authorzation: Bearer header.  
# Otherwise it would return 401 Unauthorized

# We are return JSON, so better set the header properly
echo "content-type: application/json"

if [ -z "$HTTP_AUTHORIZATION" ]
then
    echo "status: 401"
    echo
    echo "{\"message\":\"Please provide Authorization: Bearer header\"}"
    exit 1
fi

# Extracts userid/password
JWT=$(echo -n $HTTP_AUTHORIZATION | grep -i bearer | sed -E 's/.*[Bb][Ee][Aa][Rr][Ee][Rr] (.*)/\1/')
if [ -z "$JWT" ]
then
    echo "status: 401"
    echo
    echo "{\"message\":\"We only accept Bearer tokens\"}"
    exit 1
fi

# To verify a JWT, we simply run produce our own signature using the hmac-256 algorithm
# We need compare our signature with the one provided by the JWT to see if they match
# compare the signature

# First extract all the different parts of the JWT
HEADER=$(echo -n $JWT | cut -d '.' -f 1)
PAYLOAD=$(echo -n $JWT | cut -d '.' -f 2)
SIG=$(echo -n $JWT | cut -d '.' -f 3)

# Now generate our own signature
GEN_SIG=$(echo -n "${HEADER}.${PAYLOAD}" | openssl dgst -sha256 -hmac "here_is_my_secret" -binary | base64 | tr '+' '-' | tr '/' '_' | tr -d '=')

# Finally, we compare them
if [ $GEN_SIG == $SIG ]
then
    echo "status: 200"
    echo

    # We use the jq utility to reformat the payload for output.  
    echo "$PAYLOAD" | base64 -d | jq '.'
else
    echo "status: 401"
    echo
 
    # Shows that the sigs are different, and therefore
    # token is invalid.  I'm using the bash heredoc 
    # feature to allow multi-line string

    OUTPUT=$(cat <<EOF
{
  "message": "invalid token",
  "jwt_sig": "$SIG",
  "gen_sig": "$GEN_SIG"
}
EOF
)
   echo "$OUTPUT"
fi
