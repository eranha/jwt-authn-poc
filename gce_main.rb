require_relative 'authenticate_jwt'
require_relative 'token_claim_value_provider'
require_relative 'public_key_provider'
require_relative 'google_public_key_provider'
require_relative 'gce_token_validator_extension'
require 'jwt'


token = File.open('token.txt').read
decoded_token = JWT.decode(token, nil, false)
token_headers = decoded_token[1]
token_claims = decoded_token[0]
claim_value_provider = TokenClaimValueProvider.new(
  sub: '114729809789815358648',
  aud: 'conjur',
  iss: 'https://accounts.google.com'
)

puts 'token claims'
token_claims.each do |key, value|
  puts "\tkey => #{key}, value => #{value}"
end

google_cert_url = 'https://www.googleapis.com/oauth2/v1/certs'

AuthenticateJwt.new.(
  token:                      token,
  token_claim_value_provider: claim_value_provider,
  token_validator_ext:        GCETokenValidatorExtension.new,
  public_key_provider:        GooglePublicKeyProvider.new(google_cert_url, token_headers['kid']),
  algorithm:                  'RS256'
)
