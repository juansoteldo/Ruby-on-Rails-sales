# frozen_string_literal: true

require "shopify_api"

class OrdersCreateJob < WebhookJob
  def perform(args)
    super
    source_order = ShopifyAPI::Order.new(params)
    order = MostlyShopify::Order.new source_order
    order.update_request!
    webhook.commit!(order.request_id)
  end
end