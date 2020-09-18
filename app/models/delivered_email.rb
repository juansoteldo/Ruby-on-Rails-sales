# frozen_string_literal: true

# Represents a MarketingEmail sent to a User
class DeliveredEmail < ApplicationRecord
  include AASM

  aasm do
    state :fresh, initial: true
    state :delivered
    state :skipped
    state :failed

    event :deliver, before: :perform_delivery do
      transitions from: [:new, :failed], to: :delivered
    end

    event :fail, after: :record_failure do
      transitions from: :new, to: :failed
    end

    event :skip do
      transitions from: :new, to: :skipped
    end
  end
  belongs_to :request
  belongs_to :marketing_email

  after_create :deliver_or_skip

  private

  def deliver_or_skip
    request.user.presales_opt_in ? deliver! : skip!
  rescue Exception => e
    Honeybadger.notify exception
    fail!(e)
  end

  def record_failure(exception)
    update_column :exception, exception.to_s
  end

  def perform_delivery
    BoxMailer.marketing_email(request, marketing_email).deliver_now
    assign_attributes sent_at: Time.now
  end
end
