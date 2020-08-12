require_relative '../authenticate_jwt'
require_relative '../token_claim_value_provider'
require_relative 'google_public_key_provider'
require_relative 'gce_token_validator_extension'
require 'jwt'


# issue an identity otekn in GCE and save it in token.txt file
token = File.open('gce/token.txt').read

# decode the token without verification to print claims
decoded_token = JWT.decode(token, nil, false)
token_headers = decoded_token[1]
token_claims = decoded_token[0]

# construct google pubic key provider
provider_uri = 'https://accounts.google.com'
google_public_key_provider = GooglePublicKeyProvider.new(provider_uri)

# construct the expected standard claims that will be injected to the authenticator
claim_value_provider = TokenClaimValueProvider.new(
  sub: '115072799640778267780',
  aud: 'conjur/my_account/my_host',
  iss: 'https://accounts.google.com'
)

puts 'token header claims'
token_headers.each do |key, value|
  puts "\tkey => #{key}, value => #{value}"
end

puts 'token claims'
token_claims.each do |key, value|
  puts "\tkey => #{key}, value => #{value}"
end

# construct GCE token validator extension that will be
# injected to the authenticator.
token_validation_ext = GCETokenValidatorExtension.new

AuthenticateJwt.new.(
  token:                        token,
    token_claim_value_provider: claim_value_provider,
    token_validator_ext:        token_validation_ext,
    public_key:                 nil,
    verification_options:       google_public_key_provider.verification_options
)
