# frozen_string_literal: true

# Provides most publicly-accessible API routes
class PublicController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :disable_cache, only: [:get_links]

  before_action :set_salesperson_by_email, only: [:get_links]
  before_action :load_products, only: [:get_links]
  before_action :set_user_by_client_id, only: [:get_uid]
  before_action :set_shopify_order, only: [:deposit_redirect]
  before_action :set_request_by_id, only: [:set_link, :deposit_redirect]

  # Things that require a params[:email]
  before_action :normalize_email, if: :email_is_present?
  before_action :assert_email_is_valid, only: [:get_ids, :get_links, :deposit_redirect, :new_request]
  before_action :set_or_create_user_by_email, only: [:get_ids, :get_links, :deposit_redirect, :new_request]
  before_action :validate_request_parameters, only: [:new_request]
  before_action :update_user_names, only: [:new_request]
  before_action :set_or_create_request_by_email, only: [:get_ids, :get_links, :deposit_redirect]

  def redirect
    request.format = "html"
    @request = Request.find(params[:requestId]) if params[:requestId].present? && Request.find(params[:requestId])
    @request ||= Request.find_by__ga(params[:_ga]) if params[:_ga] && Request.where(_ga: params[:_ga]).any?

    @url = "https://shop.customtattoodesign.ca/products/"
    if @request&.client_id && @request.client_id != "false"
      @request.update_columns(variant: params[:variant], handle: params[:handle], last_visited_at: Time.now)
      @url += "#{params[:handle]}?variant=#{params[:variant]}&uid=#{@request.user_id}&cid=#{@request.client_id}&reqid=#{@request.id}"
    elsif @request
      @request.update_columns(last_visited_at: Time.now)
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
    @order.update_request!(@request)
    # Update custom field 'Purchased' to Yes on Campaign Monitor
    CampaignMonitorActionJob.set(wait: 10.seconds).perform_later(user: @request.user, method: "update_user_to_all_list")

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
    request.format = "json"
    render json: @user&.id
  end

  def get_links
    request.format = "json"
  end

  def get_ids
    request.format = "json"
  end

  def set_link
    head 404 unless @request
    head 422 unless @request.user.email == params[:email]
    @request.quote_from_params! request_link_params

    head :ok
  end

  def save_email
    args = SaveEmailJobArguments.new salesperson_email: params[:from_email], recipient_email: params[:recipient_email]
    head(422) && return unless args.valid?

    SaveEmailJob.perform_later(args.to_h)
    head :ok
  end

  def unsubscribed
  end

  private

  def update_user_names
    return if @user.first_name.to_s.present?

    @user.update user_params
  end

  def request_link_params
    params.require(:variant_id)
    params.require(:salesperson_id)
    params.permit :variant_id, :salesperson_id
  end

  def set_request_by_id
    @request = Request.joins(:user).where(id: params[:request_id]).first if params[:request_id].present?
  end

  def set_or_create_request_by_email
    return if @request

    @request = Request.joins(:user).where("users.email LIKE ?", params[:email]).first
    @request ||= Request.create(user: @user)
  end

  def set_last_request_by_email
    @request = @user.requests.last
  end

  def set_shopify_order
    return if params[:order_id].blank?

    source_order = ShopifyAPI::Order.find(params[:order_id])
    @order = MostlyShopify::Order.new source_order
    params[:email] ||= @order&.customer&.email
  end

  def set_salesperson_by_email
    sales_email = params[:sales_email].to_s.downcase.strip
    @salesperson = Salesperson.find_by_email(sales_email) unless sales_email.empty?
    @salesperson ||= Salesperson.find_by_email(sales_email) unless sales_email.empty?
    head 400 unless @salesperson
  end

  def set_or_create_user_by_email
    @user = User.find_by_email(params[:email])
    return if @user

    password = SecureRandom.hex(8)
    @user = User.create(email: params[:email], password: password, password_confirmation: password)
  end

  def set_user_by_client_id
    render(json: false) && return if params[:client_id].blank?

    @user = User.joins(:requests).where(requests: { client_id: params[:client_id] }).first
  end

  def load_products
    @groups = MostlyShopify::Group.all.reject do |group|
      group.products.count.zero?
    end
  end

  def validate_request_parameters
    [:position, :gender, :first_name, :last_name, :client_id].each do |sym|
      head(422) && return if params[sym] == "" || params[sym] == false
    end
  end

  def request_params
    params.permit(
      :client_id,
      :ticket_id,
      :quote_id,
      :position,
      :gender,
      :first_name,
      :last_name,
      :has_color,
      :has_cover_up,
      :is_first_time,
      :first_name,
      :last_name,
      :linker_param,
      :_ga,
      :reqid,
      :salesid,
      :style,
      :size,
      :description,
      :has_cover_up,
      user_attributes: [:marketing_opt_in]
    )
  end

  def user_params
    params.permit(:first_name, :last_name)
  end

  def normalize_email
    params[:email] = params[:email].downcase.strip
  end

  def disable_cache
    response.headers["Cache-Control"] = "no-cache, no-store"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  def email_is_present?
    @email_is_present ||= !params[:email].to_s.empty?
  end

  def assert_email_is_valid
    head 422 unless params[:email] =~ URI::MailTo::EMAIL_REGEXP
  end
end

require "securerandom"
