class DeliveredEmail < ActiveRecord::Base
  belongs_to :request
end
