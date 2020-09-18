# frozen_string_literal: true

YAML.load_file(Rails.root.join("db/seeds/tattoo_sizes.yml")).each do |yml_size|
  name = yml_size.delete("name")
  existing = TattooSize.where(name: name)
  puts "#{existing.any? ? 'Updating' : 'Creating'} #{name} size"

  existing.first_or_create! do |size|
    template_name = yml_size.delete("quote_template_name")
    quote_email = MarketingEmail.find_by_template_name(template_name)
    raise "Cannot find MarketingEmail = `#{template_name}`" unless quote_email

    size.quote_email_id = quote_email.id
    size.assign_attributes(yml_size)
    size.save!
  end
end
