# jwt-authn-poc
 JWT authenticator that validate a token and also accepts a validator extension.
 The POC demonstrate how you can atuhenticate a self signed simple JWT (demonstrated in `main.rb`) and simply by injecting Google's public key provider `GooglePublicKeyProvider` and GCE identity token validator extension `GCETokenValidatorExtension`, one can auhenticate GCE token using the same JWT authenticator class. (demonstrated in `gce_main.rb`).
 Standard claims are validated against `TokenClaimValueProvider` 
 
 
### Simple Token
The below snippet depicts how authenticate a self signed JWT token by injecting that claim values and public key providers to the authenticator.  
```
# generate private to sign the token
rsa_private = OpenSSL::PKey::RSA.generate 2048

# define token expiration
exp = Time.now.to_i + 4 * 3600

# token claims
exp_payload = { 
  iss: 'self-signed',
  aud: 'my_service',
  sub: 'foo_bar', 
  exp: exp 
}

# issue decoded signed token 
token = JWT.encode exp_payload, rsa_private, 'RS256'

# define the expected claim values
claim_value_provider = TokenClaimValueProvider.new(
  sub: 'foo_bar',
  aud: 'my_service',
  iss: 'self-signed')

authenticate_jwt = AuthenticateJwt.new
authenticate_jwt = AuthenticateJwt.new
authenticate_jwt.(
  token: token,
    token_claim_value_provider: claim_value_provider,
    token_validator_ext: nil, # no token validation extension is required
    public_key:                 rsa_private.public_key,
    verification_options:       {algorithm: 'RS256'}
)
```

### GCE Identity Token
The below code snippet depicts how to authenticate GCE identity token signed by Google. Each instance has a unique JSON Web Token (JWT) that includes details about the instance as well as Google's RS256 signature. Your applications can verify the signature against Google's [public Oauth2 certificates](https://www.googleapis.com/oauth2/v1/certs) to confirm the identity of the instance with which they have established a connection.
For more information on GCE instance identity follow: [Verifying the Identity of Instances](https://cloud.google.com/compute/docs/instances/verifying-instance-identity). For more information on how to obtain instance identity token follow: [Obtaining the instance identity token](https://cloud.google.com/compute/docs/instances/verifying-instance-identity#request_signature)
```

# run curl inside the GCE instance 
# curl -H "Metadata-Flavor: Google" \
# 'http://metadata/computeMetadata/v1/instance/service-accounts/default/identity?audience=conjur/host-my/service&format=full'
# copy the curl output and save it in token.txt file
token = File.open('token.txt').read


# construct google pubic key provider
google_cert_url = 'https://accounts.google.com'
google_public_key_provider = GooglePublicKeyProvider.new(google_cert_url)

# construct the expected standard claims that will be injected to the authenticator
claim_value_provider = TokenClaimValueProvider.new(
  sub: '114729809789815358648',
  aud: 'conjur/host-my/service',
  iss: 'https://accounts.google.com'
)

# construct GCE token validator extension that will be injected to the authenticator
token_validation_ext = GCETokenValidatorExtension.new

AuthenticateJwt.new.(
  token:                        token,
    token_claim_value_provider: claim_value_provider,
    token_validator_ext:        token_validation_ext,
    public_key:                 nil, # public key is taken from the [:jwks] in verification_options
    verification_options:       google_public_key_provider.verification_options
)

```

### GCP Service Account Self Signed Token
The below code snippet depicts how to authenticate a JWT token signed by GCP [`Service Account`](https://cloud.google.com/iam/docs/understanding-service-accounts).
For more inforamtion on how to create JWT token and sign it using the [`Service Account` private key](https://cloud.google.com/iam/docs/understanding-service-accounts#managing_service_account_keys) follow the link:
[Authentication between services](https://cloud.google.com/endpoints/docs/openapi/service-account-authentication).
For more information on `Service Acccount` Keys follow: [Creating and managing service account keys](https://cloud.google.com/iam/docs/creating-managing-service-account-keys). For code refrence in python using [google-auth-client](https://github.com/googleapis/google-auth-library-python) python lib, on how to generate Service Account self signed token, please reffer to: [Code Reference](https://github.com/eranha/jwt-authn-poc/blob/master/issue_sa_token.py)
```
# Create and sign a JWT token using GCP service account key and save it in token.txt file
token = File.open('token.txt').read

# decode the token without verification to extract the `kid` header claim
decoded_token = JWT.decode(token, nil, false)
token_headers = decoded_token[1]
kid = token_headers['kid']
token_claims = decoded_token[0]

# construct google service account pubic key provider
google_cert_url = 'https://www.googleapis.com/robot/v1/metadata/x509/'
google_public_key_provider = GCPServiceAccountPublicKeyProvider.new(
  google_cert_url << token_claims['iss'], kid
)

# construct the expected standard claims that will be injected to the authenticator
claim_value_provider = TokenClaimValueProvider.new(
  sub: '108551114425891493254',
  aud: 'conjur/host/my_service',
  iss: token_claims['iss']
)

# construct GCE token validator extension that will be
# injected to the authenticator.
token_validation_ext = GCETokenValidatorExtension.new

AuthenticateJwt.new.(
      token:                        token,
      token_claim_value_provider:   claim_value_provider,
      token_validator_ext:          token_validation_ext,
      public_key:                   google_public_key_provider.public_key,
      verification_options:         {algorithms:           ['RS256']}
)
```
