require 'openssl'
require 'base64'

class Salesperson < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :sales_totals

  def requests
    Request.quoted_or_contacted_by(self.id)
  end

  def deposited_requests
    requests.deposited
  end

  # Called by devise to allow users to be deactivated
  # http://www.rubydoc.info/github/plataformatec/devise/master/Devise/Models/Authenticatable
  def active_for_authentication?
   super && is_active?
  end

  attr_accessor :orders, :total_sales

  def claim_requests_with_email(email, after = 3.months.ago)
    Request.joins(:user).where( "email = ? AND requests.created_at > ? AND requests.contacted_by_id IS NULL", email, after)
        .update_all contacted_by_id: self.id
  end

  def self.with_sales(params)

    salespeople = Salesperson.all.to_a.map do |salesperson|
      params.each do |key, value|
        salesperson.class.send(:attr_accessor, "#{key}_sales") unless instance_variable_defined?("@#{key}_sales")
        salesperson.class.send(:attr_accessor, "#{key}_count") unless instance_variable_defined?("@#{key}_count")
        salesperson.instance_variable_set "@#{key}_sales", nil
        salesperson.instance_variable_set "@#{key}_count", nil
      end
      salesperson
    end

    params.each do |key, param|
      grouped_orders = Shopify::Order.attributed(param).group_by(&:sales_id)
      grouped_orders.select{|id, orders| id != "" }.map do |id, orders|
        salesperson = salespeople.find{|s| s.id == id }
        sales = orders.inject(0) {|sum,o| sum + o.total_price.to_f.round(2)}
        salesperson.instance_variable_set "@#{key}_sales", sales
        salesperson.instance_variable_set "@#{key}_count", orders.count
        salesperson.orders = orders
        salespeople << salesperson unless salespeople.find{|s| s.id == id }
      end
    end
    salespeople
  end

  def self.sales_by_date(params)
    params[:limit] ||= 250
    self.all_with_shopify_orders_by_email(params)
  end

  def streak_api_key
    return '' if encrypted_streak_api_key.nil?

    decipher = OpenSSL::Cipher::AES.new(128, :CBC)
    decipher.decrypt
    decipher.key = Rails.application.config.streak_api_cipher_random_key
    decipher.iv = Rails.application.config.streak_api_cipher_random_iv

    decipher.update(Base64.decode64(encrypted_streak_api_key)) + decipher.final
  end

  def streak_api_key=(new_key)
    return if new_key.blank?

    self.encrypted_streak_api_key = Salesperson.encrypt_streak_api_key(new_key)
  end

  def self.encrypt_streak_api_key(new_key)
    cipher = OpenSSL::Cipher::AES.new(128, :CBC)
    cipher.encrypt
    cipher.key = Rails.application.config.streak_api_cipher_random_key
    cipher.iv = Rails.application.config.streak_api_cipher_random_iv

    Base64.encode64( cipher.update(new_key) + cipher.final )
  end

end
