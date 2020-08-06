require_relative '../authenticate_jwt'
require_relative '../token_claim_value_provider'
require_relative '../public_key_provider'
require_relative 'google_public_key_provider'
require_relative 'gce_token_validator_extension'
require 'jwt'


# issue an identity otekn in GCE and save it in token.txt file
token = File.open('token.txt').read

# decode the token without verification to extract the `kid` header claim
decoded_token = JWT.decode(token, nil, false)
token_headers = decoded_token[1]
kid = token_headers['kid']
token_claims = decoded_token[0]

# construct google pubic key provider
google_cert_url = 'https://www.googleapis.com/oauth2/v1/certs'
google_public_key_provider = GooglePublicKeyProvider.new(google_cert_url, kid)

# construct the expected standard claims that will be injected to the authenticator
claim_value_provider = TokenClaimValueProvider.new(
  sub: '114729809789815358648',
  aud: 'conjur',
  iss: 'https://accounts.google.com'
)


puts 'token claims'
token_claims.each do |key, value|
  puts "\tkey => #{key}, value => #{value}"
end

# construct GCE token validator extension that will be
# injected to the authenticator.
token_validation_ext = GCETokenValidatorExtension.new

AuthenticateJwt.new.(
  token:                      token,
    token_claim_value_provider: claim_value_provider,
    token_validator_ext:        token_validation_ext,
    public_key_provider:        google_public_key_provider,
    algorithm:                  'RS256'
)
