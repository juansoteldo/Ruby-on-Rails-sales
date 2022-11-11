# frozen_string_literal: true

if Settings.shopify.app_type == 'custom'
  ShopifyAPI::Context.setup(
    api_key: Settings.shopify.api_key,
    api_secret_key: Settings.shopify.api_secret_key,
    host_name: Settings.shopify.host_name,
    scope: 'read_orders,read_products,read_all_orders',
    session_storage: ShopifyAPI::Auth::FileSessionStorage.new,
    is_embedded: false,
    is_private: false,
    api_version: '2022-07',
  )
elsif Settings.shopify.app_type == 'private'
  raise 'Failed to connect to Shopify API: private apps are deprecated, please use \'custom\' for shopify_app_type.'
else
  raise 'Failed to connect to Shopify API: shopify_app_type was not specified.'
end
