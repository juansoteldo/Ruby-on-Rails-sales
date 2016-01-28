class ShopifyController < ApplicationController
  def products
    @products = CTD::Shopify::Product.all
  end

  def variants
    if params[:request_id]
      @request = Request.find(params[:request_id])
    end
    @groups = CTD::Shopify::Group.all
  end
end

require 'ctd/shopify/product'
require 'ctd/shopify/group'
