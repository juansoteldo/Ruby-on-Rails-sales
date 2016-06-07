class BoxMailer < ActionMailer::Base
	default from: 'orders@customtattoodesign.ca'
 
  def reminder_email(email)
    mail(to: email, bcc: 'sales@customtattoodesign.ca, KaylaMckee@customtattoodesign.ca', subject: 'Lee Roller Owner / Custom Tattoo Design')
  end

  def confirmation_email(email)
    mail(to: email, bcc: 'sales@customtattoodesign.ca, KaylaMckee@customtattoodesign.ca', subject: 'Custom Tattoo Design - Order Confirmation')
  end

end