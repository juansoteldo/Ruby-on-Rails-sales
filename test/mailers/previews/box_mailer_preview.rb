# Preview all emails at http://localhost:3001/rails/mailers/box_mailer
class BoxMailerPreview < ActionMailer::Preview
  def initialize
    @request = Request.first
  end

  def opt_in_email; end
end
