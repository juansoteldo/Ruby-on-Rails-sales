class UpdateEventJob < ApplicationJob
  queue_as :webhook

  def perform(params)
    event = Event.from_payload(params[:payload])
    event.save!
  end
end
