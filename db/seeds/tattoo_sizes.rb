# frozen_string_literal: true

YAML.load_file(Rails.root.join("db/seeds/tattoo_sizes.yml")).each do |yml_size|
  puts "Creating #{yml_size['name']} size"
  TattooSize.where(name: yml_size.delete("name")).first_or_create! do |size|
    template_name = yml_size.delete("quote_template_name")
    quote_email = MarketingEmail.find_by_template_name(template_name)
    size.quote_email_id = quote_email.id
    size.assign_attributes(yml_size)
    size.save!
  end
end
