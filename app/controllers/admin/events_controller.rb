# frozen_string_literal: true

class Admin::EventsController < Admin::BaseController
  # GET /requests
  # GET /requests.json
  def index
    @events = policy_scope(Event)
  end
end
