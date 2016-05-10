class PublicController < ApplicationController
  skip_before_filter :verify_authenticity_token

  before_filter :validate_parameters, only: [:new_request]
  before_filter :set_user_by_email, only: [ :new_request, :get_links ]
  before_filter :set_salesperson_by_email, only: [ :get_links ]
  before_filter :load_products, only: [ :get_links ]
  before_filter :set_user_by_client_id, only: [ :get_uid ]

  def redirect
    @user_id = params[:uid]
    @client_id = params[:client_id]
    @client_id ||= params[:clientId]
    @linker_param = params[:linkerParam]
    @_ga = params[:_ga]
    @sales_id = params[:salesid]
    @req_id = params[:reqid]

    @variant = params[:variant]
    @handle = params[:handle]
  end

  def new_request
    request_params
    if Request.recent.where(user_id: @user.id, position: params[:position]).any?
      Request.recent.where(user_id: @user.id, position: params[:position]).delete_all
    end
    @request = @user.requests.create(request_params)
  end

  def get_uid
    render json: @user.id
  end

  def get_links
  end

  private

  def set_user_by_client_id
    if Request.where( client_id: params[:client_id] ).any?
      user_id = Request.find_by_client_id( params[:client_id] ).user_id
      @user =  User.find(user_id)
    else
      render json: false
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
