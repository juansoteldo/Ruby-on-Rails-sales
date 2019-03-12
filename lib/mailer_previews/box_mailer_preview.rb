# frozen_string_literal: true

class BoxMailerPreview < ActionMailer::Preview
  def marketing_email
    BoxMailer.marketing_email random_request
  end

  def confirmation_email
    BoxMailer.confirmation_email random_request
  end

  private

  def random_request
    offset = rand(Request.count)
    Request.offset(offset).first
  end
end
