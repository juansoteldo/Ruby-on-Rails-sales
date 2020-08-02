# frozen_string_literal: true

# Decorates the Event class for the UI
class EventDecorator < Draper::Decorator
  delegate_all

  def contact_methods
    method = source[:answer_2] || "Phone"
    method.split("\n")
  end
end
