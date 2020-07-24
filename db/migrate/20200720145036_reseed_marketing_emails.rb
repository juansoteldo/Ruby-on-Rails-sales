class ReseedMarketingEmails < ActiveRecord::Migration[5.2]
  def up
    return if MarketingEmail.none? do |marketing_email|
      File.exist? Rails.root.join "app/views/box_mailer", marketing_email.template_path, marketing_email.template_name
    end
    require Rails.root.join("db/seeds/marketing_emails.rb") unless Rails.env.test?
  end
end
