# frozen_string_literal: true

class Admin::EventsController < Admin::BaseController
  # GET /requests
  # GET /requests.json
  def index
    authorize(Admin::EventsController)
    @events = policy_scope(Event)
  end
end
