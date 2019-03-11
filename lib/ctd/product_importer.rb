# frozen_string_literal: true

module CTD
  class ProductImporter
    def initialize; end

    def import(csv_path)
      product = nil
      @csv = CSV.foreach(csv_path, headers: true) do |row|
        title = row['Title']
        type = row['Type']
        unless title.nil? || title.strip == ''
          group_name = title.sub('Final Payment', '').sub('Deposit', '').strip
          group = ProductGroup.find_or_create_by(name: group_name)

          puts "Creating product `#{title}`"
          product = group.products.find_or_create_by(
            handle: row['Handle'],
            name: title,
            is_deposit: row['Handle'].include?('deposit'),
            is_final_payment: row['Handle'].include?('final'),
            product_type: type
          )
        end

        if product.nil?
          puts "Skipping #{title}"
          next
        end

        puts "  Adding variant color=#{row['Option1 Value']}, cover=#{row['Option2 Value']}"
        variant = product.product_variants.create(
          sku: row['Variant SKU'].gsub(/\D/, ''),
          price: row['Variant Price'].to_f
        )

        unless type == 'Gift Card'
          variant.has_color = (row['Option1 Value'] == 'yes')
          variant.has_cover_up = (row['Option2 Value'] == 'yes')
          variant.save!
        end
      end
    end
  end
end

require 'csv'
