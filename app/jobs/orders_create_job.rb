# frozen_string_literal: true

require "shopify_api"

class OrdersCreateJob < WebhookJob
  def perform(args)
    super
    source_order = ShopifyAPI::Session.temp(domain: ENV["SHOPIFY_URL"], api_version: "2020-01", token: nil) do
      ShopifyAPI::Order.new(params)
    end
    order = MostlyShopify::Order.new source_order
    order.update_request!
    @webhook.commit!(order.request_id)
  end
end