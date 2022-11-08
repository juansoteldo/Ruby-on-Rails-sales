# frozen_string_literal: true

class AppConfig < ActiveRecord::Base
  acts_as_singleton

  serialize :shopify_session

  def self.set_shopify_session(access_token)
    session = ShopifyAPI::Auth::Session.new(shop: Settings.shopify.shop_name, access_token: access_token)
    ShopifyAPI::Context.activate_session(session)
    AppConfig.instance.update!(shopify_access_token: access_token, shopify_session: session)
    session
  end

  def self.get_shopify_session
    return nil if AppConfig.instance.shopify_access_token.nil?
    session = set_shopify_session(AppConfig.instance.shopify_access_token)
    session
  end

  def self.shopify_session
    AppConfig.instance.shopify_session
  end

  def self.shopify_access_token
    AppConfig.instance.shopify_access_token
  end

end
