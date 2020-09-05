class TattooSize < ApplicationRecord
  belongs_to :quote_email, class_name: "MarketingEmail"

  scope :defined, -> { where.not size: 0 }

  def variant
    return nil if deposit_variant_id.nil?

    @variant ||= MostlyShopify::Variant.find(deposit_variant_id)
  end

  def self.defined_size_names
    Rails.cache.fetch("tattoo_size_names", expires_in: 24.hours) do
      defined.map(&:name)
    end
  end

  def self.default
    TattooSize.find_by_size(0)
  end

  def self.for_request(request)
    return find_by_deposit_variant_id(request.deposit_variant) if request.deposit_variant

    tattoo_size = find_by_name(request.size)
    tattoo_size ||= default
    return tattoo_size if tattoo_size.size <= 0
    return tattoo_size if request.style != "Realistic" || tattoo_size.sleeve?

    tattoo_size.size == 5 ? tattoo_size : find_by_size(tattoo_size.size + 1)
  end

  def quote_email
    @quote_email = super
    @quote_email ||= MarketingEmail.find_by_template_name("general_quote_email")
  end

  def quote_template_name=(value)
    assign_attributes quote_email_id: MarketingEmail.find_by_template_name(value)
  end

  def quote_template_name
    quote_email&.template_name
  end
end
