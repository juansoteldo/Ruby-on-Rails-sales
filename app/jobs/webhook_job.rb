# frozen_string_literal: true
require "sidekiq/worker"

class WebhookJob < ApplicationJob
  attr_accessor :webhook

  rescue_from Exception do |exception|
    Rails.logger.error "WEBHOOK ERROR: #{exception}\n#{exception.backtrace.join("\n")}"
    @webhook&.fail!(exception.to_s) unless @webhook&.committed?
  end

  def perform(args)
    @webhook = args[:webhook]
    @webhook.update_column :tries, @webhook.tries + 1
  end

  def params
    @params ||= @webhook.params
  end
end