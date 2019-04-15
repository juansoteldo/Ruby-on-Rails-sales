class EventDecorator < Draper::Decorator
  delegate_all

  def contact_methods
    method = source[:answer_2] || "Phone"
    method.split("\n")
  end

end
