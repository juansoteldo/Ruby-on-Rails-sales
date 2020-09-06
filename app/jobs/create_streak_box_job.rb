# frozen_string_literal: true

# Creates a streak box based on a request
class CreateStreakBoxJob < ApplicationJob
  def perform(request)
    return unless Settings.streak.create_boxes

    box = MostlyStreak::Box.new_with_name(request.user.email)
    box.update(notes: request.description)
    request.update_columns streak_box_key: box.key
    return if !Rails.env.production? && !Settings.emails.deliver_start_design

    RequestMailer.start_design_email(request).deliver_later
  end
end
