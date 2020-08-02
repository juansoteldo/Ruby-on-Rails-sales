# frozen_string_literal: true

# Application base ActiveRecord class
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
