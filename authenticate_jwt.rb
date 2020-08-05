# frozen_string_literal: true

require 'command_class'
require 'jwt'

class AuthenticateJwt
  extend CommandClass::Include

  class InvalidAudience < RuntimeError; end
  class InvalidSubject < RuntimeError; end
  class InvalidIssuer < RuntimeError; end
  class InvalidIssuedAt < RuntimeError; end
  class TokenExpired < RuntimeError; end

  command_class(
    dependencies: {
    },
    inputs: %i[
      token
      token_claim_value_provider
      token_validator_ext
      public_key_provider
      algorithm
    ]
  ) do

    def call
      validate_exp_claims
      validate_iat_claims
      validate_audience_claim
      validate_subject_claim
      validate_issuer_claim
      validate_token_ext
    end

    private

    def validate_token_signature
      puts 'validate_token_signature'
      true
    end

    def validate_exp_claims
      puts 'validate_exp_claims'
      begin
        decoded_token = JWT.decode(@token,
                                   @public_key_provider.public_key,
                                   true,
                                   algorithm: @algorithm)
      rescue JWT::ExpiredSignature
        # Handle expired token, e.g. logout user or deny access
        raise TokenExpired
      end
    end

    def validate_iat_claims
      puts 'validate_exp_claims'
      begin
        # Add iat to the validation to check if the token has been manipulated
        decoded_token = JWT.decode(@token,
                                   @public_key_provider.public_key,
                                   true,
                                   verify_iat: true,
                                   algorithm: @algorithm)
      rescue JWT::InvalidIatError
        # Handle invalid token, e.g. logout user or deny access
        raise InvalidIssuedAt
      end
    end

    def validate_audience_claim
      puts 'validate_audience_claim'
      aud = @token_claim_value_provider.Audience
      begin
        # Add aud to the validation to check if the token has been manipulated
        decoded_token = JWT.decode(@token,
                                   @public_key_provider.public_key,
                                   true,
                                   aud: aud,
                                   verify_aud: true,
                                   algorithm: @algorithm)
      rescue JWT::InvalidAudError
        # Handle invalid token, e.g. logout user or deny access
        raise InvalidAudience
      end
      true
    end

    def validate_subject_claim
      puts 'validate_subject_claim'
      sub = @token_claim_value_provider.Subject
      begin
        # Add sub to the validation to check if the token has been manipulated
        decoded_token = JWT.decode(@token,
                                   @public_key_provider.public_key,
                                   true,
                                   sub: sub,
                                   verify_sub: true,
                                   algorithm: @algorithm)
      rescue JWT::InvalidSubError
        # Handle invalid token, e.g. logout user or deny access
        raise InvalidSubject
      end
    end

    def validate_issuer_claim
      puts 'validate_issuer_claim'
      iss = @token_claim_value_provider.Issuer
      begin
        # Add iss to the validation to check if the token has been manipulated
        decoded_token = JWT.decode(@token,
                                   @public_key_provider.public_key,
                                   true,
                                   iss: iss,
                                   verify_iss: true,
                                   algorithm: @algorithm)
      rescue JWT::InvalidIssuerError
        # Handle invalid token, e.g. logout user or deny access
        raise InvalidIssuer
      end
    end

    def validate_token_ext
      puts 'validate_token_ext'
      if @token_validator_ext
        @token_validator_ext.valid?(@token)
      end
    end
  end
end
