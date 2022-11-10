class MostlyShopify::VariantDecorator < Draper::Decorator
  include ActionView::Helpers::NumberHelper

  def formatted_price
    number_to_currency(object.price, precision: 0)
  end

  def cart_redirect_url(request = nil)
    params = if request
               {
                 requestId: request.id,
                 clientId: request.client_id, linkerParam: request.linker_param, _ga: request._ga, uuid: request.uuid
               }
             else
               {}
             end
    product = Product.find(object.product_id)
    Rails.application.routes.default_url_options[:host] = ENV.fetch('APP_URL', 'https://localhost:3001')
    Rails.application.routes.url_helpers.cart_redirect_url(product.handle, object.id, params.to_query) # TODO: test to see if this encodes properly
  end
end
