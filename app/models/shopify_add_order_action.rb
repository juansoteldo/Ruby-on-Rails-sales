# frozen_string_literal: true

class ShopifyAddOrderAction < ApplicationRecord
  belongs_to :salesperson
  belongs_to :webhook
end
