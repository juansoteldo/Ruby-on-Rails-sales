# frozen_string_literal: true

module CTD
  class SeedImporter
    def self.import_marketing_emails
      yml_path = Rails.root.join("db/seeds/marketing_emails.yml")

      YAML.load_file(yml_path).each do |yml_email|
        existing = MarketingEmail.where(template_name: yml_email["template_name"]).order(:version)
        marketing_email = if existing.any? && existing.last.version >= yml_email["version"]
                            existing.last
                          else
                            MarketingEmail.new
                          end
        marketing_email.version ||= yml_email.delete("version")
        markdown_content = yml_email.delete("markdown_content")
        marketing_email.assign_attributes yml_email
        marketing_email.markdown_content ||= markdown_content.to_s.strip
        marketing_email.save!
      end
    end

    def self.import_tattoo_sizes
      yml_path = Rails.root.join("db/seeds/tattoo_sizes.yml")

      YAML.load_file(yml_path).each do |yml_size|
        name = yml_size.delete("name")
        existing = TattooSize.where(name: name)

        existing.first_or_create! do |size|
          template_name = yml_size.delete("quote_template_name")
          quote_email = MarketingEmail.find_by_template_name(template_name)
          raise "Cannot find MarketingEmail = `#{template_name}`" unless quote_email

          size.quote_email_id = quote_email.id
          size.assign_attributes(yml_size)
          size.save!
        end
      end
    end
  end
end
