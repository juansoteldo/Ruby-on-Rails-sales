# frozen_string_literal: true
require 'services/campaign_monitor'

class CmController < ApplicationController
  protect_from_forgery prepend: true
  respond_to :json

  def update_subscriptions
    data = JSON.parse(request.body.read)
    Services::CampaignMonitor.process_webhook_events(data)
  end
end