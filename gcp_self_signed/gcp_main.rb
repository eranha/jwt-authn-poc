require_relative '../authenticate_jwt'
require_relative '../token_claim_value_provider'
require_relative '../gce/google_public_key_provider'
require_relative 'gcp_sa_token_validator_extension'
require 'jwt'


# issue an identity otekn in GCE and save it in token.txt file
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
