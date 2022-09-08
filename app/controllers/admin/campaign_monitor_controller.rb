# frozen_string_literal: true

class Admin::CampaignMonitorController < Admin::BaseController
  # TODO: use before_action instead
  def initialize
    super
    @transactional_emails = TransactionalEmail.order(:id)
  end

  def index
    authorize(Admin::CampaignMonitorController)
  end

  def update
    authorize(Admin::CampaignMonitorController)
    data = params.except(:controller, :action, :type, :utf8, :_method, :authenticity_token, :commit)
                 .permit(:full_sleeve_auto_quote, :half_sleeve_auto_quote, :extra_small_auto_quote, :first_time_auto_quote, :general_auto_quote, :test)

    success = true
    data.each do |key, value|
      puts "#{key}: #{value}"
      email = TransactionalEmail.find_by(name: key)
      if email
        email.update({
          smart_id: value
        })
      else
        raise "Failed to update transactional email with name: #{key}"
        success = false
      end
    end

    respond_to do |format|
      if success
        format.html { redirect_to admin_campaign_monitor_path, notice: "Transactional emails were successfully updated." }
      else
        format.html { redirect_to admin_campaign_monitor_path, notice: "Cannot save your changes." }
      end
    end
  end
end
