require "base64"

module Base64Filter
  def base64_encode (input)
    Base64.encode64(input)
  end
end

Liquid::Template.register_filter(Base64Filter) # register filter globally
