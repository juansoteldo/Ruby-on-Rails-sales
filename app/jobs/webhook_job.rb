# frozen_string_literal: true
require "sidekiq/worker"

class WebhookJob < ApplicationJob
  queue_as :webhook
  attr_accessor :webhook

  rescue_from Exception do |exception|
    Rails.logger.error "ERROR: #{exception}"
    @webhook&.update_column :last_error, exception.to_s
  end

  def perform(args)
    @webhook = args[:webhook]
  end

  def params
    @webhook.params
  end
end