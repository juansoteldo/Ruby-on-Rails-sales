# frozen_string_literal: true

require "openssl"
require "base64"

class Salesperson < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :sales_totals

  attr_reader :default
  def self.default
    @@default ||= find(1)
  end

  def requests
    Request.quoted_or_contacted_by(id)
  end

  # Called by devise to allow users to be deactivated
  # http://www.rubydoc.info/github/plataformatec/devise/master/Devise/Models/Authenticatable
  def active_for_authentication?
    super && is_active?
  end

  attr_accessor :orders, :total_sales

  def claim_requests_with_email(email, after = 3.months.ago)
    Request.joins(:user).where("email = ? AND requests.created_at > ? AND requests.contacted_by_id IS NULL", email, after)
           .update_all contacted_by_id: id
  end

  def self.with_sales(params)
    salespeople = Salesperson.all.to_a.map do |salesperson|
      params.each do |key, _value|
        salesperson.class.send(:attr_accessor, "#{key}_sales") unless instance_variable_defined?("@#{key}_sales")
        salesperson.class.send(:attr_accessor, "#{key}_count") unless instance_variable_defined?("@#{key}_count")
        salesperson.instance_variable_set "@#{key}_sales", nil
        salesperson.instance_variable_set "@#{key}_count", nil
      end
      salesperson
    end

    params.each do |key, param|
      grouped_orders = MostlyShopify::Order.attributed(param).group_by(&:sales_id)
      grouped_orders.select { |id, _orders| id != "" }.map do |id, orders|
        salesperson = salespeople.find { |s| s.id == id }
        sales = orders.inject(0) { |sum, o| sum + o.total_price.to_f.round(2) }
        salesperson.instance_variable_set "@#{key}_sales", sales
        salesperson.instance_variable_set "@#{key}_count", orders.count
        salesperson.orders = orders
        salespeople << salesperson unless salespeople.find { |s| s.id == id }
      end
    end
    salespeople
  end
end
