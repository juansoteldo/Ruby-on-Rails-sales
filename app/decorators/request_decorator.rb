class RequestDecorator < Draper::Decorator
  delegate_all

  def full_notes
    "Name: #{object.full_name || "Not specified"}
Email Address: #{object.user.email}
First Tattoo? #{object.is_first_time ? "Yes" : "No"}
Gender? #{object.gender&.titleize || "Not specified"}
In Color? #{object.has_color ? "Yes" : "No"}
Position? #{object.position}

Description:
#{object.description}"
  end

end
