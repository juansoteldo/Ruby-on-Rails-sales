class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :load_products

  def load_products
    @groups = CTD::Shopify::Group.all
  end
end

require 'ctd/shopify/product'
require 'ctd/shopify/group'
