# frozen_string_literal: true

require "sidekiq/worker"

# Abstract ActiveJob class that accepts web hook data and logs exceptions
class WebhookJob < ApplicationJob
  attr_accessor :webhook

  rescue_from Exception do |exception|
    Rails.logger.error "Webhook Error: #{exception}\n#{exception.backtrace.join("\n")}"
    @webhook&.fail!(exception.to_s) unless @webhook&.committed?
    raise exception if Rails.application.config.debugging
  end

  def perform(args)
    @webhook = args[:webhook]
    @webhook.update_column :tries, @webhook.tries + 1
  end

  def params
    @params ||= @webhook.params
  end
end
