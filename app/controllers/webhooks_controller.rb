# frozen_string_literal: true

class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_shopify_webhook, only: [:orders_create], if: -> { Rails.env.production? }

  def events_create
    safe_params = calendly_params
    payload = safe_params[:payload]
    create_webhook source: "Calendly",
                   source_id: payload["event"]["uuid"],
                   email: payload["invitee"]["email"],
                   params: safe_params
    head :ok
  end

  def requests_create
    safe_params = wpcf7_params
    create_webhook source: "WordPress",
                   source_id: nil,
                   email: safe_params[:email],
                   params: safe_params
    head :ok
  end

  def orders_create
    safe_params = shopify_params
    create_webhook source: "Shopify",
                   source_id: safe_params["id"],
                   email: safe_params["email"],
                   params: safe_params
    head :ok
  end

  private

  def create_webhook(args)
    Webhook.create source: args[:source], source_id: args[:source_id], action_name: action_name,
                   params: args[:params], referrer: request.referrer.to_s, email: args[:email],
                   headers: request.headers.env.select { |k, _| k =~ /^HTTP_/ }
  end

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

  def shopify_params
    params.to_unsafe_h.except(:controller, :action, :type)
  end

  def wpcf7_params
    params.except(:controller, :action, :type).permit(
      :client_id, :position, :gender, :has_color, :is_first_time, :first_name, :last_name, :linker_param, :_ga,
      :art_sample_1, :art_sample_2, :art_sample_3, :art_sample_4, :art_sample_5, :art_sample_6, :art_sample_7,
      :art_sample_8, :art_sample_9, :art_sample_10,
      :description, :email, user_attributes: [:marketing_opt_in, :presales_opt_in, :crm_opt_in]
    ).to_unsafe_h
end

  def calendly_params
    params.require(:payload).permit(event: [:uuid, :start_time, :end_time],
                                    invitee: [:uuid, :email, :first_name, :last_name, :text_reminder_number]).to_unsafe_h
  end
end
