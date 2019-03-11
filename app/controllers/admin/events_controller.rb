class Admin::EventsController < Admin::BaseController
  load_and_authorize_resource :events, class: Event

  # GET /requests
  # GET /requests.json
  def index
    @events = Event.all #where("starts_at > ?", Time.now)
  end

  private

end