# frozen_string_literal: true

class BoxMailer < ApplicationMailer
  default from: "orders@customtattoodesign.ca"

  add_template_helper(ApplicationHelper)
  track open: true, click: true, utm_params: true

  def quote_email(request, marketing_email = MarketingEmail.quote_for_request(request))
    return unless request.user

    if Settings.emails.use_cm_for_auto_quote_emails
      tattoo_size = request.tattoo_size.name.downcase
      smart_email_id = TransactionalEmail.find_by(name: 'general_auto_quote').smart_id
      if request.first_time?
        smart_email_id = TransactionalEmail.find_by(name: 'first_time_auto_quote').smart_id
      elsif tattoo_size == "full sleeve"
        smart_email_id = TransactionalEmail.find_by(name: 'full_sleeve_auto_quote').smart_id
      elsif tattoo_size == "half sleeve"
        smart_email_id = TransactionalEmail.find_by(name: 'half_sleeve_auto_quote').smart_id
      elsif tattoo_size == "extra small"
        smart_email_id = TransactionalEmail.find_by(name: 'extra_small_auto_quote').smart_id
      end
      CampaignMonitorActionJob.perform_later(smart_email_id: smart_email_id, user: request.user, method: "send_transactional_email")
      return
    end

    @request = request.decorate
    @marketing_email = marketing_email.decorate
    @user = @request.user

    @variant = MostlyShopify::Variant.find(request.tattoo_size.deposit_variant_id.to_i).first
    raise "Cannot find variant with ID #{request.tattoo_size.deposit_variant_id}" if @variant.nil?

    @variant = MostlyShopify::VariantDecorator.decorate(@variant)

    track user: @request.user,
          utm_campaign: marketing_email.template_name
    mail(to: @request.user.email,
         subject: marketing_email.subject_line,
         from: marketing_email.from,
         bcc: Settings.emails.notification_recipients,
         display_name: marketing_email.from.gsub(/<.+>/, ""))
  end

  def marketing_email(request, marketing_email = MarketingEmail.find(1))
    return unless request.user

    @request = request.decorate
    @marketing_email = marketing_email.decorate

    @variant = MostlyShopify::Variant.find(request.tattoo_size.deposit_variant_id.to_i).first if request.tattoo_size
    @variant ||= MostlyShopify::Variant.find(request.variant.to_i).first if request.variant
    @variant = MostlyShopify::VariantDecorator.decorate(@variant) unless @variant.nil?

    @user = @request.user

    track user: @request.user,
          utm_campaign: marketing_email.template_name

    reply_to = if @request.converted? || @request.salesperson.nil? || @request.salesperson == Salesperson.system
                 marketing_email.from
               else
                 @request.salesperson.email
               end

    mail(to: @request.user.email,
         subject: marketing_email.subject_line,
         from: marketing_email.from,
         reply_to: reply_to,
         display_name: marketing_email.from.gsub(/<.+>/, ""))
  end

  def confirmation_email(request)
    return if Settings.emails.use_cm_for_confirmation_emails
    return unless request.user

    @request = request.decorate
    @user = @request.user
    track user: @user

    mail(to: @user.email,
         from: Settings.emails.lee,
         subject: "Thank you, Let's Get Started! Custom Tattoo Design",
         display_name: "Lee Roller")
  end

  def opt_in_email(request)
    # opt in email disabled by Declyn request at 12.08.2021
    # because company wants switch opt-in email to campaign monitor. 
    return

    # return unless request&.user

    # @request = request.decorate
    # @user = request.user
    # track user: @user

    # mail(
    #   to: @user.email,
    #   from: Settings.emails.lee,
    #   subject: "E-Mail opt-in Custom Tattoo Design",
    #   display_name: "Lee Roller"
    # )
  end

  def final_confirmation_email(request)
    return if Settings.emails.use_cm_for_confirmation_emails
    return unless request.user

    @request = request
    @user = @request.user

    track user: @user

    mail(to: @user.email,
         from: Settings.emails.lee,
         subject: "Thank you for your business Custom Tattoo Design",
         display_name: "Lee Roller")
  end
end

require "redcarpet"
require "redcarpet/render_strip"
