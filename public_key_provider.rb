# frozen_string_literal: true

class PublicKeyProvider
  def initialize(public_key)
    @public_key = public_key
  end

  attr_reader :public_key
end
