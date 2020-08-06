require 'jwt'

class GCETokenValidatorExtension
  def valid?(token)
    puts 'TokenValidatorExtension::valid?: enter'
    valid = 0
    decoded_token = JWT.decode(token, nil, false)
    claims = decoded_token[0]
    compute_engine = claims['google']['compute_engine']
    puts 'compute_engine claim:'
    compute_engine.each do |key, value|
      puts "\tkey => #{key}, value => #{value}"
      case key
      when :instance_id
        valid -= 1 if value != '4015063098376718561'
      when :instance_name
        valid -= 1 if value != 'gce-identity--poc-instance'
      when :project_id
        valid -= 1 if value != 'refreshing-mark-284016'
      when :project_number
        valid -= 1 if value != '120811889825'
      when :zone
        valid -= 1 if value !='us-central1-a'
      end
    end
    puts "TokenValidatorExtension::valid?=>#{valid == 0}"
    valid == 0
  end
end