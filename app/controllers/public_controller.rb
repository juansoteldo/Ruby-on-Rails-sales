class PublicController < ApplicationController
  skip_before_filter :verify_authenticity_token

  before_action :disable_cache, only: [:get_links]

  before_action :normalize_email
  before_action :validate_parameters, only: [:new_request]
  before_action :set_user_by_email, only: [:new_request, :get_links]
  before_action :set_salesperson_by_email, only: [ :get_links ]
  before_action :load_products, only: [ :get_links ]
  before_filter :set_user_by_client_id, only: [ :get_uid ]
  before_filter :set_request_by_email, only: [ :get_ids, :get_links ]


  def redirect
    if params[:requestId] != nil && Request.where(id: params[:requestId] ).any?
      @request = Request.find(params[:requestId])
    end
    if not @request and ( params[:_ga] and Request.where(_ga: params[:_ga]).any? )
      @request = Request.find_by__ga(params[:_ga])
    end

    @url = 'http://shop.customtattoodesign.ca/products/'

    if @request and @request.client_id and @request.client_id != 'false'
      @request.update_columns( variant: params[:variant], handle: params[:handle], last_visited_at: Time.now )
      @url += "#{params[:handle]}?variant=#{params[:variant]}&uid=#{@request.user_id}&cid=#{@request.client_id}&reqid=#{@request.id}"
    elsif @request
      @url += "#{params[:handle]}?variant=#{params[:variant]}&utm_campaign=blocked&utm_source=crm&utm_medium=email&reqid=#{@request.id}"
    else
      @url += "#{params[:handle]}?variant=#{params[:variant]}&utm_campaign=unlisted&utm_source=crm&utm_medium=email"
    end
    if params[:salesId]
      @url += "&salesid=#{params[:salesId]}"
    end
  end

  def new_request
    request_params
    if Request.recent.where(user_id: @user.id, position: params[:position]).any?
      Request.recent.where(user_id: @user.id, position: params[:position]).delete_all
    end

    @request = Request.create(request_params)
    @request.save

    set_user_by_email if @user.nil?
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

    box = StreakAPI::Box.find_by_email( params[:email] )
    if box
      current_stage = StreakAPI::Stage.find(key: box.stage_key)
      if current_stage.name == "Contacted" || current_stage.name == "Leads"
        StreakAPI::Box.set_stage(box.key, "Quoted")
      end
    end
    head :ok
  end

  def save_email
    from_email = params[:from_email].downcase.strip
    recipient_email = params[:recipient_email]
    @salesperson = Salesperson.find_by_email( from_email )
    box = StreakAPI::Box.find_by_email(recipient_email)
    if box
      current_stage = StreakAPI::Stage.find(key: box.stage_key)

      if current_stage.name == "Leads"
        StreakAPI::Box.set_stage(box.key, "Contacted")
      end

      user_key = Salesperson.where( email: from_email ).any? && Salesperson.find_by( email: from_email ).user_key || nil
      user_key ||= StreakAPI::User.find_by_email( from_email )

      if user_key
        StreakAPI::Box.add_follower(@salesperson.streak_api_key, box.key, user_key)
      else
        Rails.logger.error ">>> Cannot get streak follower key for `#{from_email}`"
      end
    end
    head :ok
  end

  private

  def set_request_by_email
    requests = Request.joins(:user).where( 'users.email LIKE ?', params[:email] )
    if requests.any?
      @request = requests.first
    else
      @request = Request.create( user: @user )
    end
  end

  def set_salesperson_by_email
    if params[:sales_email]
      sales_email = params[:sales_email].downcase.strip

      if Salesperson.where( email: sales_email ).any?
        @salesperson =  Salesperson.find_by_email( sales_email )
      else
        password = SecureRandom.hex(8)
        @salesperson = Salesperson.create( email: sales_email, password: password, password_confirmation: password )
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
    if params[:client_id] && Request.where( client_id: params[:client_id] ).any?
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

  def normalize_email
    if params[:email]
      params[:email] = params[:email].downcase.strip
    end
  end

  def disable_cache
    response.headers["Cache-Control"] = "no-cache, no-store"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
end

require 'securerandom'
