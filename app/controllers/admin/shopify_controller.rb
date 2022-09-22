# frozen_string_literal: true
require "rake"

class Admin::ShopifyController < Admin::BaseController

  def index
    render :add_order
  end

  def add_order
    order_id = params["{:name=>\"order_id\", :class=>\"form_input\"}"]
    raise 'Failed. Order id was not specified.' if order_id.blank?
    order = ShopifyAPI::Order.find(order_id)
    raise "Failed. Order with id #{order_id} could not be found." if order.nil?
    order = flatten_object(order)
    raise "Failed. Webhook with order id #{order_id} already exists." if Webhook.find_by_source_id(order_id)
    webhook = Webhook.create! source: "Shopify", source_id: order_id, email: order['email'], params: order, action_name: 'orders_create'

    respond_to do |format|
      format.html { redirect_to admin_shopify_add_order_path, notice: "Shopify order #{order_id} was successfully added." }
      ShopifyAddOrderAction.create order_id: order_id, webhook_id: webhook.id, salesperson_id: current_salesperson.id, created_at: Time.now
    end

  rescue Exception => e
      respond_to do |format|
        format.html { redirect_to admin_shopify_add_order_path, :flash => { :error => "#{e}" } }
      end
  end
  
  def flatten_object(object)
    result = {}
    return object if !is_shopify_object? object
    object.attributes.each do |key, value|
      if is_shopify_object? value
        value.attributes.each do |nested_key, nested_value|
          result[key] = {}
          result[key][nested_key.to_sym] = nested_value
          if is_shopify_object? nested_value
            result[key][nested_key.to_sym] = flatten_object(nested_value)
          end
        end
      elsif value.class.to_s == 'Array' && !value.empty?
        result[key] = flatten_array(value)
      else
        result[key] = value
      end
    end
    return result
  end
  
  def flatten_array(array)
    result = []
    for value in array
      result << flatten_object(value)
    end
    return result
  end

  def is_shopify_object?(value)
    return value.class.to_s.start_with? 'ShopifyAPI::'
  end

end
