class DeliveredEmail < ActiveRecord::Base
  belongs_to :request
  belongs_to :marketing_email
end
