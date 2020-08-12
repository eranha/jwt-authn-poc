require 'net/http'
require 'json'

class GCPServiceAccountPublicKeyProvider
  def initialize(url, kid)
    uri = URI(url)
    response = Net::HTTP.get(uri)
    certificate = OpenSSL::X509::Certificate.new JSON.parse(response)[kid]
    @public_key = certificate.public_key
  end
  attr_reader :public_key
end



