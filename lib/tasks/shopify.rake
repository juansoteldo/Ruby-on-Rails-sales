# frozen_string_literal: true

namespace :shopify do
  desc 'update all data'
  task update_all_data: :environment do
    CTD::Shopify.update_all_data
  end

  desc 'update products and variants by pulling data from Shopify API'
  task update_products_and_variants: :environment do
    CTD::Shopify.update_products_and_variants
  end

  desc 'update variant ids for tattoo sizes by pulling data from Shopify API'
  task update_tattoo_sizes: :environment do
    CTD::Shopify.update_tattoo_sizes
  end
end
