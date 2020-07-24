class RequestDecorator < Draper::Decorator
  delegate_all

  def full_name
    names = [first_name, last_name].reject(&:nil?)
    return nil unless names.any?

    names.map(&:titleize).join(" ")
  end

  def full_notes
    "Name: #{object.full_name || 'Not specified'}
Email Address: #{object.user.email}
Position: #{object.position}
Style: #{object.style}
Size: #{object.size}
Gender: #{object.gender&.titleize || 'Not specified'}
First Tattoo? #{object.is_first_time ? 'Yes' : 'No'}
In Color? #{object.has_color ? 'Yes' : 'No'}

Description:
#{object.description}"
  end
end
