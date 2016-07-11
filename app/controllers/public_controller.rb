class PublicController < ApplicationController
  skip_before_filter :verify_authenticity_token

  before_filter :validate_parameters, only: [:new_request]
  before_filter :set_user_by_email, only: [ :new_request, :get_links ]
  before_filter :set_salesperson_by_email, only: [ :get_links ]
  before_filter :load_products, only: [ :get_links ]
  before_filter :set_user_by_client_id, only: [ :get_uid ]
  before_filter :set_request_by_email, only: [ :get_ids, :get_links ]

  def redirect
    @user_id = params[:uid]
    @client_id = params[:client_id]
    @client_id ||= params[:clientId]
    @linker_param = params[:linkerParam]
    @_ga = params[:_ga]
    @req_id = params[:reqid]

    @variant = params[:variant]
    @handle = params[:handle]

    @sales_id = params[:salesId]

    if params[:requestId] != nil && Request.where(id: params[:requestId] ).any?
      @request = Request.find(params[:requestId])
    end
    if not @request and ( params[:_ga] and Request.where(_ga: params[:_ga]).any? )
      @request = Request.find_by__ga(params[:_ga])
    end

    if @request and @request.client_id and @request.client_id != 'false'
      @request.update_columns( variant: @variant, handle: @handle, last_visited_at: Time.now )
      @url ="http://shop.customtattoodesign.ca/products/#{@handle}?variant=#{@variant}&uid=#{@request.user_id}&cid=#{@request.client_id}&reqid=#{@request.id}"
    elsif @request
      @url = "http://shop.customtattoodesign.ca/products/#{@handle}?variant=#{@variant}&utm_campaign=blocked&utm_source=crm&utm_medium=email&reqid=#{@request.id}"
    else
      @url = "http://shop.customtattoodesign.ca/products/#{@handle}?variant=#{@variant}&utm_campaign=unlisted&utm_source=crm&utm_medium=email"
    end
    if @sales_id
      @url = "#{@url}&salesid=#{@sales_id}"
    end
  end

  def new_request
    request_params
    if Request.recent.where(user_id: @user.id, position: params[:position]).any?
      Request.recent.where(user_id: @user.id, position: params[:position]).delete_all
    end
    @request = Request.create(request_params)
    @request.save
    @user.requests << @request
  end

  def get_uid
    render json: @user.id
  end

  def get_links
  
  end

  def get_ids

  end

  def set_link
    @request = Request.find(params[:request_id])
    @request.variant = params[:variant_id]
    @request.quoted_by_id = params[:salesperson_id]
    @request.save!
    box = StreakAPI::Box.find_by_email(params[:email])
    if box
      current_stage = StreakAPI::Stage.find(key: box.stage_key)
      if current_stage.name == "Contacted" || current_stage.name == "Lead"
        StreakAPI::Box.set_stage(box.key, "Quoted")
      end
    end
    head :ok
  end

  def save_email
    @salesperson = Salesperson.find_by_email( params[:from_email] )
    box = StreakAPI::Box.find_by_email(params[:recipient_email])
    if box
      current_stage = StreakAPI::Stage.find(key: box.stage_key)

      if current_stage.name == "Lead"
        StreakAPI::Box.set_stage(box.key, "Contacted")
      end

      user_key = StreakAPI::User.find_by_email(params[:from_email])
      StreakAPI::Box.add_follower(@salesperson.streak_api_key, box.key, user_key)
    end
    head :ok
  end

  private

  def set_request_by_email
    requests = Request.joins(:user).where( 'users.email LIKE ?', params[:email] )
    if requests.any?
      @request = requests.first
    else
      if Rails.env.development?
        @request = Request.create( user: @user )
      else
        render json: false
      end
    end
  end

  def set_salesperson_by_email
    if params[:sales_email]
      if Salesperson.where( email: params[:sales_email] ).any?
        @salesperson =  Salesperson.find_by_email( params[:sales_email] )
      else
        password = SecureRandom.hex(8)
        @salesperson = Salesperson.create( email: params[:sales_email], password: password, password_confirmation: password )
      end
    end
  end

  def set_user_by_email
    if User.where( email: params[:email] ).any?
      @user =  User.find_by_email( params[:email] )
    else
      password = SecureRandom.hex(8)
      @user = User.create( email: params[:email], password: password, password_confirmation: password )
    end
  end

  def set_user_by_client_id
    if Request.where( client_id: params[:client_id] ).any?
      user_id = Request.find_by_client_id( params[:client_id] ).user_id
      @user =  User.find(user_id)
    else
      render json: false
    end
  end

  def load_products
    @groups = Shopify::Group.all.reject{ |group|
      group.products.count == 0
    }
  end

  def validate_parameters
   [:position, :gender, :first_name, :last_name, :client_id ].each do |sym|
      render( json: false ) if params[sym] == '' or params[sym] == false
    end
  end

  def request_params
    params.permit( :client_id, :ticket_id, :quote_id, :position, :gender,
                   :has_color, :is_first_time, :first_name, :last_name, :linker_param, :_ga, :reqid, :salesid )
  end
end

require 'securerandom'
