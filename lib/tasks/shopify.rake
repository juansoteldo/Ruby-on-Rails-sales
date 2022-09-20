# frozen_string_literal: true

namespace :shopify do
  desc "Flatten Shopify Order Data"
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
