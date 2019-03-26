# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'mailer@customtattoodesign.ca'

  layout 'mailer'
end

