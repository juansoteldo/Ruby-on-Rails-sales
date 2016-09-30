class MarketingEmail < ActiveRecord::Base
  has_many :delivered_emails
end
