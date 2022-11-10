# frozen_string_literal: true

namespace :shopify do
  desc 'get products from Shopify API and save output to file'
  task get_products: :environment do
    products = ShopifyAPI::Product.all(session: AppConfig.shopify_session)
    f = File.new('tmp/all_products.rb', 'w')
    f << products
    f.close
    puts 'done'
  end

  desc 'get variants from Shopify API and save output to file'
  task get_variants: :environment do
    products = ShopifyAPI::Product.all(session: AppConfig.shopify_session)
    all_variants = []
    for product in products
      variants = ShopifyAPI::Variant.all(session: AppConfig.shopify_session, product_id: product.id)
      all_variants << variants
    end
    f = File.new('tmp/all_variants.erb', 'w')
    f << all_variants
    f.close
    puts 'done'
  end

  desc 'update products and variants by pulling data from Shopify API'
  task update_products_and_variants: :environment do
    Product.destroy_all
    Variant.destroy_all

    products = ShopifyAPI::Product.all(session: AppConfig.shopify_session)
    for product in products
      next if product.product_type.end_with? 'Final Payment'
      Product.create(
        id: product.id,
        title: product.title,
        handle: product.handle
      )
      variants = product.variants
      for variant in variants
        Variant.create(
          id: variant.id,
          product_id: variant.product_id,
          title: variant.title,
          price: variant.price,
          fulfillment_service: variant.fulfillment_service,
          option1: variant.option1,
          option2: variant.option2,
          option3: variant.option3,
        )
      end
    end
  end

  desc 'update variant ids for tattoo sizes by pulling data from Shopify API'
  task update_tattoo_sizes: :environment do
    variants = Variant.where(option1: 'no', option2: 'no')
    for variant in variants
      next if variant.fulfillment_service === 'gift_card'
      size = variant.size
      tattoo_size = TattooSize.find_by(name: size)
      if tattoo_size
        tattoo_size.update(deposit_variant_id: variant.id)
      end
    end
  end

  desc "flatten shopify order data"
  task :flatten_shopify_order_data, [:order_id] => :environment do |t, args|
    # Example: rake shopify:flatten_shopify_order_data\[4593098752193\]
    args.with_defaults(:order_id => '4590702100673')
    order_id = args[:order_id]
    order = ShopifyAPI::Order.find(order_id)
    result = {}
    result = flatten_object(order)
    puts result.to_json
  end
end

def flatten_object(object)
  result = {}
  return object if !is_shopify_object? object
  object.attributes.each do |key, value|
    if is_shopify_object? value
      value.attributes.each do |nested_key, nested_value|
        result[key] = {}
        result[key][nested_key.to_sym] = nested_value
        if is_shopify_object? nested_value
          result[key][nested_key.to_sym] = flatten_object(nested_value)
        end
      end
    elsif value.class.to_s == 'Array' && !value.empty?
      result[key] = flatten_array(value)
    else
      result[key] = value
    end
  end
  return result
end

def flatten_array(array)
  result = []
  for value in array
    result << flatten_object(value)
  end
  return result
end

def is_shopify_object?(value)
  return value.class.to_s.start_with? 'ShopifyAPI::'
end

