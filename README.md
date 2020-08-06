# jwt-authn-poc
 JWT authenticator that validate a token and also accepts a validator extension.
 The POC demonstrate how you can atuhenticate a self signed simple JWT (demonstrated in `main.rb`) and simply by injecting Google's public key provider `GooglePublicKeyProvider` and GCE identity token validator extension `GCETokenValidatorExtension`, one can auhenticate GCE token using the same JWT authenticator class. (demonstrated in `gce_main.rb`).
 Standard claims are validated against `TokenClaimValueProvider` 
 
 
### Simple Token
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

# define public key provider that will be injected to the authenticator
public_key_provider = PublicKeyProvider.new(rsa_private.public_key)

authenticate_jwt = AuthenticateJwt.new
authenticate_jwt.(
          token: token,
          token_claim_value_provider: claim_value_provider,
          token_validator_ext: nil, # no token validation extension is required
          public_key_provider: public_key_provider,
          algorithm: 'RS256'
```

### GCE Identity Token
```
# issue an identity identity in GCE and save it in token.txt file
token = File.open('token.txt').read

# decode the token without veiriicaiton to extract the `kid` header claim
kid = decoded_token[1]['kid']

# construct google pubic key provider
google_cert_url = 'https://www.googleapis.com/oauth2/v1/certs'
google_public_key_provider = GooglePublicKeyProvider.new(google_cert_url, kid)

# construct the expected standard claims that will be injected to the authenticator
claim_value_provider = TokenClaimValueProvider.new(
  sub: '114729809789815358648',
  aud: 'conjur',
  iss: 'https://accounts.google.com'
)

# construct GCE token validator extension that will be injected to the authenticator
token_validation_ext = GCETokenValidatorExtension.new

AuthenticateJwt.new.(
  token:                      token,
  token_claim_value_provider: claim_value_provider,
  token_validator_ext:        token_validation_ext,
  public_key_provider:        google_public_key_provider,
  algorithm:                  'RS256'
)
```

### GCP Service Account Self Signed Token
The below code snippet depicts how to validate a JWT token signed by GCP Service Account.
To find more inforamtion on how to crater JWT and sign it using the Service Account private follow the below link:
[Authentication between services](https://cloud.google.com/endpoints/docs/openapi/service-account-authentication)
```
# Create and sign a JWT token using GCP service account key and save it in token.txt file
token = File.open('token.txt').read

# decode the token without verification to extract the `kid` header claim
decoded_token = JWT.decode(token, nil, false)
token_headers = decoded_token[1]
kid = token_headers['kid']
token_claims = decoded_token[0]

# construct google pubic key provider
google_cert_url = "https://www.googleapis.com/robot/v1/metadata/x509/#{token_claims['iss']}"
google_public_key_provider = GooglePublicKeyProvider.new(google_cert_url, kid)

# construct the expected standard claims that will be injected to the authenticator
claim_value_provider = TokenClaimValueProvider.new(
  sub: '108551114425891493254',
  aud: 'conjur/host/my_service',
  iss: token_claims['iss']
)
```
