# frozen_string_literal: true

class BoxMailer < ApplicationMailer
  default from: "orders@customtattoodesign.ca"

  layout "marketing_email"

  add_template_helper(ApplicationHelper)

  def marketing_email(request, marketing_email = MarketingEmail.find(1))
    return unless request.user
    @request = request
    @user = @request.user
    track user: @user
    track utm_content: marketing_email.template_name

    reply_to = if @request.converted? || @request.salesperson.nil?
                 marketing_email.from
               else
                 @request.salesperson.email
               end

    mail(to: @user.email,
         subject: marketing_email.subject_line,
         from: marketing_email.from,
         reply_to: reply_to,
         display_name: marketing_email.from.gsub(/<.+>/, ""),
         template_path: marketing_email.template_path,
         template_name: marketing_email.template_name)
  end

  def confirmation_email(request)
    return unless request.user
    @request = request.decorate
    @user = @request.user
    track user: @user

    mail(to: @user.email,
         from: "leeroller@customtattoodesign.ca",
         subject: "Thank you, Let's Get Started! Custom Tattoo Design",
         display_name: "Lee Roller")
  end

  def opt_in_email(request)
    return unless request&.user
    @request = request.decorate
    @user = request.user
    track user: @user

    mail(
      to: @user.email,
      from: "leeroller@customtattoodesign.ca",
      subject: "E-Mail opt-in Custom Tattoo Design",
      display_name: "Lee Roller"
    )
  end

  def final_confirmation_email(request)
    return unless request.user
    @request = request
    @user = @request.user

    track user: @user

    mail(to: @user.email,
         from: "leeroller@customtattoodesign.ca",
         subject: "Thank you for your business Custom Tattoo Design",
         display_name: "Lee Roller")
  end
end
