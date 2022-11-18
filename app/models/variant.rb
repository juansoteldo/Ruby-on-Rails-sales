# frozen_string_literal: true

class Variant < ApplicationRecord
  belongs_to :product

  def name
    base_name = product.title[0, product.title.index('Design Deposit') - 1]
    base_name << ', Color' if color?
    base_name << ', Cover-up' if cover_up?
    base_name
  end

  def color?
    option1 == 'yes'
  end

  def cover_up?
    option2 == "yes"
  end

  def temporary?
    option3 == "yes"
  end

  def gift_card?
    fulfillment_service == 'gift_card'
  end

  def size
    product.title[0, product.title.index('Tattoo Design Deposit') - 1]
  end

  def product_type
    return 'preview' if product.title == 'Custom Tattoo Design Preview'
    return 'gift card' if product.title == 'Custom Tattoo Design Gift Card'
    return 'aftercare kit' if product.title == 'Ultimate Tattoo Aftercare Kit'
    return 'deposit' if product.title.end_with?('Design Deposit')
    return 'final payment' if product.title.end_with?('Final Payment')
    'unknown'
  end
end
