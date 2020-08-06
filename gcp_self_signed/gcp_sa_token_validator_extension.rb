require 'jwt'

class GCETokenValidatorExtension
  def valid?(token)
    puts 'TokenValidatorExtension::valid?'
    decoded_token = JWT.decode(token, nil, false)
    claims = decoded_token[0]
    puts "account service email: #{claims['email']} validate against host: #{claims['aud']} annotation"
    true
  end
end