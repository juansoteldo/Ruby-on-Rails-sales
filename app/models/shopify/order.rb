require 'shopify/base'

class Shopify::Order < Shopify::Base
  def update_request
    if has_request_id?
      request = Request.where(id:request_id).first
    else
      request = Request.joins(:user).where(email: self.customer.email.downcase ).first
    end

    return unless request

    if request.can_convert? and is_deposit?
      request.convert
      request.update_attribute(:deposit_order_id, @source.id)
      request.update_attribute(:state_changed_at, @source.created_at)
    elsif request.can_complete? and is_final?
      request.complete
      request.update_attribute(:final_order_id, @source.id)
      request.update_attribute(:state_changed_at, @source.created_at)
    end

    if has_salesperson_id? and request.quoted_by_id.nil?
      request.update_attribute :quoted_by_id, salesperson_id
    end
  end

  def request_id
    note_value('req_id')
  end

  def salesperson_id
    note_value('sales_id')
  end

  def has_request_id?
    request_id != nil
  end

  def has_salesperson_id?
    salesperson_id != nil
  end

  def created_at
    Date.strptime(@source.created_at)
  end

  def sku
    skus.first
  end

  def skus
    @source.line_items.map{|li| li.sku }.uniq
  end

  def is_deposit?
    @source.line_items.any? { |line_item| line_item.title.include? 'Deposit' }
  end

  def is_final?
    @source.line_items.any? { |line_item| line_item.title.include? 'Final' }
  end

  def self.find(params)
    digest = Digest::SHA256.base64digest params.inspect
    Rails.cache.fetch('shopify/orders/' + digest, expires_in: 5.minutes) do
      ShopifyAPI::Order.find( :all, params: params ).map{ |c| self.new(c) }
    end
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

  private

  def note_value(attr_name)
    return nil unless @source.note_attributes

    @source.note_attributes.each do |note_attr|
      if note_attr.name == attr_name
        return note_attr.value if note_attr.value != 'undefined'
      end
    end
  end

end

require 'digest'
