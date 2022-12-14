# frozen_string_literal: true

# Creates a streak box based on a request
class CreateStreakBoxJob < ApplicationJob
  def perform(request)
    return unless Settings.config.create_streak_boxes

    box = MostlyStreak::Box.new_with_name(request.user.email)
    box.update(notes: request.description)
    request.update_columns streak_box_key: box.key
    return if !Rails.env.production? && !Settings.emails.deliver_start_design

    recipients = [Salesperson.system.email]

    if Setting.auto_quoting.value && !request.auto_quotable?
      sales_manager = Salesperson.sales_manager
      if sales_manager
        box.set_stage_by_name('Leads')
        box.assign_to_salesperson(sales_manager)
        recipients << sales_manager.email
      end
    end

    RequestMailer.start_design_email(request, recipients).deliver_later
  end
end
