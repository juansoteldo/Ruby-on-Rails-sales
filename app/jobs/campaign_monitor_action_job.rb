require 'exceptions'

# frozen_string_literal: true

# Executes a Request action (method) asynchronously
class CampaignMonitorActionJob < ApplicationJob
  def perform(args)
    return if Settings.config.campaign_monitor == 'disabled'

    smart_email_id = args[:smart_email_id]
    user = args[:user]
    list_title = args[:list_title]
    list_id = args[:list_id]
    async_method = args[:method]

    if smart_email_id && async_method && user
      Services::CampaignMonitor.send(async_method.to_sym, smart_email_id, user)
    elsif async_method && list_id && user
      Services::CampaignMonitor.send(async_method.to_sym, list_id, user)    
    elsif async_method && user
      Services::CampaignMonitor.send(async_method.to_sym, user)
    elsif async_method && list_title
      Services::CampaignMonitor.send(async_method.to_sym, list_title)
    elsif async_method && list_id
      Services::CampaignMonitor.send(async_method.to_sym, list_id)
    else
      raise Exceptions::InvalidArguments.new("Invalid arguments: #{args}")
    end

    # TODO: refactor code
          # new_args = args.delete(:method)
          # async_method = args[:method]
          # Services::CampaignMonitor.send(async_method.to_sym, new_args)
  end
end
