require 'shopify/base'

class Shopify::Order < Shopify::Base

  def created_at
    Date.strptime(@source.created_at)
  end

  def sku
    skus.first
  end

  def skus
    @source.line_items.map{|li| li.sku }.uniq
  end

  def self.search(params)
    ShopifyAPI::Order.find(params).map{ |c| self.new(c) }
  end

  def self.all(*params)
    self.shopify_orders(params).map{ |order| self.new(order) }
  end

  def self.shopify_orders params
      order_count    = ShopifyAPI::Order.count( :params => params )
      nb_pages       = (order_count / params[:limit].to_f).ceil
      orders         = []
      1.upto(nb_pages) do |page|
        params[:page] = page
        orders = orders + ShopifyAPI::Order.find( :all, :params => params )
      end
      orders
  end
end
