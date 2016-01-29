class Admin::ShopifyController < Admin::BaseController
  def products
    @products = Shopify::Product.all
  end

  def variants
    if params[:request_id]
      @request = Request.find(params[:request_id])
    end
    @groups = Shopify::Group.all.reject{ |group|
      group.products.count == 0
    }
  end

  def customers
    if params[:email]
      Shopify::Customer.search(email: params[:email])
    end

  end

  def customer
    if params[:email]
      @customer = Shopify::Customer.search(email: params[:email])
    else
      @customer = Shopify::Customer.search(id: params[:customer_id])

    end
    User.where(email: params[:email]).update_all( shopify_id: @customer.id ) unless @customer.nil?
  end

  def orders
    if params[:customer_id]
      customer = Shopify::Customer.search(id: params[:customer_id]).first
      @orders = Shopify::Order.search(email: customer.email)
    elsif params[:email]
      @orders = Shopify::Customer.search(email: params[:email]).first.orders
    else
      @orders = []
    end
  end
end

require 'shopify/product'
require 'shopify/group'
require 'shopify/customer'
