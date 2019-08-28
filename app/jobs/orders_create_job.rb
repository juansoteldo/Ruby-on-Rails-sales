# frozen_string_literal: true

require "shopify_api"

class OrdersCreateJob < ApplicationJob
  queue_as :webhook

  def perform(webhook)
    source_order = ShopifyAPI::Order.new(webhook.params)
    order = MostlyShopify::Order.new source_order
    order.update_request!
    webhook.commit!(order.request_id)
  end
end