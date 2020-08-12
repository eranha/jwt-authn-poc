require 'openid_connect'
require 'json'

class GooglePublicKeyProvider
  def initialize(url)
    provider = OpenIDConnect::Discovery::Provider::Config.discover!(url)
    @verification_options = { jwks:        {keys: provider.jwks},
                              algorithms:  provider.id_token_signing_alg_values_supported}
  end

  attr_reader :verification_options
end
