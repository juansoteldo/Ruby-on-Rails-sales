# frozen_string_literal: true

class UpdateEventJob < WebhookJob
  def perform(args)
    super
    event = Event.from_payload(params[:payload])
    event.save!
    webhook.commit!(event.request_id)
  end
end
