# frozen_string_literal: true

class CmController < ApplicationController
  respond_to :json

  def unsubscribe
    data = JSON.parse(request.body.read)
    Services::CM.process_webhook_events(data)
  end
end