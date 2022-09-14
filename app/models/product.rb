# frozen_string_literal: true

class Product < ApplicationRecord
  has_many :variants, dependent: :destroy

  def final_payment?
    handle.include?('final')
  end

  def deposit?
    handle.include?('deposit')
  end
  
end
