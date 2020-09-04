class RequestDecorator < Draper::Decorator
  include ActionView::Helpers::DateHelper

  delegate_all

  def full_name
    names = [first_name, last_name].reject(&:nil?)
    return nil unless names.any?

    names.map(&:titleize).join(" ")
  end

  def age_in_words
    time_ago_in_words(state_changed_at)
  end

  def full_notes
    "Name: #{full_name || 'Not specified'}
Email Address: #{user.email}
Position: #{position}
Style: #{style}
Size: #{size}
Gender: #{gender&.titleize || 'Not specified'}
First Tattoo? #{is_first_time ? 'Yes' : 'No'}
In Color? #{has_color ? 'Yes' : 'No'}

Description:
#{description}"
  end
end
