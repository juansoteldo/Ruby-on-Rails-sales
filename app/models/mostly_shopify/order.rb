# frozen_string_literal: true

require "digest"
require 'shopify_api'
require "mostly_shopify/base"

module MostlyShopify
  class Order < Base
    DEFAULT_SALESPERSON_EMAIL = "brittany@customtattoodesign.ca"

    def update_request!(request = self.request)
      raise StandardError.new("cannot find request for #{order_status_url}") unless request

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

      if !sales_id.nil? && sales_id != request.quoted_by_id
        request.update_column :quoted_by_id, sales_id
      end

      @source.id == (is_deposit? ? request.deposit_order_id : request.final_order_id)
    end

    def request_id
      @request_id ||= note_value("req_id") || request_id_from_landing_site
    end

    def request_id=(value)
      @request_id = value
    end

    def request(reset_attribution: false)
      return @request if @request && !reset_attribution
      @request = Request.for_shopify_order(self, reset_attribution: reset_attribution)
      @request_id = @request.id if @request
      @request
    end

    def salesperson_id
      @salesperson_id ||= note_value("sales_id")
      return @salesperson_id if @salesperson_id
      return nil unless /salesid=(\d+)/ =~ landing_site
      @salesperson_id = landing_site.gsub(/.+salesid=(\d+).+/, "\\1")
    end

    def email
      @source.respond_to?(:email) ? @source.email : customer&.email
    end

    def has_request_id?
      !request_id.nil?
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
      Rails.cache.fetch("shopify/orders/" + digest, expires_in: expire_in) do
        ShopifyAPI::Order.all(params: params).map { |c| new(c) }
      end
    end

    def self.all(params)
      find_in_batches(params).map(&method(:new))
    end

    def self.count(params)
      digest = Digest::SHA256.base64digest params.inspect
      Rails.cache.fetch("shopify/orders/count/" + digest, expires_in: expire_in) do
        ShopifyAPI::Order.count(params: params)
      end
    end

    def self.find_in_batches(params)
      order_count = MostlyShopify::Order.count params
      params[:limit] ||= 250
      if params[:page]
        end_page = params[:page]
        start_page = params[:page]
      else
        end_page = (order_count / params[:limit].to_f).ceil
        start_page = 1
      end
      orders = []
      start_page.upto(end_page) do |page|
        params[:page] = page
        orders += ShopifyAPI::Order.all(params: params)
        Rails.logger.debug "Loaded #{params[:limit]} orders, sleeping for 0.55 seconds"
        sleep 0.55
      end
      orders
    end

    def self.deposits(params)
      digest = Digest::SHA256.base64digest params.inspect
      Rails.cache.fetch("shopify/orders/deposits/" + digest, expires_in: expire_in(6.hours)) do
        params[:created_at_min] ||= CTD::MIN_DATE.dup
        params[:created_at_max] ||= 1.day.ago.end_of_day

        params[:created_at_min] = [params[:created_at_min], CTD::MIN_DATE.dup].max

        params[:fields] = "customer,line_items,total_price,subtotal_price,note_attributes,created_at"

        Rails.logger.debug "Loading Shopify orders using #{params.inspect}"
        orders = MostlyShopify::Order.all(params)
        orders = orders.reject do |order|
          order.created_at < (params[:created_at_min]) || order.created_at > (params[:created_at_max])
        end.select do |order|
          order.line_items.any? { |li| !li.title.include? "Final" }
        end
        orders
      end
    end

    def self.attributed(params)
      digest = Digest::SHA256.base64digest params.inspect
      Rails.cache.fetch("shopify/orders/attributed/" + digest, expires_in: expire_in(6.hours)) do
        orders = MostlyShopify::Order.deposits(params)
        date_range = "Wed, 1 Jun 2016".to_date..Time.now
        orders = orders.select do |order|
          (order.note_value("sales_id") ||
            User.where(email: order.customer.email).joins(:requests).
              where(requests: { created_at: date_range }).any?)
        end

        orders
      end
    end

    def sales_id
      @sales_id ||= guess_sales_id
    end

    private

    def landing_site
      return nil unless @source.respond_to? :landing_site
      @source.landing_site
    end

    def guess_sales_id
      return 6 if created_at.to_date < "Tue, 7 Jun 2016".to_date
      return box_sales_id if box_sales_id
      return noted_sales_id if noted_sales_id
      return request_sales_id if request_sales_id
      puts "Cannot find sales id for shopify order with email #{email}" unless Rails.env.test?
      nil
    end

    def box_sales_id
      return @box_sales_id if @box_sales_id
      request = Request.for_shopify_order(self)
      if request&.quoted_by_id && request&.quoted_by_id != 6
        @box_sales_id = request.quoted_by_id
      end
      @box_sales_id ||= MostlyStreak::Box.find_by_email(email)&.salesperson&.id
    end

    def noted_sales_id
      @noted_sales_id ||= note_value("sales_id")
    end

    def request_sales_id
      return @request_sales_id if @request_sales_id
      @request_sales_id ||= request&.quoted_by_id
    end

    def request_id_from_landing_site
      return nil unless /reqid=(\d+)/ =~ landing_site
      id = landing_site.gsub(/.+reqid=(\d+).+/, "\\1")
      @request_id = id unless id.to_s.blank?
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
