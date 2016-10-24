class AdminMailer < ActionMailer::Base
  default from: 'mailer@customtattoodesign.ca'

  def daily_blast_counts( counts )
    @counts = counts
    mail(to: 'brittany@customtattoodesign.ca',
         bcc: [ 'wojtek@grabski.ca', 'leeroller@customattoodesign.ca' ],
         subject: 'Marketing E-Mail Status Report'
    )
  end

end
