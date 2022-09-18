# frozen_string_literal: true

ShopifyAPI::Base.site = ENV.fetch("SHOPIFY_URL")
ShopifyAPI::Base.api_version = "2020-01"
