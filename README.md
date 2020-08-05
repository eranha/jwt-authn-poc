# jwt-authn-poc
 JWT authenticator that validate a token and also accepts a validator extension.
 The POC demonstrate how you can atuhenticate a self signed simple JWT (demonstrated in `main.rb`) and simply by injecting Google's public key provider `GooglePublicKeyProvider` and GCE identity token validator extension `GCETokenValidatorExtension`, one can auhenticate GCE token using the same JWT authenticator class. (demonstrated in `gce_main.rb`).
 Standard claims are validated against `TokenClaimValueProvider` 
 
 
# Simple Token
```
rsa_private = OpenSSL::PKey::RSA.generate 2048
exp = Time.now.to_i + 4 * 3600
exp_payload = { iss: 'http://identity-provider',
                aud: 'my_service',
                sub: 'foobar', exp: exp }
token = JWT.encode exp_payload, rsa_private, 'RS256'
claim_value_provider = TokenClaimValueProvider.new(
  sub: 'foobar',
  aud: 'my_service',
  iss: 'http://identity-provider')

authenticate_jwt = AuthenticateJwt.new
authenticate_jwt.(
          token: token,
          token_claim_value_provider: claim_value_provider,
          token_validator_ext: nil,
          public_key_provider: PublicKeyProvider.new(rsa_private.public_key),
          algorithm: 'RS256'
```

# GCE Identity Token
```
token = File.open('token.txt').read
decoded_token = JWT.decode(token, nil, false)
token_headers = decoded_token[1]
token_claims = decoded_token[0]
claim_value_provider = TokenClaimValueProvider.new(
  sub: '114729809789815358648',
  aud: 'conjur',
  iss: 'https://accounts.google.com'
)

google_cert_url = 'https://www.googleapis.com/oauth2/v1/certs'

AuthenticateJwt.new.(
  token:                      token,
  token_claim_value_provider: claim_value_provider,
  token_validator_ext:        GCETokenValidatorExtension.new,
  public_key_provider:        GooglePublicKeyProvider.new(google_cert_url, token_headers['kid']),
  algorithm:                  'RS256'
)
```
