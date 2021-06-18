# frozen_string_literal: true
require 'campaign_monitor'

class CmController < ApplicationController
  respond_to :json

  def unsubscribe
    creds               = Rails.application.credentials
    marketing_list_id   = creds.cm[Rails.env.to_sym][:marketing_list_id]
    all_list_id         = creds.cm[Rails.env.to_sym][:all_list_id]
    combined            = [marketing_list_id, all_list_id]

    data = JSON.parse(request.body.read)
    events = data['Events']

    return unless combined.include? data['ListID']

    events.each do |event|
      next unless event['Type'] == 'Deactivate'

      email = event['EmailAddress']
      user = User.find_by_email email
      next unless user

      case data['ListID']
      when marketing_list_id
        user.update_column :marketing_opt_in, false
      when all_list_id
        user.update_column :presales_opt_in, false
      end
    end

  end
end