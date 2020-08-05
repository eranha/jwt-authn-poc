class TokenClaimValueProvider
  def initialize(token_claim_values)
    @token_claim_values = token_claim_values
  end

  def Subject
    @token_claim_values[:sub]
  end

  def Issuer
    @token_claim_values[:iss]
  end

  def Audience
    @token_claim_values[:aud]
  end
end