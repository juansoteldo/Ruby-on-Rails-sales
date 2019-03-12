# frozen_string_literal: true

class SalesTotal < ApplicationRecord
  belongs_to :salesperson, optional: true
end
