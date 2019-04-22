class OrdersCreateJob < ApplicationJob
  queue_as :webhook

  def perform(params)
    source_order = ShopifyAPI::Order.new(params[:webhook])
    order = MostlyShopify::Order.new source_order
    order.update_request
  end
end

require 'streak_api/box'
