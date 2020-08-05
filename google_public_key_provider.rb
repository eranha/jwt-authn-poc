require 'open-uri'
require 'json'

class GooglePublicKeyProvider
  def initialize(url, kid)
    raw = JSON.parse open(url) { |io| io.read }
    certificate = OpenSSL::X509::Certificate.new raw[kid]
    @public_key = certificate.public_key
  end

  attr_reader :public_key
end
