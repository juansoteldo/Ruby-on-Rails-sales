# frozen_string_literal: true

# Represents a MarketingEmail sent to a User
class DeliveredEmail < ApplicationRecord
  belongs_to :request
  belongs_to :marketing_email

  before_create :deliver_if_necessary

  private

  def deliver_if_necessary
    return unless request.user.presales_opt_in

    BoxMailer.marketing_email(request, marketing_email).deliver_now
    assign_attributes sent_at: Time.now
  end
end
