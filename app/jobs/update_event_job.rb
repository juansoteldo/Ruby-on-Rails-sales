# frozen_string_literal: true

# Creates or updates an event based on new webhook data
class UpdateEventJob < WebhookJob
  def perform(args)
    super
    event = Event.from_payload(params[:payload])
    event.save!
    webhook.commit!(event.request_id)
  end
end
