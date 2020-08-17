# frozen_string_literal: true

require 'jwt'
require 'openid_connect'
require 'json'

# retrieve keys and algorithms
provider_uri = 'https://accounts.google.com'
provider = OpenIDConnect::Discovery::Provider::Config.discover!(provider_uri)
verification_options = { jwks: { keys: provider.jwks },
                         algorithms:  provider.id_token_signing_alg_values_supported }

token = File.open('.access-token').read

# add the claims we want to verify
verification_options.merge(
  sub: '115072799640778267780',
  aud: 'conjur/my_account/my_host',
  iss: 'https://accounts.google.com'
)

begin
  JWT.decode(token,
             # passing nil as public key, the key
             # will be taken from jwks: in verification_options
             nil,
             true,
             verification_options)
rescue JWT::ExpiredSignature
  puts 'Token expired!'
rescue JWT::DecodeError => e
  puts 'Decode token error: ' + e.inspect
rescue => e
  puts 'Invalid token: ' + e.inspect
else
  puts 'token is valid'
end

