# frozen_string_literal: true

# Executes a Request action (method) asynchronously
class CampaignMonitorActionJob < ApplicationJob
  def perform(args)
    return if Settings.emails.disable_campaign_monitor

    smart_email_id = args[:smart_email_id]
    user = args[:user]
    async_method = args[:method]

    if smart_email_id && async_method && user
      Services::CampaignMonitor.send(async_method.to_sym, smart_email_id, user)
      return
    end

    if async_method && user
      Services::CampaignMonitor.send(async_method.to_sym, user) 
    end
  end
end
