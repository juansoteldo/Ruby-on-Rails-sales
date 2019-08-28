# frozen_string_literal: true

require "digest"
require 'shopify_api'
require "mostly_shopify/base"

module MostlyShopify
  class Order < Base
    DEFAULT_SALESPERSON_EMAIL = "brittany@customtattoodesign.ca"

    def update_request!
      request = guessed_request
      raise "cannot find request for #{order_status_url}" unless request

      if request.can_convert? && is_deposit?
        request.convert
        request.update_columns deposit_order_id: @source.id,
                               state_changed_at: @source.created_at,
                               deposited_at: Time.now
      elsif request.can_complete? && is_final?
        request.complete
        request.update_columns final_order_id: @source.id,
                               state_changed_at: @source.created_at
      end

      if has_salesperson_id? && request.quoted_by_id.nil?
        request.update_column :quoted_by_id, salesperson_id
      end

      @source.id == (is_deposit? ? request.deposit_order_id : request.final_order_id)
    end

    def guessed_request
      request = Request.where(id: request_id).first if has_request_id?
      return request if request
      return nil unless @source.email
      Request.joins(:user).where("users.email LIKE ?", @source.email.downcase.strip).last
    end

    def request_id
      @request_id ||= note_value("req_id")
      return @request_id if @request_id
      return nil unless /reqid=(\d+)/ =~ landing_site
      @request_id = landing_site.gsub(/.+reqid=(\d+).+/, "\\1")
    end

    def salesperson_id
      @salesperson_id ||= note_value("sales_id")
      return @salesperson_id if @salesperson_id
      return nil unless /salesid=(\d+)/ =~ landing_site
      @salesperson_id = landing_site.gsub(/.+salesid=(\d+).+/, "\\1")
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
      @source.line_items.map(&:sku).uniq
    end

    def is_deposit?
      @source.line_items.any? { |line_item| line_item.title.include? "Deposit" }
    end

    def is_final?
      @source.line_items.any? { |line_item| line_item.title.include? "Final" }
    end

    def self.find(params)
      digest = Digest::SHA256.base64digest params.inspect
      Rails.cache.fetch("shopify/orders/" + digest, expires_in: 5.minutes) do
        ShopifyAPI::Order.all(params: params).map { |c| new(c) }
      end
    end

    def self.all(params)
      find_in_batches(params).map(&method(:new))
    end

    def self.count(params)
      digest = Digest::SHA256.base64digest params.inspect
      Rails.cache.fetch("shopify/orders/count/" + digest, expires_in: 5.minutes) do
        ShopifyAPI::Order.count(params: params)
      end
    end

    def self.find_in_batches(params)
      order_count = MostlyShopify::Order.count params
      params[:limit] ||= 250
      nb_pages       = (order_count / params[:limit].to_f).ceil
      orders         = []
      1.upto(nb_pages) do |page|
        params[:page] = page
        orders += ShopifyAPI::Order.all(params: params)
        sleep 0.55
      end
      orders
    end

    def default_salesperson; end

    def note_attribute(name)
      note_attributes.each do |note_attr|
        return note_attr.value if note_attr.name == name
      end
      nil
    end

    MIN_DATE = "2016-06-01T00:00:00-00:00".to_time

    def self.attributed(params)
      digest = Digest::SHA256.base64digest params.inspect
      expires_in = Rails.env.production? ? 6.hours : 0
      Rails.cache.fetch("shopify/orders/attributed/" + digest, expires_in: expires_in) do
        params[:limit] ||= Rails.env.production? ? "250" : "5"

        params[:created_at_min] ||= MIN_DATE
        params[:created_at_max] ||= 1.day.ago.end_of_day

        params[:created_at_min] = [params[:created_at_min], MIN_DATE.dup].max
        params[:created_at_max] = params[:created_at_max]

        params[:fields] = "customer,line_items,total_price,subtotal_price,note_attributes,created_at"

        orders = MostlyShopify::Order.all(params)
        orders = orders.select do |order|
          order.line_items.any? { |li| !li.title.include? "Final" } &&
              (order.note_attribute("sales_id") ||
                  User.where(email: order.customer.email).joins(:requests).
                      where(requests: { created_at: "Wed, 1 Jun 2016".to_date..Time.now }).any?)
        end

        default_salesperson = Salesperson.find_by(email: DEFAULT_SALESPERSON_EMAIL)
        sale_cutoff = (MIN_DATE.dup - 120.days)
        orders = orders.reject do |order|
          order.created_at < (params[:created_at_min]) || order.created_at > (params[:created_at_max])
        end.map do |order|
          order.sales_id = nil
          if order.created_at.to_date < "Tue, 7 Jun 2016".to_date
            order.sales_id = 6
          else
            noted_id = order.note_attribute("sales_id")

            if noted_id
              order.sales_id = noted_id.to_i
            else
              requests = Request.where(created_at: (sale_cutoff..Time.now)).where.not(quoted_by_id: nil).
                  joins(:user).where(users: { email: order.customer.email })
              order.sales_id = requests.first.quoted_by_id if requests.any?
            end
            order.sales_id ||= default_salesperson.id
          end
          order
        end
        orders
      end
    end

    private

    def landing_site
      return nil unless @source.respond_to? :landing_site
      @source.landing_site
    end

    def note_value(attr_name)
      return nil unless @source.respond_to? :note_attributes
      return nil unless @source.note_attributes

      @source.note_attributes.each do |note_attr|
        next unless note_attr.respond_to?(:name)
        next unless note_attr.name == attr_name
        return nil if note_attr.value == "undefined"

        return note_attr.value
      end
      nil
    end
  end
end
