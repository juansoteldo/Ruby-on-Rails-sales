class BoxMailer < ActionMailer::Base
	default from: 'orders@customtattoodesign.ca'
 
  def reminder_email(email)
  	#@name = "#{first_name} #{last_name}"
    mail(to: email, subject: 'Welcome to My Awesome Site')
  end
end