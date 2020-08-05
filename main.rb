require_relative 'authenticate_jwt'
require_relative 'token_claim_value_provider'
require_relative 'public_key_provider'
require 'jwt'

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
)
