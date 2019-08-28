class UpdateEventJob < ApplicationJob
  queue_as :webhook

  def perform(webhook)
    event = Event.from_payload(webhook.params[:payload])
    event.save!
    webhook.commit!(event.request_id)
  end
end
