# frozen_string_literal: true
require 'services/cm'

class CmController < ApplicationController
  respond_to :json

  def update_subscriptions
    data = JSON.parse(request.body.read)
    Services::CM.process_webhook_events(data)
  end
end