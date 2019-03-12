# frozen_string_literal: true

class PublicController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :disable_cache, only: [:get_links]

  before_action :normalize_email
  before_action :validate_parameters, only: [:new_request]
  before_action :set_or_create_user_by_email, only: [:new_request, :get_links]
  before_action :set_salesperson_by_email, only: [:get_links]
  before_action :load_products, only: [:get_links]
  before_action :set_user_by_client_id, only: [:get_uid]
  before_action :set_shopify_order, only: [:deposit_redirect]
  before_action :set_request_by_id, only: [:deposit_redirect]
  before_action :set_request_by_email, only: [:get_ids, :get_links, :deposit_redirect]

  def redirect
    @request = Request.find(params[:requestId]) if params[:requestId].present? && Request.find(params[:requestId])
    @request ||= Request.find_by__ga(params[:_ga]) if params[:_ga] && Request.where(_ga: params[:_ga]).any?

    @url = 'https://shop.customtattoodesign.ca/products/'
    if @request&.client_id && @request.client_id != 'false'
      @request.update_columns(variant: params[:variant], handle: params[:handle], last_visited_at: Time.now)
      @url += "#{params[:handle]}?variant=#{params[:variant]}&uid=#{@request.user_id}&cid=#{@request.client_id}&reqid=#{@request.id}"
    elsif @request
      @url += "#{params[:handle]}?variant=#{params[:variant]}&utm_campaign=blocked&utm_source=crm&utm_medium=email&reqid=#{@request.id}"
    else
      @url += "#{params[:handle]}?variant=#{params[:variant]}&utm_campaign=unlisted&utm_source=crm&utm_medium=email"
    end
    @url += "&salesid=#{params[:salesId]}" if params[:salesId]
  end

  def new_request
    recent_requests = Request.recent.where(user_id: @user.id, position: params[:position])
    if recent_requests.any?
      @request = recent_requests.first
      @request.update(request_params.reject { |_, v| v.blank? })
    else
      @request = Request.new(request_params)
      @request.user = @user
      @request.save
    end
  end

  def deposit_redirect
    @order.update_request

    if @request
      respond_to do |format|
        format.json { render json: !@request.deposit_order_id.nil? }
        format.html {}
      end
    else
      render text: "Request not found"
    end
  end

  def get_uid
    render json: @user.id
  end

  def get_links; end

  def get_ids; end

  def set_link
    @request = Request.find(params[:request_id])
    @request.variant = params[:variant_id]
    @request.quoted_by_id = params[:salesperson_id]
    @request.state = "quoted" if @request.state == "fresh"
    @request.save!

    box = StreakAPI::Box.find_by_email(params[:email])
    if box
      current_stage = StreakAPI::Stage.find(key: box.stage_key)
      if current_stage.name == 'Contacted' || current_stage.name == 'Leads'
        StreakAPI::Box.set_stage(box.key, 'Quoted')
      end
    end
    head :ok
  end

  def save_email
    from_email = params[:from_email].downcase.strip
    @salesperson = Salesperson.find_by_email!(from_email)

    recipient_email = params[:recipient_email]
    @salesperson.claim_requests_with_email(recipient_email)

    box = StreakAPI::Box.find_by_email(recipient_email)
    if box
      current_stage = StreakAPI::Stage.find(key: box.stage_key)

      if current_stage.name == 'Leads'
        StreakAPI::Box.set_stage(box.key, 'Contacted')
      end

      user_key = @salesperson&.user_key
      user_key ||= StreakAPI::User.find_by_email(from_email)

      if user_key
        StreakAPI::Box.add_follower(@salesperson.streak_api_key, box.key, user_key)
      else
        Rails.logger.error ">>> Cannot get streak follower key for `#{from_email}`"
      end
    end
    head :ok
  end

  private

  def set_request_by_id
    @request = Request.joins(:user).where(id: params[:request_id]).first if params[:request_id].present?
  end

  def set_request_by_email
    return if @request
    requests = Request.joins(:user).where('users.email LIKE ?', params[:email])
    @request = requests.any? ? requests.first : Request.create(user: @user)
  end

  def set_last_request_by_email
    @request = @user.requests.last
  end

  def set_shopify_order
    return if params[:order_id].blank?
    source_order = ShopifyAPI::Order.find(params[:order_id])
    @order = Shopify::Order.new source_order
  end

  def set_salesperson_by_email
    @salesperson = Salesperson.find_by_email(params[:sales_email].downcase.strip) unless params[:sales_email].to_s.empty?
    @salesperson ||= Salesperson.find_by_email(params[:from_email].downcase.strip) unless params[:sales_email].to_s.empty?
  end

  def set_or_create_user_by_email
    users = User.where(email: params[:email])
    return users.first if users.any?

    password = SecureRandom.hex(8)
    @user = User.create(email: params[:email], password: password, password_confirmation: password)
  end

  def set_user_by_client_id
    render(json: false) && return unless params[:client_id]

    @user = User.joins(:requests).where(requests: { client_id: params[:client_id] }).first
  end

  def load_products
    @groups = Shopify::Group.all.reject do |group|
      group.products.count == 0
    end
  end

  def validate_parameters
    [:position, :gender, :first_name, :last_name, :client_id].each do |sym|
      render(json: false) if params[sym] == '' || params[sym] == false
    end
  end

  def request_params
    params.permit(:client_id, :ticket_id, :quote_id, :position, :gender,
                  :has_color, :is_first_time, :first_name, :last_name, :linker_param, :_ga, :reqid, :salesid, :description)
  end

  def normalize_email
    params[:email] = params[:email].downcase.strip if params[:email]
  end

  def disable_cache
    response.headers['Cache-Control'] = 'no-cache, no-store'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = 'Fri, 01 Jan 1990 00:00:00 GMT'
  end
end

require 'securerandom'
