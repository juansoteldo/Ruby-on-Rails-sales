class TattooSize < ApplicationRecord
  belongs_to :quote_email, class_name: "MarketingEmail"

  def variant
    return nil if deposit_variant_id.nil?
    @variant ||= MostlyShopify::Variant.find(deposit_variant_id)
  end

  def self.default
    TattooSize.find_by_size(0)
  end

  def self.for_request(request)
    return find_by_deposit_variant_id(request.deposit_variant) if request.deposit_variant

    tattoo_size = find_by_name(request.size)
    tattoo_size ||= default
    return tattoo_size if tattoo_size.size <= 0
    return tattoo_size unless request.style == "Realistic"

    tattoo_size.size == 5 ? tattoo_size : find_by_size(tattoo_size.size + 1)
  end

  attr_reader :quote_email
  def quote_email
    @quote_email = MarketingEmail.find_by_template_name(quote_template_name)
    @quote_email ||= MarketingEmail.find_by_template_name("general_quote_email")
  end
end
