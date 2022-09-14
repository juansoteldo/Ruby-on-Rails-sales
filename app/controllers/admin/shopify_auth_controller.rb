# frozen_string_literal: true

require 'shopify_api'

class Admin::ShopifyAuthController < Admin::BaseController

  def index
    authorize(Admin::ShopifyAuthController)
    @access_token = AppConfig.shopify_access_token
    @active_session = AppConfig.shopify_session
  end

  def login
    shop = request.headers['Shop']

    auth_response = ShopifyAPI::Auth::Oauth.begin_auth(shop: Settings.shopify.shop_name, redirect_path: '/admin/shopify_auth/callback')

    cookies[auth_response[:cookie].name] = {
      expires: auth_response[:cookie].expires,
      secure: true,
      http_only: true,
      value: auth_response[:cookie].value
    }

    head 307
    response.set_header('Location', auth_response[:auth_route])
  end

  def callback
    begin
      auth_result = ShopifyAPI::Auth::Oauth.validate_auth_callback(
        cookies: cookies.to_h,
        auth_query: ShopifyAPI::Auth::Oauth::AuthQuery.new(request.parameters.symbolize_keys.except(:controller, :action, :id))
      )
      
      cookies[auth_result[:cookie].name] = {
        expires: auth_result[:cookie].expires,
        secure: true,
        http_only: true,
        value: auth_result[:cookie].value
      }

      access_token = auth_result[:session].access_token
      AppConfig.set_shopify_session(access_token)
  
      head 307
      response.set_header('Location', '/admin/shopify_auth')
    rescue => e
      puts(e.message)  
      head 500
    end
  end
end
