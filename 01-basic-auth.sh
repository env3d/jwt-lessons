#!/bin/bash

echo "content-type: text/plain"

if [ -z "$HTTP_AUTHORIZATION" ]
then
    echo "status: 401"
    echo "WWW-Authenticate: Basic realm=\"Please provide user id and password\""
    echo
    echo "Please login"
    exit 1
fi

# Extracts userid/password
CRED=$(echo -n $HTTP_AUTHORIZATION | grep -i basic | sed -E 's/.*[Bb][Aa][Ss][Ii][Cc] (.*)/\1/')
if [ -z "$CRED" ]
then
    echo "status: 401"
    echo "WWW-Authenticate: Basic realm=\"Please provide user id and password\""
    echo
    echo "We only accept BASIC authentication"
    exit 1
fi

# The $CRED variable has content, run base64 decode and extract
echo "status: 200"
echo 

USERID=$(echo "$CRED" | base64 -d | cut -f 1 -d ':')
PASSWORD=$(echo "$CRED" | base64 -d | cut -f 2 -d ':')

# Normally - we would perform userid/password looking now
# In this simple example, we simply output a welcome message

echo "User ${USERID} welcome!"
    
