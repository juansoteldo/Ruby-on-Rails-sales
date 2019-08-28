class Webhook < ApplicationRecord
  include AASM
  serialize :params
  serialize :headers

  after_create :queue!

  aasm do
    state :fresh, initial: true
    state :queued
    state :committed

    event :queue, after: :queue_job do
      transitions from: :fresh, to: :queued
    end

    event :commit, before: :associate do
      transitions from: [:fresh, :queued], to: :committed
    end

    event :perform, before: :perform_job do
      transitions from: [:fresh, :queued], to: :committed
    end
  end

  def perform_job
    job_class.perform_now(self)
  rescue StandardError => e
    update_column :last_error, "#{e.message}\n#{e.backtrace}"
  end

  def queue_job
    job_class.perform_later(self)
  end

  def associate(request_id)
    update_column :request_id, request_id
  end

  private

  def job_class
    if source == "WordPress" && action == "requests_create"
      RequestCreateJob
    elsif source == "Shopify" && action == "orders_create"
      OrdersCreateJob
    elsif source == "Calendly" && action == "calendly"
      UpdateEventJob
    end
  end
end
