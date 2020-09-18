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
    product = if !object.product.respond_to?(:handle)
                MostlyShopify::Product.for_variant(object)
              else
                object.product
              end
    Rails.application.routes.default_url_options[:host] = ENV.fetch("APP_HOST", "http://localhost:3000")
    Rails.application.routes.url_helpers.cart_redirect_url(product.handle, object.id, params)
  end
end
