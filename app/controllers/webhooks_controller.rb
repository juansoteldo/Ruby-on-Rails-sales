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
 		request.body.rewind
  	data = request.body.read
    hmac_header = request.headers['HTTP_X_SHOPIFY_HMAC_SHA256']
    digest  = OpenSSL::Digest::Digest.new('sha256')
    calculated_hmac = Base64.encode64(OpenSSL::HMAC.digest(digest, ENV['WEBHOOK_SIGNING'], data)).strip
    puts hmac_header
    unless hmac_header == calculated_hmac
      head :unauthorized
    end
    request.body.rewind
  end
	
	def webhook_params
	  params.except(:controller, :action, :type)
	end
end