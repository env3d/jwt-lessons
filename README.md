# JWT Lessons 
All of these scripts are created as CGI to be deployed on the apache
webserver 2.4.x on Ubuntu 22.04

For these to work properly on your own server, you'll need to add the following
line to your vhost configuration:

```
# Pass Authorization header to CGI scripts
SetEnvIf Authorization "(.*)" HTTP_AUTHORIZATION=$1
```

If you are taking my class, you can also clone this repo on learn.operatoroverload server
under your own public_html directory.

# Password Authentication 

Let’s say you are creating a mobile app where you have an API backend for authorized users to call.
You’ll need to properly protect your backend.

A simple way to protect your backend is to require a userid/password combo to be sent to the backend
with every request.  We can do this via HTTP basic authentication
[https://developer.mozilla.org/en-US/docs/Web/HTTP/Authentication](https://developer.mozilla.org/en-US/docs/Web/HTTP/Authentication) 


Noticed that the Authorization header starts with the word Basic to indicate we are using
basic authentication.  The userid and password is encoded with the following scheme:  

```
base64(${userid}:${password})
```

To illustrate this, take a look at the [01-basic-auth.sh](01-basic-auth.sh) script.

```
# we encode the credentials using base64
#
$curl -v -H "Authorization: Basic $(echo -n 'env3d:abcde' | base64)" https://${SERVER_CGI_URL}/01-basic-auth.sh
```

OR

```
# You can simply put the credentials into the curl itself by 
# putting it between the protocol and the domain.
$curl https://env3d:abcde@https://${SERVER_CGI_URL}/01-basic-auth.sh
```

# Token Authentication
While password authentication on the API is easy to understand and implement,
it comes with several disadvantages:

 1. Password theft: your application will need to keep a copy of the userid/password in storage, which makes it easy to steal.
 1. Expiry: it’s hard to manage expiry dates on passwords if it is kept inside the application code.  Most tokens come with an expiry so it is only valid for a limited amount of time, lowering the risk of leaked tokens.
 1. Hard to share: in the case of OAuth2.0/OpenID Connect, the user’s id and password is never shared with the application since the user is redirected to the auth provider’s login page and only a token is returned.  This is impossible if we only have userid/password

The focus of our discussion will be on JWT, which allows information to be embedded inside the token itself,
and have a standard way for token authenticity to be verified.

The website [https://jwt.io](https://jwt.io) has lots of information on JWT,
as well as an interactive tool for creating and verifying you tokens.

## HMAC-SHA256 Signatures 
The script [02-hmac-token.sh](02-hmac-token.sh) is an example of a service where given the correct userid/password,
it returns a valid JWT.  

Other API/endpoint can now require a valid token to be passed before performing its functions.
An example of such an endpoint can be found at [03-jwt-protected.sh](03-jwt-protected.sh).
Try sending various JWTs to this endpoint to see how it works.

The interesting thing about this token is that it uses the HMAC-SHA256 signature.  At a high level,
it generates a hash value using a secret phrase.  If another party/script wants to verify that the
token has a valid signature, it’ll simply regenerate the signature and compare it against the
signature in the JWT.

Please note that the secret phrase will need to be shared between the producer of the JWT and
the consumer of the JWT.

## RSA-SHA256 Signatures 
Using HMAC-SHA256 is great if the producer and consumer of JWT is the same system and can share the
same secret.  However, if we the producer and consumer of the JWT are from different organizations,
then it is not practical to share the symmetric secret phrase.  Instead, we will make use of
public/private key infrastructure where we will sign the JWT with the producer’s private key.

The consumer can then verify the JWT using the producer’s public key.

To illustrate, the script [04-rsa-token.sh](04-rsa-token.sh) will produce a jwt with rsa-sha256 signature.  

You can verify it against the following public key:

```
----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAu1SU1LfVLPHCozMxH2Mo
4lgOEePzNm0tRgeLezV6ffAt0gunVTLw7onLRnrq0/IzW7yWR7QkrmBL7jTKEn5u
+qKhbwKfBstIs+bMY2Zkp18gnTxKLxoS2tFczGkPLPgizskuemMghRniWaoLcyeh
kd3qqGElvW/VDL5AaWTg0nLVkjRo9z+40RQzuVaE8AkAFmxZzow3x+VJYKdjykkJ
0iT9wCS0DRTXu269V264Vf/3jvredZiKRkgwlL9xNAwxXFg0x/XFw005UWVRIkdg
cKWTjpBP2dPwVZ4WWC+9aGVd+Gyn1o0CLelf4rEjGoXbAAEgAqeGUxrcIlbjXfbc
mwIDAQAB
-----END PUBLIC KEY-----
```

The script [05-rsa-verify.sh](05-rsa-verify.sh) performs this verification.

