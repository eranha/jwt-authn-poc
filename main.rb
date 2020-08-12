# frozen_string_literal: true

require_relative 'authenticate_jwt'
require_relative 'token_claim_value_provider'
require_relative 'public_key_provider'
require 'jwt'

# generate key to sign the token
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
  iss: 'self-signed'
)

# define public key provider that will be injected to the authenticator
public_key_provider = PublicKeyProvider.new(rsa_private.public_key)

authenticate_jwt = AuthenticateJwt.new
authenticate_jwt.(
  token: token,
    token_claim_value_provider: claim_value_provider,
    token_validator_ext: nil, # no token validation extension is required
    public_key:                 public_key_provider.public_key,
    verification_options:       {algorithm: 'RS256'}
)
