# frozen_string_literal: true

ShopifyAPI::Base.site = ENV.fetch("SHOPIFY_URL", Rails.application.credentials[:shopify][:url])