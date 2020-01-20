# frozen_string_literal: true

class StreakBoxCreateJob < ApplicationJob
  def perform(request)
    return if request.streak_box_key
    return unless request.user&.email
    return unless request.user.first_name&.present?

    box = MostlyStreak::Box.create(request.user.email)
    MostlyStreak::Box.update(box.key, notes: request.description)
    request.update_columns streak_box_key: box.key
    return unless Settings.emails.deliver_start_design
    RequestMailer.start_design_email(request).deliver_later
  end
end