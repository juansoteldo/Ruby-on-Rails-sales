class Webhook < ApplicationRecord
  acts_as_paranoid

  include AASM
  serialize :params
  serialize :headers

  after_create_commit :queue!

  scope :uncommitted, -> { where.not(aasm_state: "committed") }

  aasm do
    state :fresh, initial: true
    state :queued
    state :committed
    state :failed

    event :queue, after: :queue_job do
      transitions from: [:fresh, :failed], to: :queued
    end

    event :commit, before: :associate, after: :clear_art_samples! do
      transitions from: [:fresh, :queued, :failed], to: :committed
    end

    event :fail, before: :record_failure do
      transitions from: [:fresh, :queued], to: :failed
    end
  end

  def perform!
    return unless ["fresh", "queued", "failed"].include?(aasm_state)
    perform_job
  end

  def perform_job
    job_class.perform_now(webhook: self)
    true
  rescue => e
    fail! "#{e.message}\n#{e.backtrace.join("\n")}"
    raise(e) if Rails.application.config.debugging
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
      CreateRequestJob
    elsif source == "Shopify" && action_name == "orders_create"
      CommitShopifyOrderJob
    elsif source == "Calendly" && action_name == "events_create"
      UpdateEventJob
    end
  end

  def params
    super.with_indifferent_access
  end

  private

  def record_failure(message)
    update_column :last_error, message
  end

  def clear_art_samples!
    new_params = params.dup
    (1..10).each do |x|
      key = "art_sample_#{x}".to_sym
      next unless new_params.key?(key)
      new_params[key] = nil
    end
    update_column :params, new_params
  end
end
