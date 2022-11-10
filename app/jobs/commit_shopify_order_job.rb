# frozen_string_literal: true

require "shopify_api"

# Updates a Request based on Shopify order web hook data
class CommitShopifyOrderJob < WebhookJob
  def perform(args)
    super
    source_order = ShopifyAPI::Order.new(session: AppConfig.get_shopify_session)

    params.each do |key, value|
      source_order.instance_variable_set("@#{key}".to_sym, value)
    end

    order = MostlyShopify::Order.new(source_order)
    order.update_request!

    @webhook.commit!(order.request_id)
  end
end
