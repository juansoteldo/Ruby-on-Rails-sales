class WebhooksController < ApplicationController
	skip_before_filter :verify_authenticity_token
	before_action :verify_webhook
	#ADD ENV VARIABLE SHOPIFY_SECRET
	def orders_create
		OrdersCreateJob.perform_later(webhook: webhook_params, shop: shop_domain)
		head :ok
	end

	private
  
 	def verify_webhook
    data = request.body.read.to_s
    hmac_header = request.headers['HTTP_X_SHOPIFY_HMAC_SHA256']
    digest  = OpenSSL::Digest::Digest.new('sha256')
    calculated_hmac = Base64.encode64(OpenSSL::HMAC.digest(digest, ENV['SHOPIFY_SECRET'], data)).strip
    unless calculated_hmac == hmac_header
      head :unauthorized
    end
    request.body.rewind
  end
	
	def webhook_params
	  params.except(:controller, :action, :type)
	end
end