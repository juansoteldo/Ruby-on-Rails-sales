class BoxMailer < ActionMailer::Base
	default from: 'orders@customtattoodesign.ca'
 
  def reminder_email(email)
    mail(to: email, subject: 'Lee Roller Owner / Custom Tattoo Design')
  end

  def confirmation_email(email)
    mail(to: email, subject: 'Custom Tattoo Design - Order Confirmation')
  end

end