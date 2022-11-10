# frozen_string_literal: true

class BoxMailer < ApplicationMailer
  default from: "leeroller@customtattoodesign.ca"

  add_template_helper(ApplicationHelper)
  track open: true, click: true, utm_params: true

  def quote_email(request, marketing_email = MarketingEmail.quote_for_request(request))
    return unless request.user

    if Settings.config.auto_quote_emails == 'cm'
      # TODO: add transactional emails for test environment
      raise 'CM is not available for test environment' if ENV['RAILS_ENV'] == 'test'

      tattoo_size = request.tattoo_size.name.downcase

      if request.first_time?
        smart_email_id = TransactionalEmail.find_by(name: 'first_time_auto_quote').smart_id
      elsif tattoo_size == "full sleeve"
        smart_email_id = TransactionalEmail.find_by(name: 'full_sleeve_auto_quote').smart_id
      elsif tattoo_size == "half sleeve"
        smart_email_id = TransactionalEmail.find_by(name: 'half_sleeve_auto_quote').smart_id
      elsif tattoo_size == "extra small"
        smart_email_id = TransactionalEmail.find_by(name: 'extra_small_auto_quote').smart_id
      else
        smart_email_id = TransactionalEmail.find_by(name: 'general_auto_quote').smart_id
      end
      
      CampaignMonitorActionJob.perform_later(smart_email_id: smart_email_id, user: request.user, method: "send_transactional_email") unless Settings.config.transactional_emails == 'disabled'
    elsif Settings.config.auto_quote_emails == 'aws'
      @request = request.decorate
      @marketing_email = marketing_email.decorate
      @user = @request.user
  
      @variant = Variant.find(request.tattoo_size.deposit_variant_id.to_i)
      raise "Cannot find variant with ID #{request.tattoo_size.deposit_variant_id}" if @variant.nil?
  
      @variant = MostlyShopify::VariantDecorator.decorate(@variant)
  
      track user: @request.user,
            utm_campaign: marketing_email.template_name
      mail(to: @request.user.email,
           subject: marketing_email.subject_line,
           from: marketing_email.from,
           bcc: Settings.emails.auto_quote_bcc_recipients,
           display_name: marketing_email.from.gsub(/<.+>/, ""))
    else
      Rails.logger.warn 'Auto quote emails are turned off'
    end
  end

  def marketing_email(request, marketing_email = MarketingEmail.find(1))
    return unless request.user

    @request = request.decorate
    @marketing_email = marketing_email.decorate

    @variant = Variant.find(request.tattoo_size.deposit_variant_id.to_i).first if request.tattoo_size
    @variant ||= Variant.find(request.variant.to_i) if request.variant
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
    return if Settings.config.confirmation_emails != 'aws'
    return unless request.user

    @request = request.decorate
    @user = @request.user
    track user: @user

    mail(to: @user.email,
         from: Settings.emails.lee,
         subject: "Thank you, Let's Get Started! Custom Tattoo Design",
         display_name: "Lee Roller")
  end

  def final_confirmation_email(request)
    return if Settings.config.confirmation_emails != 'aws'
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
