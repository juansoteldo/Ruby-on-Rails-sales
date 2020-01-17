# frozen_string_literal: true

class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_shopify_webhook, only: [:orders_create]

  def calendly
    UpdateEventJob.perform_later(params)
    head :ok
  end

  def requests_create
    RequestCreateJob.perform_later(wpcf7_params)
    head :ok
  end

  def orders_create
    OrdersCreateJob.perform_later(webhook: shopify_params, shop: shop_domain)
    head :ok
  end

  private

  def verify_shopify_webhook
    data = request.body.read
    hmac_header = request.headers['HTTP_X_SHOPIFY_HMAC_SHA256']
    digest = OpenSSL::Digest::Digest.new('sha256')
    webhook_key = ENV.fetch("SHOPIFY_WEBHOOK_KEY", Rails.application.credentials[:shopify][:webhook_key])
    calculated_hmac = Base64.encode64(
      OpenSSL::HMAC.digest(digest, webhook_key, data)).strip
    unless hmac_header == calculated_hmac
      head :unauthorized
    end
    request.body.rewind
  end

  def shop_domain
    request.headers['HTTP_X_SHOPIFY_SHOP_DOMAIN']
  end

  def shopify_params
    params.to_unsafe_h.except(:controller, :action, :type)
  end

  def wpcf7_params
    params.except(:controller, :action, :type).permit(
        :client_id, :position, :gender, :has_color, :is_first_time, :first_name, :last_name, :linker_param, :_ga, :art_sample_1, :art_sample_2,
        :art_sample_3, :description, :email, user_attributes: [ :marketing_opt_in, :presales_opt_in, :crm_opt_in ]
    )
  end
end
