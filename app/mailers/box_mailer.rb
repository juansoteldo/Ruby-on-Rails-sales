class BoxMailer < ActionMailer::Base
	default from: 'orders@customtattoodesign.ca'
  layout 'marketing_email'
  def marketing_email( request, marketing_email = MarketingEmail.find(1) )
    @request = request
#    bcc = Rails.application.config.action_mailer_bcc
    bcc ||= []

    mail(to: request.user.email,
         bcc: bcc,
         subject: marketing_email.subject_line,
         from: marketing_email.from,
         display_name: marketing_email.from.gsub(/\<.+\>/, ''),
         template_path: marketing_email.template_path,
         template_name: marketing_email.template_name
    )
  end

  def confirmation_email(request)
    return unless request.user
    @request = request

    mail(to: request.user.email,
#         bcc: Rails.application.config.action_mailer_bcc,
         from: 'leeroller@customtattoodesign.ca',
         subject: 'Thank you, Let\'s Get Started! Custom Tattoo Design',
         display_name: 'Lee Roller')
  end

  def final_confirmation_email(request)
  	return unless request.user

    @request = request
    mail(to: email,
#         bcc: Rails.application.config.action_mailer_bcc,
         from: 'leeroller@customtattoodesign.ca',
         subject: 'Thank you for your business Custom Tattoo Design',
         display_name: 'Lee Roller')
  end

end
