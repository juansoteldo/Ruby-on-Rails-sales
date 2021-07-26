# frozen_string_literal: true

# Executes a Request action (method) asynchronously
class CampaignMonitorActionJob < ApplicationJob
  def perform(args)
    user = args[:user]
    async_method = args[:method]

    Services::CampaignMonitor.send(async_method.to_sym, user) if async_method && user
  end
end
