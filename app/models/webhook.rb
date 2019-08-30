class Webhook < ApplicationRecord
  include AASM
  serialize :params
  serialize :headers

  after_create :queue!

  scope :uncommitted, -> { where.not(aasm_state: "committed") }

  aasm do
    state :fresh, initial: true
    state :queued
    state :committed
    state :failed

    event :queue, after: :queue_job do
      transitions from: [:fresh, :failed], to: :queued
    end

    event :commit, before: :associate do
      transitions from: [:fresh, :queued], to: :committed
    end

    event :perform, before: :perform_job do
      transitions from: [:fresh, :queued, :failed], to: :committed
    end

    event :fail, before: :record_failure do
      transitions from: [:queued], to: :failed
    end
  end

  def perform_job
    job_class.perform_now(webhook: self)
  rescue StandardError => e
    update_columns last_error: "#{e.message}\n#{e.backtrace}", aasm_state: "failed"
    false
  end

  def queue_job
    job_class.perform_later(webhook: self)
  end

  def associate(request_id)
    update_column :request_id, request_id
  end

  def job_class
    if source == "WordPress" && action_name == "requests_create"
      RequestCreateJob
    elsif source == "Shopify" && action_name == "orders_create"
      OrdersCreateJob
    elsif source == "Calendly" && action_name == "events_create"
      UpdateEventJob
    end
  end
end
