# frozen_string_literal: true

yml_path = File.join(File.dirname(__FILE__), "marketing_emails.yml")

YAML.load_file(yml_path).each do |yml_email|
  existing = MarketingEmail.where(template_name: yml_email["template_name"]).order(:version)
  if existing.any? && existing.last.version >= yml_email["version"]
    puts "Found #{yml_email['template_name']}, updating"
    marketing_email = existing.last
  else
    puts "Couldn't find #{yml_email['template_name']}, creating"
    marketing_email = MarketingEmail.new
  end
  marketing_email.version ||= yml_email.delete("version")
  marketing_email.assign_attributes yml_email
  marketing_email.save!
end
