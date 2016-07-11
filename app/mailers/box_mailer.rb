class BoxMailer < ActionMailer::Base
	default from: 'orders@customtattoodesign.ca'
 
  def reminder_email(email)
    mail(to: email,
         bcc: Rails.application.config.action_mailer_bcc,
         subject: 'Lee Roller Owner / Custom Tattoo Design',
         reply_to: 'leeroller@customtattoodesign.ca',
         display_name: 'Lee Roller')
  end

  def confirmation_email(email)
    mail(to: email,
         bcc: Rails.application.config.action_mailer_bcc,
         reply_to: 'leeroller@customtattoodesign.ca',
         subject: 'Custom Tattoo Design - Order Confirmation',
         display_name: 'Lee Roller')
  end

  def final_confirmation_email(email)
  	@user = User.find_by_email(email)
  	return unless @user

    @request = @user.requests.first
    mail(to: email,
         bcc: Rails.application.config.action_mailer_bcc,
         reply_to: 'leeroller@customtattoodesign.ca',
         subject: 'Custom Tattoo Design - Thank You',
         display_name: 'Lee Roller')
  end

end
